/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "safemodefixes.h"

#include <KCompositeJob>
#include <KDirWatch>
#include <KIO/CopyJob>
#include <KIO/DeleteJob>
#include <KIO/MkpathJob>
#include <KIO/OpenUrlJob>
#include <KJob>
#include <KLocalizedString>
#include <kworkspace6/sessionmanagement.h>

#include <QDir>
#include <QDirListing>
#include <QFileInfo>
#include <QStandardPaths>
#include <QtEnvironmentVariables>

#include <algorithm>
#include <any>
#include <memory>

#include "welcome_debug.h"

using namespace Qt::StringLiterals;

namespace
{
QString withoutTrailingSlash(const QByteArray &path)
{
    return path.length() > 1 && path.endsWith('/') ? path.chopped(1) : path;
}

QString subPath(const QString &path, const QString &relativePath)
{
    return path + (path.endsWith('/') ? QString() : u"/"_s) + relativePath;
}

QUrl subPathUrl(const QUrl &url, const QString &subdirname)
{
    if (!url.isValid()) {
        return QUrl();
    }
    QUrl newUrl = url;
    newUrl.setPath(subPath(url.path(), subdirname));
    return newUrl;
}

class SequentialCompositeJob : public KCompositeJob
{
    Q_OBJECT

public:
    bool addSubjob(KJob *job) override; // original addSubjob() is protected, so we can't use it directly
    void start() override;
    QString errorString() const override;

    void setAbortOnError(bool abortOnError);

public Q_SLOTS:
    void setSubJobError(const KJob *subjob, const QString &customString = QString());

protected Q_SLOTS:
    void slotResult(KJob *job) override;

private:
    bool m_abortOnError = true;
};

bool SequentialCompositeJob::addSubjob(KJob *job)
{
    return KCompositeJob::addSubjob(job);
}

void SequentialCompositeJob::start()
{
    if (hasSubjobs()) {
        subjobs().first()->start();
    } else {
        emitResult();
    }
}

QString SequentialCompositeJob::errorString() const
{
    return errorText();
}

void SequentialCompositeJob::setAbortOnError(bool shouldAbort)
{
    m_abortOnError = shouldAbort;
}

void SequentialCompositeJob::setSubJobError(const KJob *subjob, const QString &customString)
{
    if (error()) {
        // Store only the first set error.
        // A subjob can choose to set it first with a custom string, before slotResult() gets to it.
        return;
    }
    setError(subjob->error());
    setErrorText(customString.isEmpty() ? subjob->errorString() : customString);
}

void SequentialCompositeJob::slotResult(KJob *job)
{
    if (job->error()) {
        setSubJobError(job);

        if (m_abortOnError) {
            emitResult();
            return;
        }
    }
    removeSubjob(job);
    start(); // a.k.a. continue/finish
}

static QSet<QString> makePlasmaConfigPaths()
{
    return QSet<QString>{
        "autostart"_L1,
        "fontconfig"_L1,
        "glib-2.0"_L1,
        "gtk-2.0"_L1,
        "gtk-3.0"_L1,
        "gtk-4.0"_L1,
        "KDE/kunifiedpush-distributor.conf"_L1,
        "KDE/Sonnet.conf"_L1,
        "KDE/UserFeedback.conf"_L1,
        "kde.org/systemsettings.conf"_L1,
        "kdeconnect"_L1,
        "kdedefaults"_L1,
        "menus"_L1,
        "plasma-workspace"_L1,
        "qtvirtualkeyboard"_L1,
        "session"_L1,
        "systemd"_L1,
        "baloofileinformationrc"_L1,
        "baloofilerc"_L1,
        "bluedevilglobalrc"_L1,
        "device_automounter_kcmrc"_L1,
        "discoverrc"_L1,
        "dolphinrc"_L1,
        "drkonqirc"_L1,
        "filetypesrc"_L1,
        "gtkrc"_L1,
        "gtkrc-2.0"_L1,
        "kaccessrc"_L1,
        "kactivitymanagerd-pluginsrc"_L1,
        "kactivitymanagerd-statsrc"_L1,
        "kactivitymanagerd-switcher"_L1,
        "kactivitymanagerdrc"_L1,
        "kcminputrc"_L1,
        "kcmshell6rc"_L1,
        "kconf_updaterc"_L1,
        "kded5rc"_L1,
        "kdeglobals"_L1,
        "kdialogrc"_L1,
        "kfontinstuirc"_L1,
        "kgammarc"_L1,
        "kglobalshortcutsrc"_L1,
        "khotkeysrc"_L1, // obsolete
        "kinfocenterrc"_L1,
        "kiorc"_L1,
        "kmenueditrc"_L1,
        "kmixctrlrc"_L1,
        "kmixrc"_L1,
        "knighttimerc"_L1,
        "krdpserverrc"_L1,
        "krunnerrc"_L1,
        "kscreenlockerrc"_L1,
        "kservicemenurc"_L1,
        "ksmserverrc"_L1,
        "ksysguardrc"_L1,
        "ktimezonedrc"_L1,
        "ktrashrc"_L1,
        "kuprc"_L1,
        "kwalletrc"_L1,
        "kwinoutputconfig.json"_L1,
        "kwinrc"_L1,
        "kxkbrc"_L1,
        "mimeapps.list"_L1,
        "plasma.emojierrc"_L1,
        "plasma-localerc"_L1,
        "plasma-nm"_L1,
        "plasma-org.kde.plasma.desktop-appletsrc"_L1,
        "plasma-welcomerc"_L1,
        "PlasmaDiscoverUpdates"_L1,
        "plasmanotifyrc"_L1,
        "plasmaparc"_L1,
        "plasmarc"_L1,
        "plasmashellrc"_L1,
        "plasmoidviewer-appletsrc"_L1,
        "powerdevil.notifyrc"_L1,
        "powerdevilrc"_L1,
        "powermanagementprofilesrc"_L1, // obsolete
        "print-manager"_L1,
        "QtProject.conf"_L1,
        "spectaclerc"_L1,
        "systemmonitorrc"_L1,
        "systemsettingsrc"_L1,
        "touchpadrc"_L1,
        "touchpadxlibinputrc"_L1, // obsolete
        "trashrc"_L1,
        "Trolltech.conf"_L1,
        "user-dirs.dirs"_L1,
        "user-dirs.locale"_L1,
        "xdg-desktop-portal-kderc"_L1,
    };
}

class BackupCategoryFiles
{
public:
    virtual ~BackupCategoryFiles() = default;
    virtual bool containsRelativePath(const QString &testedPath) const = 0;
    virtual bool containsPartsOfRelativeDir(const QString &testedDir) const = 0;

    virtual QSet<QString> knownRelativePaths() const
    {
        return {};
    }
};
} // anonymous namespace

struct BackupCategoryInfo {
    const SafeModeFixes::BackupCategory category;
    const QString localizedName;
    const QString origDirRoot;
    const QString backupSubDirName;
    std::unique_ptr<BackupCategoryFiles> files;

    QUrl backupSubDir(const QUrl &backupDir) const
    {
        return subPathUrl(backupDir, backupSubDirName);
    }
    bool isEntireDir() const
    {
        return files ? false : true;
    }
};

class BackupCategoryKnownFiles : public BackupCategoryFiles
{
public:
    BackupCategoryKnownFiles(const QSet<QString> &relativePaths)
        : m_relativePaths(relativePaths)
    {
    }

    bool containsRelativePath(const QString &testedRelativePath) const override
    {
        return m_relativePaths.contains(testedRelativePath);
    }

    bool containsPartsOfRelativeDir(const QString &testedRelativeDir) const override
    {
        if (m_relativePaths.contains(testedRelativeDir)) {
            return false; // this contains the entire directory, not just parts of it
        }
        return std::ranges::any_of(m_relativePaths, [testedRelativeDir](const QString &path) {
            return path.startsWith(testedRelativeDir) && path.at(testedRelativeDir.size()) == '/'_L1;
        });
    }

    QSet<QString> knownRelativePaths() const override
    {
        return m_relativePaths;
    }

private:
    QSet<QString> m_relativePaths;
};

class BackupCategoryRemainingFiles : public BackupCategoryFiles
{
public:
    BackupCategoryRemainingFiles(const BackupCategoryFiles *excludedFiles)
        : m_excludedFiles(excludedFiles)
    {
    }

    bool containsRelativePath(const QString &testedPath) const override
    {
        // If m_excludedFiles contains parts of the tested path (interpreted as a directory),
        // then we must also return false here, so we don't claim the entire directory.
        return !m_excludedFiles->containsRelativePath(testedPath) && !m_excludedFiles->containsPartsOfRelativeDir(testedPath);
    }

    bool containsPartsOfRelativeDir(const QString &testedDir) const override
    {
        // If m_excludedFiles encompasses the entire tested directory, containsRelativePath() will be true.
        // It returns false for partially claimed directories; we'll claim the remaining files in there.
        return !m_excludedFiles->containsRelativePath(testedDir);
    }

private:
    const BackupCategoryFiles *m_excludedFiles;
};

SafeModeFixes::SafeModeFixes(QObject *parent)
    : QObject(parent)
    , m_origDirWatch(new KDirWatch(this))
    , m_backupDirWatch(new KDirWatch(this))
{
    m_origDataDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_DATA_HOME"));
    m_origConfigDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME"));
    m_origStateDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_STATE_HOME"));
    m_origCacheDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_CACHE_HOME"));

    auto plasmaConfigPaths = std::make_unique<BackupCategoryKnownFiles>(makePlasmaConfigPaths());
    auto nonPlasmaConfigPaths = std::make_unique<BackupCategoryRemainingFiles>(plasmaConfigPaths.get());

    m_backupCategoryInfo.emplace_back(SafeModeFixes::BackupCategory::PlasmaConfig, //
                                      i18nc("name for backup category (in logs, etc.)", "Plasma Configuration"),
                                      m_origConfigDir,
                                      u"config-plasma"_s,
                                      std::move(plasmaConfigPaths));
    m_backupCategoryInfo.emplace_back(SafeModeFixes::BackupCategory::NonPlasmaConfig, //
                                      i18nc("name for backup category (in logs, etc.)", "App & Miscellaneous Configuration"),
                                      m_origConfigDir,
                                      u"config"_s,
                                      std::move(nonPlasmaConfigPaths));
    m_backupCategoryInfo.emplace_back(SafeModeFixes::BackupCategory::StateDir, //
                                      i18nc("name for backup category (in logs, etc.)", "State"),
                                      m_origStateDir,
                                      u"state"_s);
    m_backupCategoryInfo.emplace_back(SafeModeFixes::BackupCategory::DataDir, //
                                      i18nc("name for backup category (in logs, etc.)", "Desktop & Application Data"),
                                      m_origDataDir,
                                      u"data"_s);

    m_backupDir = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + "/Customizations Backup"_L1);

    // re-evaluate if directories already exist
    QObject::connect(this, &SafeModeFixes::backupDirChanged, this, &SafeModeFixes::preExistingBackupTargetPathsChanged);
    QObject::connect(this, &SafeModeFixes::selectedBackupCategoriesChanged, this, &SafeModeFixes::preExistingBackupTargetPathsChanged);
    QObject::connect(this, &SafeModeFixes::selectedRestoreCategoriesChanged, this, &SafeModeFixes::preExistingRestoreTargetPathsChanged);

    // watch the user's original XDG home directories (plus selected subdirectories)
    QObject::connect(m_origDirWatch, &KDirWatch::created, this, &SafeModeFixes::onOrigDirChanged);
    QObject::connect(m_origDirWatch, &KDirWatch::deleted, this, &SafeModeFixes::onOrigDirChanged);
    QObject::connect(m_origDirWatch, &KDirWatch::dirty, this, &SafeModeFixes::onOrigDirChanged);

    // inside the selected backup directory, watch directories for each backup category (plus selected subdirectories)
    QObject::connect(m_backupDirWatch, &KDirWatch::created, this, &SafeModeFixes::onBackupSubDirChanged);
    QObject::connect(m_backupDirWatch, &KDirWatch::deleted, this, &SafeModeFixes::onBackupSubDirChanged);
    QObject::connect(m_backupDirWatch, &KDirWatch::dirty, this, &SafeModeFixes::onBackupSubDirChanged);

    activateDirWatches();

    // set sensible selections based on available sources that were initialized by addDirWatches()
    m_selectedBackupCategories = m_availableBackupSources & BackupCategories{BackupCategory::PlasmaConfig, BackupCategory::StateDir};
    m_selectedRestoreCategories = m_availableRestoreSources;
}

SafeModeFixes::~SafeModeFixes()
{
}

QUrl SafeModeFixes::origCacheDir() const
{
    return m_origCacheDirExists ? QUrl() : QUrl::fromLocalFile(m_origCacheDir);
}

bool SafeModeFixes::origCacheDirExists() const
{
    return m_origCacheDirExists;
}

void SafeModeFixes::setBackupDir(const QUrl &dir)
{
    if (m_backupDir == dir) {
        return;
    }
    resetSuccessfulBackupCategories();
    resetSuccessfulRestoreCategories();

    suspendDirWatches();
    m_backupDir = dir;
    activateDirWatches();
    Q_EMIT backupDirChanged();
}

QUrl SafeModeFixes::backupDir() const
{
    return m_backupDir;
}

SafeModeFixes::BackupCategories SafeModeFixes::availableBackupSources() const
{
    return m_availableBackupSources;
}

SafeModeFixes::BackupCategories SafeModeFixes::availableRestoreSources() const
{
    return m_availableRestoreSources;
}

void SafeModeFixes::setSelectedBackupCategories(BackupCategories categories)
{
    if (m_selectedBackupCategories == categories) {
        return;
    }
    m_selectedBackupCategories = categories;
    Q_EMIT selectedBackupCategoriesChanged();
}

SafeModeFixes::BackupCategories SafeModeFixes::selectedBackupCategories() const
{
    return m_selectedBackupCategories;
}

SafeModeFixes::BackupCategories SafeModeFixes::successfulBackupCategories() const
{
    return m_successfulBackupCategories;
}

void SafeModeFixes::resetSuccessfulBackupCategories()
{
    resetUserLog();

    BackupCategories previous = m_successfulBackupCategories;
    m_successfulBackupCategories = BackupCategories{};

    if (previous.toInt() != 0) {
        Q_EMIT successfulBackupCategoriesChanged();
    }
}

void SafeModeFixes::setSelectedRestoreCategories(BackupCategories categories)
{
    if (m_selectedRestoreCategories == categories) {
        return;
    }
    m_selectedRestoreCategories = categories;
    Q_EMIT selectedRestoreCategoriesChanged();
}

SafeModeFixes::BackupCategories SafeModeFixes::selectedRestoreCategories() const
{
    return m_selectedRestoreCategories;
}

SafeModeFixes::BackupCategories SafeModeFixes::successfulRestoreCategories() const
{
    return m_successfulRestoreCategories;
}

void SafeModeFixes::resetSuccessfulRestoreCategories()
{
    resetUserLog();

    BackupCategories previous = m_successfulRestoreCategories;
    m_successfulRestoreCategories = BackupCategories{};

    if (previous.toInt() != 0) {
        Q_EMIT successfulRestoreCategoriesChanged();
    }
}

static QList<QUrl> intersectionAsUrls(const QSet<QString> &relativePathsA, const QSet<QString> &relativePathsB, const QUrl &rootDirForUrl)
{
    QList<QUrl> result;

    for (const QString &relativePathB : relativePathsB) {
        if (relativePathsA.contains(relativePathB)) {
            result.append(subPathUrl(rootDirForUrl, relativePathB));
        }
    }
    std::ranges::sort(result);
    return result;
}

QList<QUrl> SafeModeFixes::conflictingPathsForCategory(const BackupCategoryInfo &categoryInfo, const QUrl &categoryTargetDir) const
{
    if (!categoryTargetDir.isValid()) {
        return {};
    }

    if (categoryInfo.isEntireDir()) {
        return QFileInfo(categoryTargetDir.toLocalFile()).exists() ? QList<QUrl>{categoryTargetDir} : QList<QUrl>{};
    } else {
        return intersectionAsUrls(m_availableRestoreSourcePaths.value(categoryInfo.category),
                                  m_availableBackupSourcePaths.value(categoryInfo.category),
                                  categoryTargetDir);
    }
}

QList<QUrl> SafeModeFixes::preExistingBackupTargetPaths() const
{
    QList<QUrl> paths;
    for (const auto &info : m_backupCategoryInfo) {
        if (!m_selectedBackupCategories.testFlag(info.category)) {
            continue;
        }
        paths += conflictingPathsForCategory(info, info.backupSubDir(m_backupDir));
    }
    return paths;
}

QList<QUrl> SafeModeFixes::preExistingRestoreTargetPaths() const
{
    QList<QUrl> paths;
    for (const auto &info : m_backupCategoryInfo) {
        if (!m_selectedRestoreCategories.testFlag(info.category)) {
            continue;
        }
        paths += conflictingPathsForCategory(info, QUrl::fromLocalFile(info.origDirRoot));
    }
    return paths;
}

void SafeModeFixes::clearCache()
{
    if (m_origCacheDir.isEmpty()) {
        qCWarning(WELCOME_LOG) << "Didn't clear user cache dir (not in Safe Mode)";
        return;
    }
    auto job = KIO::del(QUrl::fromLocalFile(m_origCacheDir));
    job->start();
}

static void addMoveSubJob(SequentialCompositeJob *compositeJob, const QUrl &source, const QUrl &target)
{
    std::unique_ptr<KJob> moveJob(KIO::moveAs(source, target));

    QObject::connect(moveJob.get(), &KJob::infoMessage, compositeJob, &KJob::infoMessage);
    QObject::connect(moveJob.get(), &KJob::result, compositeJob, [compositeJob, sourcePath = source.path(), targetPath = target.path()](KJob *moveJob) {
        if (moveJob->error()) {
            compositeJob->setSubJobError(moveJob,
                                         i18nc("@info:status backup/restore log error - %1 and %2 are filesystem paths, %3 is the error message",
                                               "Could not move `%1` to `%2`: %3",
                                               sourcePath,
                                               targetPath,
                                               moveJob->errorString()));
        } else {
            Q_EMIT compositeJob->infoMessage(
                compositeJob,
                i18nc("@info:status successful backup/restore log - %1 and %2 are filesystem paths", "Moved `%1` to `%2`", sourcePath, targetPath));
        }
    });

    compositeJob->addSubjob(moveJob.release());
}

static void addMkpathSubJob(SequentialCompositeJob *compositeJob, const QUrl &dir, const QUrl &baseUrl = QUrl())
{
    std::unique_ptr<KJob> mkpathJob(KIO::mkpath(dir, baseUrl));

    QObject::connect(mkpathJob.get(), &KJob::infoMessage, compositeJob, &KJob::infoMessage);
    QObject::connect(mkpathJob.get(), &KJob::result, compositeJob, [compositeJob, path = dir.path()](KJob *mkpathJob) {
        if (mkpathJob->error()) {
            compositeJob->setSubJobError(mkpathJob,
                                         i18nc("@info:status backup/restore log error - %1 and %2 are filesystem paths, %3 is the error message",
                                               "Could not create `%1`: %3",
                                               path,
                                               mkpathJob->errorString()));
        } else {
            Q_EMIT compositeJob->infoMessage(compositeJob,
                                             i18nc("@info:status successful backup/restore log - %1 is a folder path", "Created directory `%1`", path));
        }
    });

    compositeJob->addSubjob(mkpathJob.release());
}

static std::unique_ptr<KJob> makeCategoryMoveJob(const BackupCategoryInfo &categoryInfo,
                                                 const QUrl &categorySourceRoot,
                                                 const QUrl &categoryTargetRoot,
                                                 const QUrl &baseUrl,
                                                 const QSet<QString> &relativeSourcePaths)
{
    auto compositeJob = std::make_unique<SequentialCompositeJob>();

    if (categoryInfo.isEntireDir()) {
        addMoveSubJob(compositeJob.get(), categorySourceRoot, categoryTargetRoot);
    } else {
        QSet<QString> createdDirs;

        for (const QString &relativePath : relativeSourcePaths) {
            const QUrl target = subPathUrl(categoryTargetRoot, relativePath);

            if (const QString targetParentDir = QFileInfo(target.toLocalFile()).path(); !createdDirs.contains(targetParentDir)) {
                addMkpathSubJob(compositeJob.get(), QUrl::fromLocalFile(targetParentDir), baseUrl);
                createdDirs.insert(targetParentDir);
            }
            addMoveSubJob(compositeJob.get(), subPathUrl(categorySourceRoot, relativePath), target);
        }
    }
    return compositeJob;
}

static QString formatPathsForLog(const QList<QUrl> &paths)
{
    if (paths.size() == 1) {
        return '`'_L1 + paths.first().path() + '`'_L1;
    }
    QString str;
    for (const QUrl &path : paths) {
        str += "\n  - `"_L1 + path.path() + '`'_L1;
    }
    return str;
}

bool SafeModeFixes::moveCustomizationsToBackupDir(KJob *previousJob)
{
    if (previousJob && previousJob->error()) {
        return false;
    }

    if (!m_backupDir.isLocalFile()) {
        qCWarning(WELCOME_LOG) << "Didn't move customization dirs - invalid backup directory:" << m_backupDir;
        return false;
    }

    QFileInfo backupDirInfo(m_backupDir.toLocalFile());
    if (!backupDirInfo.exists()) {
        auto createBackupDirJob = KIO::mkpath(m_backupDir);
        QObject::connect(createBackupDirJob, &KJob::result, this, &SafeModeFixes::moveCustomizationsToBackupDir);
        createBackupDirJob->start();
        return true;
    } else if (!backupDirInfo.isDir()) {
        qCWarning(WELCOME_LOG) << "Didn't move customization dirs - backup directory exists but is not a directory:" << m_backupDir;
        return false;
    }
    QDir backupDir(backupDirInfo.filePath());

    resetUserLog(backupDir.filePath(QDateTime::currentDateTime().toString(u"yyyy-MM-dd hhmm.ss 'Customizations Backup Log.txt'")));

    userLog(MessageType::Intention,
            i18nc("@info:status restore log - %1 is a folder path", "Resetting customizations and creating backup in `%1`", backupDir.path()));
    userLog(MessageType::CosmeticSpacing, "=====\n"_L1);

    auto compositeJob = std::make_unique<SequentialCompositeJob>();
    compositeJob->setAbortOnError(false);

    for (const auto &info : m_backupCategoryInfo) {
        if (!m_selectedBackupCategories.testFlag(info.category)) {
            continue;
        }
        const QUrl sourceDir = QUrl::fromLocalFile(info.origDirRoot);
        const QUrl targetDir = info.backupSubDir(m_backupDir);
        const QString targetDirPath = targetDir.toLocalFile();
        const auto relativeSourcePaths = m_availableBackupSourcePaths.value(info.category);

        userLog(
            MessageType::Intention,
            i18nc("@info:status backup log - %1 is a backup category, %2 is a folder path", "%1: Backing up files to `%2`", info.localizedName, targetDirPath));

        if (relativeSourcePaths.isEmpty()) {
            userLog(MessageType::Error,
                    i18nc("@info:status backup log error - %1 is a backup category, %2 is a folder path",
                          "%1: Didn't move customization dirs - no customization files found in `%2`",
                          info.localizedName,
                          info.origDirRoot));
            return false;
        }
        if (const auto conflictingPaths = conflictingPathsForCategory(info, targetDir); !conflictingPaths.isEmpty()) {
            userLog(MessageType::Error,
                    i18nc("@info:status backup log error - %1 is a backup category, %2 is a folder path or a collection of files",
                          "%1: Didn't move customization dirs - target backup files already exist: %2",
                          info.localizedName,
                          formatPathsForLog(conflictingPaths)));
            return false;
        }
        std::unique_ptr<KJob> categoryJob = makeCategoryMoveJob(info, sourceDir, targetDir, m_backupDir, relativeSourcePaths);

        QObject::connect(categoryJob.get(), &KJob::infoMessage, this, [this, name = info.localizedName](KJob *, const QString &message) {
            userLog(MessageType::Intention,
                    i18nc("@info:status backup/restore log - %1 is backup category, %2 is an info message from the move job", "%1: %2", name, message));
        });
        QObject::connect(categoryJob.get(), &KJob::warning, this, [this, name = info.localizedName](KJob *, const QString &message) {
            userLog(MessageType::Warning,
                    i18nc("@info:status backup/restore log - %1 is backup category, %2 is an info message from the move job", "%1: %2", name, message));
        });
        QObject::connect(categoryJob.get(), &KJob::result, this, [this, category = info.category, name = info.localizedName, targetDirPath](KJob *categoryJob) {
            if (categoryJob->error()) {
                userLog(MessageType::Error,
                        i18nc("@info:status backup/restore log error - %1 is the category name, %2 is a folder path, %3 is the error message",
                              "%1: Error moving files into `%2`: %3",
                              name,
                              targetDirPath,
                              categoryJob->errorString()));
            } else {
                userLog(MessageType::Progress,
                        i18nc("@info:status successful backup/restore log - %1 is the category name, %2 is a folder path",
                              "%1: Successfully reset and backed up into `%2`",
                              name,
                              targetDirPath));
                userLog(MessageType::CosmeticSpacing, ""_L1);

                m_successfulBackupCategories |= category;
                Q_EMIT successfulBackupCategoriesChanged();

                // Also pre-select it for restoring this backup, in case the user wants to move it right back.
                m_selectedRestoreCategories |= category;
                Q_EMIT selectedRestoreCategoriesChanged();
            }
        });
        compositeJob->addSubjob(categoryJob.release());
    }

    userLog(MessageType::CosmeticSpacing, ""_L1);

    QObject::connect(compositeJob.get(), &KJob::result, this, [this](KJob *job) {
        if (job->error()) {
            userLog(MessageType::Error, i18nc("@info:status backup log", "Errors encountered while backing up customizations, see above."));
        } else {
            userLog(MessageType::Progress, i18nc("@info:status backup log", "Customizations were successfully backed up."));
        }
        activateDirWatches();
    });
    suspendDirWatches();
    compositeJob->start();
    compositeJob.release(); // asynchronous, self-deleting KIO jobs

    return true;
}

bool SafeModeFixes::restoreCustomizationsFromBackupDir()
{
    if (!m_backupDir.isLocalFile()) {
        qCWarning(WELCOME_LOG) << "Didn't restore customization dirs - invalid backup directory:" << m_backupDir;
        return false;
    }

    QDir backupDir(m_backupDir.toLocalFile());
    if (!backupDir.exists()) {
        qCWarning(WELCOME_LOG) << "Didn't restore customization dirs - backup directory is not a directory:" << m_backupDir;
        return false;
    }

    resetUserLog(backupDir.filePath(QDateTime::currentDateTime().toString(u"yyyy-MM-dd hh.mm.ss 'Customizations Restore Log.txt'")));

    userLog(MessageType::Intention, i18nc("@info:status restore log - %1 is a folder path", "Restoring customizations backup from `%1`", backupDir.path()));
    userLog(MessageType::CosmeticSpacing, "=====\n"_L1);

    auto compositeJob = std::make_unique<SequentialCompositeJob>();
    compositeJob->setAbortOnError(false);

    for (const auto &info : m_backupCategoryInfo) {
        if (!m_selectedRestoreCategories.testFlag(info.category)) {
            continue;
        }
        const QUrl sourceDir = info.backupSubDir(m_backupDir);
        const QString sourceDirPath = sourceDir.toLocalFile();
        const QUrl targetDir = QUrl::fromLocalFile(info.origDirRoot);
        const auto relativeSourcePaths = m_availableRestoreSourcePaths.value(info.category);

        userLog(MessageType::Intention,
                i18nc("@info:status restore log - %1 is a backup category, %2 is a folder path",
                      "%1: Restoring backup files from `%2`",
                      info.localizedName,
                      sourceDirPath));

        if (relativeSourcePaths.isEmpty()) {
            userLog(MessageType::Error,
                    i18nc("@info:status backup log error - %1 is backup category, %2 is a folder path",
                          "%1: Didn't restore customization dirs - no backup files found in `%2`",
                          info.localizedName,
                          sourceDirPath));
            return false;
        }
        if (const auto conflictingPaths = conflictingPathsForCategory(info, info.origDirRoot); !conflictingPaths.isEmpty()) {
            userLog(MessageType::Error,
                    i18nc("@info:status backup log error - %1 is backup category, %2 is a folder path or a collection of files",
                          "%1: Didn't restore customization dirs - target customization files already exist: %2",
                          info.localizedName,
                          formatPathsForLog(conflictingPaths)));
            return false;
        }
        std::unique_ptr<KJob> categoryJob = makeCategoryMoveJob(info, sourceDir, targetDir, QUrl(), relativeSourcePaths);

        QObject::connect(categoryJob.get(), &KJob::infoMessage, this, [this, name = info.localizedName](KJob *, const QString &message) {
            userLog(MessageType::Intention,
                    i18nc("@info:status backup/restore log - %1 is backup category, %2 is an info message from the move job", "%1: %2", name, message));
        });
        QObject::connect(categoryJob.get(), &KJob::warning, this, [this, name = info.localizedName](KJob *, const QString &message) {
            userLog(MessageType::Warning,
                    i18nc("@info:status backup/restore log - %1 is backup category, %2 is an info message from the move job", "%1: %2", name, message));
        });
        QObject::connect(categoryJob.get(), &KJob::result, this, [this, category = info.category, name = info.localizedName, sourceDirPath](KJob *categoryJob) {
            if (categoryJob->error()) {
                userLog(MessageType::Error,
                        i18nc("@info:status backup/restore log error - %1 is the category name, %2 is a folder path, %3 is the error message",
                              "%1: Error moving files from `%2`: %3",
                              name,
                              sourceDirPath,
                              categoryJob->errorString()));
            } else {
                userLog(MessageType::Progress,
                        i18nc("@info:status successful backup/restore log - %1 is the category name, %2 is a folder path",
                              "%1: Successfully restored from `%2`",
                              name,
                              sourceDirPath));
                userLog(MessageType::CosmeticSpacing, ""_L1);

                m_successfulRestoreCategories |= category;
                Q_EMIT successfulRestoreCategoriesChanged();

                // Also pre-select it for backup, in case the user wants to back it up again right away.
                m_selectedBackupCategories |= category;
                Q_EMIT selectedBackupCategoriesChanged();
            }
        });
        compositeJob->addSubjob(categoryJob.release());
    }

    userLog(MessageType::CosmeticSpacing, ""_L1);

    QObject::connect(compositeJob.get(), &KJob::result, this, [this](KJob *job) {
        if (job->error()) {
            userLog(MessageType::Error, i18nc("@info:status restore log", "Errors encountered while restoring customizations, see above."));
        } else {
            userLog(MessageType::Progress, i18nc("@info:status restore log", "Customizations were successfully restored."));
        }
        activateDirWatches();
    });
    suspendDirWatches();
    compositeJob->start();
    compositeJob.release(); // asynchronous, self-deleting KIO jobs

    return true;
}

void SafeModeFixes::userLog(MessageType msgType, const QString &msg)
{
    if (m_userLogFile.isOpen()) {
        QTextStream out(&m_userLogFile);

        if (msgType == MessageType::Error) {
            out << "🗙 ";
        } else if (msgType == MessageType::Warning) {
            out << "❗ ";
        } else if (msgType == MessageType::Progress) {
            out << "✓ ";
        }

        out << msg << "\n";

        if (msgType == MessageType::Error) {
            qCCritical(WELCOME_LOG) << msg;
            if (!m_hasUserLogError) {
                m_hasUserLogError = true;
                Q_EMIT userLogErrorChanged();
            }
        } else if (msgType != MessageType::CosmeticSpacing) {
            qCInfo(WELCOME_LOG) << msg;
        }
    }
}

void SafeModeFixes::resetUserLog(const QString &filepath)
{
    if (m_hasUserLogError) {
        m_hasUserLogError = false;
        Q_EMIT userLogErrorChanged();
    }

    if (m_userLogFile.isOpen()) {
        m_userLogFile.close();
    }

    if (!filepath.isEmpty()) {
        m_userLogFile.setFileName(filepath);

        if (!m_userLogFile.open(QIODeviceBase::Append | QIODevice::Text)) {
            m_hasUserLogError = true;
            Q_EMIT userLogErrorChanged();
            return;
        }
    }
}

bool SafeModeFixes::hasUserLogError() const
{
    return m_hasUserLogError;
}

void SafeModeFixes::openUserLog()
{
    auto job = new KIO::OpenUrlJob(QUrl::fromLocalFile(m_userLogFile.fileName()));
    QObject::connect(job, &KJob::result, this, [this](KJob *openJob) {
        if (openJob->error()) {
            qCWarning(WELCOME_LOG) << openJob->errorString();
        }
    });
    job->start();
}

void SafeModeFixes::openBackupDir()
{
    auto job = new KIO::OpenUrlJob(m_backupDir);
    QObject::connect(job, &KJob::result, this, [this](KJob *openJob) {
        if (openJob->error()) {
            qCWarning(WELCOME_LOG) << openJob->errorString();
        }
    });
    job->start();
}

void SafeModeFixes::logOut()
{
    static SessionManagement *sessionManagement = new SessionManagement();
    sessionManagement->requestLogout(SessionManagement::ConfirmationMode::Skip);
}

static void collectWatchDirsForSource(const BackupCategoryInfo &info, const QString &categorySourceDir, QSet<QString> &watchDirs)
{
    if (categorySourceDir.isEmpty()) {
        return;
    }

    if (info.isEntireDir() || info.files->knownRelativePaths().isEmpty()) {
        watchDirs.insert(categorySourceDir);
    } else {
        for (const QString &relPath : info.files->knownRelativePaths()) {
            const QString absolutePath = subPath(categorySourceDir, relPath);
            watchDirs.insert(QFileInfo(absolutePath).path());
        }
    }
}

static void collectWatchDirsForTarget(const BackupCategoryInfo &info,
                                      const QString &categoryTargetDir,
                                      QSet<QString> &targetWatchDirs,
                                      const QString &categorySourceDir,
                                      QSet<QString> &sourceWatchDirs)
{
    using F = QDirListing::IteratorFlag;

    if (categoryTargetDir.isEmpty()) {
        return;
    }

    targetWatchDirs.insert(categoryTargetDir);

    if (info.isEntireDir()) {
        return;
    }

    // We want to detect when a source file can't be moved due to the corresponding target path already existing.
    // Watch directories that exist inside the target directory and *may* include files on the source side.
    QStringList recursedDirs{categoryTargetDir};
    QStringList nextRecursedDirs;

    while (!recursedDirs.isEmpty()) {
        nextRecursedDirs.clear();

        for (const auto &dir : recursedDirs) {
            for (const QDirListing::DirEntry &entry : QDirListing(dir, F::DirsOnly | F::IncludeHidden)) {
                const QString relativeDir = QDir(categoryTargetDir).relativeFilePath(entry.filePath());

                if (info.files->containsPartsOfRelativeDir(relativeDir)) {
                    targetWatchDirs.insert(entry.filePath());
                    nextRecursedDirs.append(entry.filePath());

                    if (!categorySourceDir.isEmpty()) {
                        const QString correspondingSourcePath = subPath(categorySourceDir, relativeDir);
                        sourceWatchDirs.insert(correspondingSourcePath);
                    }
                }
            }
        }
        recursedDirs = nextRecursedDirs;
    }
}

void SafeModeFixes::activateDirWatches()
{
    m_origDirWatch->addDir(m_origCacheDir);

    QSet<QString> origDirWatches;
    QSet<QString> backupSubDirWatches;

    for (const auto &info : m_backupCategoryInfo) {
        QString backupSubDir = info.backupSubDir(m_backupDir).toLocalFile();

        collectWatchDirsForSource(info, info.origDirRoot, origDirWatches);
        collectWatchDirsForTarget(info, backupSubDir, backupSubDirWatches, info.origDirRoot, origDirWatches);
        collectWatchDirsForSource(info, backupSubDir, backupSubDirWatches);
        collectWatchDirsForTarget(info, info.origDirRoot, origDirWatches, backupSubDir, backupSubDirWatches);
    }

    m_origDirWatches = origDirWatches;
    for (const QString &dir : m_origDirWatches) {
        m_origDirWatch->addDir(dir);
    }

    m_backupDirWatches = backupSubDirWatches;
    for (const QString &dir : m_backupDirWatches) {
        m_backupDirWatch->addDir(dir);
    }

    updateOrigCacheDirExists();
    updateAvailableBackupSources();
    updateAvailableRestoreSources();
}

void SafeModeFixes::suspendDirWatches()
{
    m_origDirWatch->removeDir(m_origCacheDir);

    for (const auto &dir : m_origDirWatches) {
        m_origDirWatch->removeDir(dir);
    }
    m_origDirWatches.clear();

    for (const auto &dir : m_backupDirWatches) {
        m_backupDirWatch->removeDir(dir);
    }
    m_backupDirWatches.clear();
}

void SafeModeFixes::onOrigDirChanged(const QString &path)
{
    if (path == m_origCacheDir) {
        updateOrigCacheDirExists();
    } else {
        updateAvailableBackupSources();
    }
}

void SafeModeFixes::onBackupSubDirChanged(const QString &path)
{
    Q_UNUSED(path);
    updateAvailableRestoreSources();
}

void SafeModeFixes::updateOrigCacheDirExists()
{
    bool exists = QDir(m_origCacheDir).exists();
    if (m_origCacheDirExists != exists) {
        m_origCacheDirExists = exists;
        Q_EMIT origCacheDirExistsChanged();
    }
}

static QSet<QString> existingSourcePathsIn(const QString &categorySourceDir, const BackupCategoryInfo &categoryInfo)
{
    if (categoryInfo.isEntireDir()) {
        return {};
    }

    Q_ASSERT(categoryInfo.files != nullptr);

    using F = QDirListing::IteratorFlag;
    const QDirListing::IteratorFlags flags = F::Recursive | F::IncludeHidden | F::IncludeBrokenSymlinks | F::ExcludeOther;

    QSet<QString> sourcePaths;
    for (const QDirListing::DirEntry &entry : QDirListing(categorySourceDir, flags)) {
        QString relativePath = QDir(categorySourceDir).relativeFilePath(entry.filePath());
        if (categoryInfo.files->containsRelativePath(relativePath)) {
            sourcePaths.insert(relativePath);
        }
    }
    return sourcePaths;
}

void SafeModeFixes::updateAvailableBackupSources()
{
    bool changed = false;

    for (const auto &info : m_backupCategoryInfo) {
        bool hasSources = false;

        if (info.isEntireDir()) {
            hasSources = QDir(info.origDirRoot).exists();
            m_availableBackupSourcePaths[info.category] = hasSources ? QSet<QString>{"."_L1} : QSet<QString>{};
        } else {
            const auto sourcePaths = existingSourcePathsIn(info.origDirRoot, info);
            hasSources = !sourcePaths.isEmpty();
            m_availableBackupSourcePaths[info.category] = sourcePaths;
        }

        if (m_availableBackupSources.testFlag(info.category) != hasSources) {
            m_availableBackupSources.setFlag(info.category, hasSources);
            changed = true;
        }
    }

    if (changed) {
        Q_EMIT availableBackupSourcesChanged();
        Q_EMIT preExistingRestoreTargetPathsChanged(); // TODO: does this also get updated if only the target path has changed?
    }
}

void SafeModeFixes::updateAvailableRestoreSources()
{
    bool changed = false;

    for (const auto &info : m_backupCategoryInfo) {
        bool hasSources = false;
        const QUrl backupSubDir = info.backupSubDir(m_backupDir);

        if (info.isEntireDir()) {
            hasSources = backupSubDir.isValid() && QDir(backupSubDir.toLocalFile()).exists();
            m_availableRestoreSourcePaths[info.category] = hasSources ? QSet<QString>{"."_L1} : QSet<QString>{};
        } else {
            const auto sourcePaths = existingSourcePathsIn(backupSubDir.toLocalFile(), info);
            hasSources = !sourcePaths.isEmpty();
            m_availableRestoreSourcePaths[info.category] = sourcePaths;
        }

        if (m_availableRestoreSources.testFlag(info.category) != hasSources) {
            m_availableRestoreSources.setFlag(info.category, hasSources);
            changed = true;
        }
    }

    if (changed) {
        Q_EMIT availableRestoreSourcesChanged();
        Q_EMIT preExistingBackupTargetPathsChanged();
    }
}

#include "moc_safemodefixes.cpp"
#include "safemodefixes.moc" // SequentialCompositeJob
