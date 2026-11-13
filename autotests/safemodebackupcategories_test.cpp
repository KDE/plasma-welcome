/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "safemodebackupcategories.h"

#include <KLocalizedString>

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSignalSpy>
#include <QTemporaryDir>
#include <QtTest>

#include <initializer_list>
#include <utility>
#include <vector>

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

const CategoryInfo *categoryForSubDir(const CategoryTree &tree, const QString &subDirName)
{
    for (const CategoryInfo &info : tree.categories) {
        if (info.backupSubDirName == subDirName) {
            return &info;
        }
    }
    return nullptr;
}

bool writeFile(const QString &path, const QByteArray &contents = {})
{
    if (!QDir().mkpath(QFileInfo(path).absolutePath())) {
        return false;
    }
    QFile file(path);
    return file.open(QIODevice::WriteOnly) && file.write(contents) == contents.size();
}

CategoryGroupInfo makeGroup(CategoryGroup group, std::vector<Category> categories)
{
    return CategoryGroupInfo{
        group,
        CategoryGroupInfo::Strings{
            .description = QStringLiteral("Description"),
            .backupTitle = QStringLiteral("Backup title"),
            .backupSuccessTitle = QStringLiteral("Backup success title"),
            .restoreTitle = QStringLiteral("Restore title"),
            .restoreSuccessTitle = QStringLiteral("Restore success title"),
        },
        true,
        std::move(categories),
    };
}

CategoryInfo makeCategory(Category category, CategoryGroup group, const QString &sourceRoot)
{
    return CategoryInfo{
        category,
        group,
        sourceRoot,
        QStringLiteral("category-%1").arg(category),
        nullptr,
        QStringLiteral("Category %1").arg(category),
        QString(),
    };
}

Qt::CheckState selectionState(const CategoryModel &model, int row)
{
    return static_cast<Qt::CheckState>(model.data(model.index(row, 0), CategoryModel::SelectionStateRole).toInt());
}

bool isAvailable(const CategoryModel &model, int row)
{
    return model.data(model.index(row, 0), CategoryModel::AvailableRole).toBool();
}

bool isSuccessful(const CategoryModel &model, int row)
{
    return model.data(model.index(row, 0), CategoryModel::SuccessfulRole).toBool();
}
} // anonymous namespace

class SafeModeBackupCategoriesTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void initTestCase();
    void pathClassification();
    void entireDirectoryPaths();
    void emptyRootsProduceNoTree();
    void modelSelectionState();
    void modelResults();
    void modelConflicts();
};

void SafeModeBackupCategoriesTest::initTestCase()
{
    KLocalizedString::setApplicationDomain("plasma-welcome");
}

void SafeModeBackupCategoriesTest::pathClassification()
{
    QTemporaryDir home;
    QTemporaryDir config;
    QTemporaryDir data;
    QTemporaryDir state;
    QVERIFY(home.isValid());
    QVERIFY(config.isValid());
    QVERIFY(data.isValid());
    QVERIFY(state.isValid());

    EnvironmentGuard env({QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME"),
                          QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_DATA_HOME"),
                          QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_STATE_HOME")});
    env.set(QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME"), config.path());
    env.set(QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_DATA_HOME"), data.path());
    env.set(QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_STATE_HOME"), state.path());

    QVERIFY(writeFile(config.filePath(QStringLiteral("kdeglobals"))));
    QVERIFY(writeFile(config.filePath(QStringLiteral("KDE/Sonnet.conf"))));
    QVERIFY(writeFile(config.filePath(QStringLiteral("KDE/other.conf"))));
    QVERIFY(writeFile(config.filePath(QStringLiteral("autostart/foo.desktop"))));
    QVERIFY(writeFile(config.filePath(QStringLiteral("someapp/settings.conf"))));

    const CategoryTree tree = makeCategoryTree(home.path());
    const CategoryInfo *plasma = categoryForSubDir(tree, QStringLiteral("config-plasma"));
    const CategoryInfo *remaining = categoryForSubDir(tree, QStringLiteral("config"));
    QVERIFY(plasma);
    QVERIFY(remaining);

    const QSet<QString> plasmaPaths = plasma->existingSourcePaths(config.path());
    QVERIFY(plasmaPaths.contains(QStringLiteral("kdeglobals")));
    QVERIFY(plasmaPaths.contains(QStringLiteral("KDE/Sonnet.conf")));
    QVERIFY(plasmaPaths.contains(QStringLiteral("autostart")));
    QVERIFY(!plasmaPaths.contains(QStringLiteral("KDE/other.conf")));
    QVERIFY(!plasmaPaths.contains(QStringLiteral("someapp")));

    const QSet<QString> remainingPaths = remaining->existingSourcePaths(config.path());
    QVERIFY(!remainingPaths.contains(QStringLiteral("kdeglobals")));
    QVERIFY(!remainingPaths.contains(QStringLiteral("KDE/Sonnet.conf")));
    QVERIFY(!remainingPaths.contains(QStringLiteral("autostart")));
    QVERIFY(remainingPaths.contains(QStringLiteral("KDE/other.conf")));
    QVERIFY(remainingPaths.contains(QStringLiteral("someapp")));
}

void SafeModeBackupCategoriesTest::entireDirectoryPaths()
{
    QTemporaryDir home;
    QTemporaryDir state;
    QTemporaryDir data;
    QVERIFY(home.isValid());
    QVERIFY(state.isValid());
    QVERIFY(data.isValid());

    QVERIFY(writeFile(state.filePath(QStringLiteral("recent-documents"))));
    QVERIFY(writeFile(data.filePath(QStringLiteral("favorites"))));

    EnvironmentGuard env({QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME"),
                          QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_DATA_HOME"),
                          QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_STATE_HOME")});
    env.set(QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME"), home.path());
    env.set(QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_DATA_HOME"), data.path());
    env.set(QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_STATE_HOME"), state.path());

    const CategoryTree tree = makeCategoryTree(home.path());
    const CategoryInfo *stateCategory = categoryForSubDir(tree, QStringLiteral("state"));
    const CategoryInfo *dataCategory = categoryForSubDir(tree, QStringLiteral("data"));
    QVERIFY(stateCategory);
    QVERIFY(dataCategory);

    QVERIFY(stateCategory->isEntireDir());
    QVERIFY(dataCategory->isEntireDir());

    const QSet<QString> statePaths = stateCategory->existingSourcePaths(state.path());
    const QSet<QString> dataPaths = dataCategory->existingSourcePaths(data.path());
    QCOMPARE(statePaths, QSet<QString>{QStringLiteral(".")});
    QCOMPARE(dataPaths, QSet<QString>{QStringLiteral(".")});
}

void SafeModeBackupCategoriesTest::emptyRootsProduceNoTree()
{
    EnvironmentGuard env({QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME"),
                          QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_DATA_HOME"),
                          QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_STATE_HOME")});
    env.set(QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME"), QString());
    env.set(QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_DATA_HOME"), QString());
    env.set(QByteArrayLiteral("KDE_SAFEMODE_ORIG_XDG_STATE_HOME"), QString());

    const CategoryTree tree = makeCategoryTree(QString());
    QVERIFY(tree.categories.empty());
    QVERIFY(tree.groups.empty());
}

void SafeModeBackupCategoriesTest::modelSelectionState()
{
    const CategoryGroup Group0 = 0;

    CategoryTree tree;
    tree.groups.push_back(makeGroup(Group0, {0, 1}));
    tree.categories.push_back(makeCategory(0, Group0, QStringLiteral("/a")));
    tree.categories.push_back(makeCategory(1, Group0, QStringLiteral("/b")));

    CategoryModel model(tree, Operation::Backup);
    QCOMPARE(model.rowCount(), 1);

    QVERIFY(!isAvailable(model, Group0));
    QCOMPARE(selectionState(model, Group0), Qt::Unchecked);

    model.setCategoryAvailable(0, true);
    QVERIFY(isAvailable(model, Group0));
    QCOMPARE(selectionState(model, Group0), Qt::Unchecked);

    model.setGroupSelected(Group0, Qt::Checked);
    QCOMPARE(selectionState(model, Group0), Qt::Checked);
    QVERIFY(model.isCategorySelected(0));
    QVERIFY(!model.isCategorySelected(1)); // not available => not selected

    // Making the previously unavailable category available should turn the group
    // into a partially checked state.
    model.setCategoryAvailable(1, true);
    QCOMPARE(selectionState(model, Group0), Qt::PartiallyChecked);

    model.setCategorySelected(1, true);
    QCOMPARE(selectionState(model, Group0), Qt::Checked);

    // Removing the unselected category should not require a selection change
    // to update the group state.
    model.setCategorySelected(1, false);
    QCOMPARE(selectionState(model, Group0), Qt::PartiallyChecked);
    model.setCategoryAvailable(1, false);
    QCOMPARE(selectionState(model, Group0), Qt::Checked);

    model.setCategoryAvailable(0, false);
    QCOMPARE(selectionState(model, Group0), Qt::Unchecked);
    QVERIFY(!model.hasSelectedCategories());
}

void SafeModeBackupCategoriesTest::modelResults()
{
    const CategoryGroup Group0 = 0;

    CategoryTree tree;
    tree.groups.push_back(makeGroup(Group0, {0, 1}));
    tree.categories.push_back(makeCategory(0, Group0, QStringLiteral("/a")));
    tree.categories.push_back(makeCategory(1, Group0, QStringLiteral("/b")));

    CategoryModel model(tree, Operation::Backup);
    QSignalSpy successSpy(&model, &CategoryModel::hasSuccessfulCategoriesChanged);

    QVERIFY(!isSuccessful(model, Group0));

    model.setCategoryResult(0, Result::Succeeded);
    QVERIFY(isSuccessful(model, Group0));
    QCOMPARE(successSpy.count(), 1);

    model.setCategoryResult(1, Result::Failed);
    QVERIFY(!isSuccessful(model, Group0));
    QCOMPARE(successSpy.count(), 2);

    model.resetCategoryResults({Result::Failed});
    QVERIFY(isSuccessful(model, Group0));
    QCOMPARE(successSpy.count(), 3);

    model.setCategoryResult(1, Result::Operating);
    QVERIFY(!isSuccessful(model, Group0));
    QCOMPARE(successSpy.count(), 4);

    model.resetCategoryResults({Result::Operating});
    QVERIFY(isSuccessful(model, Group0));
    QCOMPARE(successSpy.count(), 5);

    model.resetCategoryResults();
    QVERIFY(!isSuccessful(model, Group0));
    QCOMPARE(successSpy.count(), 6);
}

void SafeModeBackupCategoriesTest::modelConflicts()
{
    const CategoryGroup Group0 = 0;

    CategoryTree tree;
    tree.groups.push_back(makeGroup(Group0, {0, 1}));
    tree.categories.push_back(makeCategory(0, Group0, QStringLiteral("/a")));
    tree.categories.push_back(makeCategory(1, Group0, QStringLiteral("/b")));

    CategoryModel model(tree, Operation::Backup);
    model.setCategoryAvailable(0, true);
    model.setCategoryAvailable(1, true);
    QCOMPARE(model.conflictingPaths(), QList<QUrl>{});

    const QUrl conflictA(QStringLiteral("file:///tmp/conflict-a"));
    const QUrl conflictB(QStringLiteral("file:///tmp/conflict-b"));
    model.setCategoryConflictingPaths(0, {conflictA});
    model.setCategoryConflictingPaths(1, {conflictB});

    QSignalSpy conflictSpy(&model, &CategoryModel::conflictingPathsChanged);
    model.setCategorySelected(0, true);
    QCOMPARE(model.conflictingPaths(), QList<QUrl>{conflictA});
    QCOMPARE(conflictSpy.count(), 1);

    model.setCategorySelected(1, true);
    QCOMPARE(model.conflictingPaths(), (QList<QUrl>{conflictA, conflictB}));
    QCOMPARE(conflictSpy.count(), 2);

    model.setCategorySelected(0, false);
    QCOMPARE(model.conflictingPaths(), QList<QUrl>{conflictB});
    QCOMPARE(conflictSpy.count(), 3);
}

QTEST_GUILESS_MAIN(SafeModeBackupCategoriesTest)

#include "safemodebackupcategories_test.moc"
