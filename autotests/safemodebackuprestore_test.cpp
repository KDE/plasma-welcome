/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "safemodebackupcategories.h"
#include "safemodebackuprestore.h"

#include <KLocalizedString>

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSignalSpy>
#include <QTemporaryDir>
#include <QUrl>
#include <QtTest>

#include <initializer_list>
#include <memory>
#include <utility>

using namespace SafeModeBackup;

namespace
{
class EnvironmentGuard
{
public:
    explicit EnvironmentGuard(std::initializer_list<QByteArray> names)
    {
        for (const QByteArray &name : names) {
            Entry entry;
            entry.name = name;
            entry.wasSet = qEnvironmentVariableIsSet(name.constData());
            if (entry.wasSet) {
                entry.value = qgetenv(name.constData());
            }
            m_entries.append(entry);
        }
    }

    ~EnvironmentGuard()
    {
        for (const Entry &entry : m_entries) {
            if (entry.wasSet) {
                qputenv(entry.name.constData(), entry.value);
            } else {
                qunsetenv(entry.name.constData());
            }
        }
    }

    void set(const QByteArray &name, const QString &value)
    {
        qputenv(name.constData(), QFile::encodeName(value));
    }

private:
    struct Entry {
        QByteArray name;
        QByteArray value;
        bool wasSet = false;
    };
    QList<Entry> m_entries;
};

bool writeFile(const QString &path, const QByteArray &contents = {})
{
    if (!QDir().mkpath(QFileInfo(path).absolutePath())) {
        return false;
    }
    QFile file(path);
    return file.open(QIODevice::WriteOnly) && file.write(contents) == contents.size();
}

const CategoryInfo *categoryForSubDir(const CategoryTree &tree, const QString &subDirName)
{
    for (const CategoryInfo &info : tree.categories) {
        if (info.backupSubDirName == subDirName) {
            return &info;
        }
    }
    return nullptr;
}

CategoryGroup groupForSubDir(const CategoryTree &tree, const QString &subDirName)
{
    const CategoryInfo *info = categoryForSubDir(tree, subDirName);
    return info ? info->group : -1;
}
} // anonymous namespace

class SafeModeBackupRestoreTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void initTestCase();
    void init();
    void cleanup();

    void backupMovesFileAndEntireDirectory();
    void rejectOperationWhileOperating();
    void emptyOperationDoesNotReportSuccess();
    void detectsFileConflicts();
    void hasRestoreConflictsWithExistingWholeDirectory();
    void restoreRemovesEmptyCategoryRoot();
    void restoreRetainsNonEmptyCategoryRoot();
    void rejectsOverlappingBackupDirectory();

private:
    QString configDir() const
    {
        return m_sourceRoot->filePath(QStringLiteral("config"));
    }
    QString stateDir() const
    {
        return m_sourceRoot->filePath(QStringLiteral("state"));
    }
    QString dataDir() const
    {
        return m_sourceRoot->filePath(QStringLiteral("data"));
    }

    CategoryTree categoryTree() const
    {
        return makeCategoryTree(m_home->path());
    }

    void selectGroups(CategoryModel *model, const QStringList &subDirNames);
    void deselectAllGroups(CategoryModel *model);
    void createBackupRestoreObject();

    std::unique_ptr<EnvironmentGuard> m_env;
    std::unique_ptr<QTemporaryDir> m_home;
    std::unique_ptr<QTemporaryDir> m_sourceRoot;
    std::unique_ptr<QTemporaryDir> m_backupRoot;
    std::unique_ptr<QTemporaryDir> m_otherBackupRoot;
    std::unique_ptr<SafeModeBackupRestore> m_backupRestoreObject;
};

void SafeModeBackupRestoreTest::initTestCase()
{
    KLocalizedString::setApplicationDomain("plasma-welcome");
}

void SafeModeBackupRestoreTest::init()
{
    m_home = std::make_unique<QTemporaryDir>();
    m_sourceRoot = std::make_unique<QTemporaryDir>();
    m_backupRoot = std::make_unique<QTemporaryDir>();
    m_otherBackupRoot = std::make_unique<QTemporaryDir>();
    QVERIFY(m_home->isValid());
    QVERIFY(m_sourceRoot->isValid());
    QVERIFY(m_backupRoot->isValid());
    QVERIFY(m_otherBackupRoot->isValid());

    QVERIFY(QDir().mkpath(configDir()));
    QVERIFY(QDir().mkpath(stateDir()));
    QVERIFY(QDir().mkpath(dataDir()));

    m_env = std::make_unique<EnvironmentGuard>(std::initializer_list<QByteArray>{
        QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME"),
        QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_DATA_HOME"),
        QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_STATE_HOME"),
    });
    m_env->set(QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME"), configDir());
    m_env->set(QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_DATA_HOME"), dataDir());
    m_env->set(QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_STATE_HOME"), stateDir());
}

void SafeModeBackupRestoreTest::cleanup()
{
    m_backupRestoreObject.reset();
    m_env.reset();
    m_otherBackupRoot.reset();
    m_backupRoot.reset();
    m_sourceRoot.reset();
    m_home.reset();
}

void SafeModeBackupRestoreTest::createBackupRestoreObject()
{
    m_backupRestoreObject = std::make_unique<SafeModeBackupRestore>(m_home->path());
    m_backupRestoreObject->setBackupDir(QUrl::fromLocalFile(m_backupRoot->path()));
    m_backupRestoreObject->updateAvailableCategories();
}

void SafeModeBackupRestoreTest::selectGroups(CategoryModel *model, const QStringList &subDirNames)
{
    const CategoryTree tree = categoryTree();
    for (const CategoryGroupInfo &group : tree.groups) {
        model->setGroupSelected(group.group, Qt::Unchecked);
    }
    for (const QString &subDirName : subDirNames) {
        const CategoryGroup group = groupForSubDir(tree, subDirName);
        if (group >= 0) {
            model->setGroupSelected(group, Qt::Checked);
        }
    }
}

void SafeModeBackupRestoreTest::deselectAllGroups(CategoryModel *model)
{
    const CategoryTree tree = categoryTree();
    for (const CategoryGroupInfo &group : tree.groups) {
        model->setGroupSelected(group.group, Qt::Unchecked);
    }
}

void SafeModeBackupRestoreTest::backupMovesFileAndEntireDirectory()
{
    QVERIFY(writeFile(configDir() + QStringLiteral("/kdeglobals")));
    QVERIFY(writeFile(stateDir() + QStringLiteral("/state-file")));

    createBackupRestoreObject();
    selectGroups(m_backupRestoreObject->backupCategories(), {QStringLiteral("config-plasma"), QStringLiteral("state")});

    QSignalSpy operatingSpy(m_backupRestoreObject.get(), &SafeModeBackupRestore::isOperatingChanged);
    QVERIFY(m_backupRestoreObject->moveCustomizationsToBackupDir());
    QTRY_VERIFY_WITH_TIMEOUT(!m_backupRestoreObject->isOperating(), 1000);

    QVERIFY(QFile::exists(m_backupRoot->filePath(QStringLiteral("config-plasma/kdeglobals"))));
    QVERIFY(!QFile::exists(configDir() + QStringLiteral("/kdeglobals")));
    QVERIFY(QFile::exists(m_backupRoot->filePath(QStringLiteral("state/state-file"))));
    QVERIFY(!QDir(stateDir()).exists());
    QVERIFY(operatingSpy.count() >= 2);
}

void SafeModeBackupRestoreTest::rejectOperationWhileOperating()
{
    QVERIFY(writeFile(configDir() + QStringLiteral("/kdeglobals")));

    createBackupRestoreObject();
    selectGroups(m_backupRestoreObject->backupCategories(), {QStringLiteral("config-plasma")});

    const QUrl originalBackupDir = m_backupRestoreObject->backupDir();
    QVERIFY(m_backupRestoreObject->moveCustomizationsToBackupDir());
    QVERIFY(m_backupRestoreObject->isOperating());
    QVERIFY(!m_backupRestoreObject->moveCustomizationsToBackupDir());

    m_backupRestoreObject->setBackupDir(QUrl::fromLocalFile(m_otherBackupRoot->path()));
    QCOMPARE(m_backupRestoreObject->backupDir(), originalBackupDir);

    QTRY_VERIFY_WITH_TIMEOUT(!m_backupRestoreObject->isOperating(), 1000);
}

void SafeModeBackupRestoreTest::emptyOperationDoesNotReportSuccess()
{
    QVERIFY(writeFile(configDir() + QStringLiteral("/kdeglobals")));

    createBackupRestoreObject();
    deselectAllGroups(m_backupRestoreObject->backupCategories());

    QVERIFY(!m_backupRestoreObject->moveCustomizationsToBackupDir());
    QVERIFY(!m_backupRestoreObject->isOperating());
    QVERIFY(m_backupRestoreObject->hasUserLogError());
    QVERIFY(!QFile::exists(m_backupRoot->filePath(QStringLiteral("config-plasma/kdeglobals"))));
}

void SafeModeBackupRestoreTest::detectsFileConflicts()
{
    QVERIFY(writeFile(configDir() + QStringLiteral("/kdeglobals")));
    QVERIFY(writeFile(m_backupRoot->filePath(QStringLiteral("config-plasma/kdeglobals"))));

    createBackupRestoreObject();
    selectGroups(m_backupRestoreObject->backupCategories(), {QStringLiteral("config-plasma")});

    const QList<QUrl> backupConflicts = m_backupRestoreObject->backupCategories()->conflictingPaths();
    QVERIFY(backupConflicts.contains(QUrl::fromLocalFile(m_backupRoot->filePath(QStringLiteral("config-plasma/kdeglobals")))));

    selectGroups(m_backupRestoreObject->restoreCategories(), {QStringLiteral("config-plasma")});
    const QList<QUrl> restoreConflicts = m_backupRestoreObject->restoreCategories()->conflictingPaths();
    QVERIFY(restoreConflicts.contains(QUrl::fromLocalFile(configDir() + QStringLiteral("/kdeglobals"))));
}

void SafeModeBackupRestoreTest::hasRestoreConflictsWithExistingWholeDirectory()
{
    QVERIFY(writeFile(m_backupRoot->filePath(QStringLiteral("state/state-file"))));
    QVERIFY(writeFile(stateDir() + QStringLiteral("/existing-state")));

    createBackupRestoreObject();
    selectGroups(m_backupRestoreObject->restoreCategories(), {QStringLiteral("state")});

    QVERIFY(!m_backupRestoreObject->restoreCustomizationsFromBackupDir());
    QVERIFY(!m_backupRestoreObject->isOperating());
    QVERIFY(QFile::exists(m_backupRoot->filePath(QStringLiteral("state/state-file"))));
    QVERIFY(!QFile::exists(stateDir() + QStringLiteral("/state-file")));
}

void SafeModeBackupRestoreTest::restoreRemovesEmptyCategoryRoot()
{
    QVERIFY(writeFile(m_backupRoot->filePath(QStringLiteral("config-plasma/kdeglobals"))));

    createBackupRestoreObject();
    selectGroups(m_backupRestoreObject->restoreCategories(), {QStringLiteral("config-plasma")});

    QVERIFY(m_backupRestoreObject->restoreCustomizationsFromBackupDir());
    QTRY_VERIFY_WITH_TIMEOUT(!m_backupRestoreObject->isOperating(), 1000);

    QVERIFY(QFile::exists(configDir() + QStringLiteral("/kdeglobals")));
    QVERIFY(!QDir(m_backupRoot->filePath(QStringLiteral("config-plasma"))).exists());
    QVERIFY(QDir(m_backupRoot->path()).exists());
}

void SafeModeBackupRestoreTest::restoreRetainsNonEmptyCategoryRoot()
{
    QVERIFY(writeFile(m_backupRoot->filePath(QStringLiteral("config-plasma/kdeglobals"))));
    QVERIFY(writeFile(m_backupRoot->filePath(QStringLiteral("config-plasma/leftover"))));

    createBackupRestoreObject();
    selectGroups(m_backupRestoreObject->restoreCategories(), {QStringLiteral("config-plasma")});

    QVERIFY(m_backupRestoreObject->restoreCustomizationsFromBackupDir());
    QTRY_VERIFY_WITH_TIMEOUT(!m_backupRestoreObject->isOperating(), 1000);

    QVERIFY(QFile::exists(configDir() + QStringLiteral("/kdeglobals")));
    QVERIFY(QDir(m_backupRoot->filePath(QStringLiteral("config-plasma"))).exists());
    QVERIFY(QFile::exists(m_backupRoot->filePath(QStringLiteral("config-plasma/leftover"))));
}

void SafeModeBackupRestoreTest::rejectsOverlappingBackupDirectory()
{
    createBackupRestoreObject();

    const QUrl originalBackupDir = m_backupRestoreObject->backupDir();
    m_backupRestoreObject->setBackupDir(QUrl::fromLocalFile(configDir()));
    QCOMPARE(m_backupRestoreObject->backupDir(), originalBackupDir);

    m_backupRestoreObject->setBackupDir(QUrl::fromLocalFile(m_sourceRoot->path()));
    QCOMPARE(m_backupRestoreObject->backupDir(), originalBackupDir);

    m_backupRestoreObject->setBackupDir(QUrl::fromLocalFile(m_otherBackupRoot->path()));
    QCOMPARE(m_backupRestoreObject->backupDir(), QUrl::fromLocalFile(m_otherBackupRoot->path()));

    const QUrl allowedBackupDir = m_backupRestoreObject->backupDir();
    m_backupRestoreObject->setBackupDir(QUrl(QStringLiteral("https://example.com/backup")));
    QCOMPARE(m_backupRestoreObject->backupDir(), allowedBackupDir);
}

QTEST_GUILESS_MAIN(SafeModeBackupRestoreTest)

#include "safemodebackuprestore_test.moc"
