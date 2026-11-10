/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "safemodebackuprestore.h"

#include <KCompositeJob>
#include <KDirWatch>
#include <KIO/CopyJob>
#include <KIO/DeleteJob>
#include <KIO/MkpathJob>
#include <KIO/OpenFileManagerWindowJob>
#include <KIO/OpenUrlJob>
#include <KJob>
#include <KLocalizedString>

#include <QDateTime>
#include <QDir>
#include <QDirListing>
#include <QFileInfo>
#include <QTextStream>
#include <QtAssert>

#include <algorithm>

#include "welcome_debug.h"

using namespace Qt::StringLiterals;
using namespace SafeModeBackup;

namespace
{
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
} // anonymous namespace

SafeModeBackupRestore::SafeModeBackupRestore(const QString &homeDir, QObject *parent)
    : QObject(parent)
    , m_backupDir(homeDir.isEmpty() ? QUrl() : QUrl::fromLocalFile(homeDir + "/Customizations Backup"_L1))
    , m_categoryInfo(SafeModeBackup::makeCategoryInfo())
    , m_backupCategories(new CategoryModel(m_categoryInfo, Operation::Backup, this))
    , m_restoreCategories(new CategoryModel(m_categoryInfo, Operation::Restore, this))
    , m_origDirWatch(new KDirWatch(this))
    , m_backupDirWatch(new KDirWatch(this))
{
    updateBackupCategoryRoots();

    // watch the user's original XDG home directories (plus selected subdirectories)
    QObject::connect(m_origDirWatch, &KDirWatch::created, this, &SafeModeBackupRestore::updateAvailableCategories);
    QObject::connect(m_origDirWatch, &KDirWatch::deleted, this, &SafeModeBackupRestore::updateAvailableCategories);
    QObject::connect(m_origDirWatch, &KDirWatch::dirty, this, &SafeModeBackupRestore::updateAvailableCategories);

    // inside the selected backup directory, watch directories for each backup category (plus selected subdirectories)
    QObject::connect(m_backupDirWatch, &KDirWatch::created, this, &SafeModeBackupRestore::updateAvailableCategories);
    QObject::connect(m_backupDirWatch, &KDirWatch::deleted, this, &SafeModeBackupRestore::updateAvailableCategories);
    QObject::connect(m_backupDirWatch, &KDirWatch::dirty, this, &SafeModeBackupRestore::updateAvailableCategories);

    activateDirWatches();

    // set sensible selections based on available sources that were initialized by activateDirWatches()
    m_backupCategories->selectDefaultCategories();
    m_restoreCategories->selectDefaultCategories();
}

SafeModeBackupRestore::~SafeModeBackupRestore()
{
}

void SafeModeBackupRestore::setBackupDir(const QUrl &dir)
{
    if (m_backupDir == dir) {
        return;
    }
    resetSuccessfulBackupCategories();
    resetSuccessfulRestoreCategories();

    suspendDirWatches();
    m_backupDir = dir;
    updateBackupCategoryRoots();
    activateDirWatches();
    Q_EMIT backupDirChanged();
}

QUrl SafeModeBackupRestore::backupDir() const
{
    return m_backupDir;
}

void SafeModeBackupRestore::updateBackupCategoryRoots()
{
    for (auto &info : m_categoryInfo) {
        info.backupCategoryRoot = m_backupDir.isLocalFile() ? subPath(m_backupDir.toLocalFile(), info.backupSubDirName) : QString();
    }
}

CategoryModel *SafeModeBackupRestore::backupCategories() const
{
    return m_backupCategories;
}

CategoryModel *SafeModeBackupRestore::restoreCategories() const
{
    return m_restoreCategories;
}

void SafeModeBackupRestore::resetSuccessfulBackupCategories()
{
    resetUserLog();
    m_backupCategories->resetSuccessful();
}

void SafeModeBackupRestore::resetSuccessfulRestoreCategories()
{
    resetUserLog();
    m_restoreCategories->resetSuccessful();
}

QList<QUrl> SafeModeBackupRestore::conflictingPathsForCategory(const CategoryInfo &categoryInfo, const QUrl &categoryTargetDir) const
{
    if (!categoryTargetDir.isValid()) {
        return {};
    }

    const auto intersectionAsUrls = [](const QSet<QString> &relativePathsA, const QSet<QString> &relativePathsB, const QUrl &rootDirForUrl) -> QList<QUrl> {
        QList<QUrl> result;
        for (const QString &relativePathB : relativePathsB) {
            if (relativePathsA.contains(relativePathB)) {
                result.append(subPathUrl(rootDirForUrl, relativePathB));
            }
        }
        std::ranges::sort(result);
        return result;
    };

    if (categoryInfo.isEntireDir()) {
        return QFileInfo(categoryTargetDir.toLocalFile()).exists() ? QList<QUrl>{categoryTargetDir} : QList<QUrl>{};
    } else {
        return intersectionAsUrls(m_availableRestoreSourcePaths.value(categoryInfo.category),
                                  m_availableBackupSourcePaths.value(categoryInfo.category),
                                  categoryTargetDir);
    }
}

void SafeModeBackupRestore::updateConflicts()
{
    for (const auto &info : m_categoryInfo) {
        m_backupCategories->setConflictingPaths(info.category, conflictingPathsForCategory(info, QUrl::fromLocalFile(info.backupCategoryRoot)));
        m_restoreCategories->setConflictingPaths(info.category, conflictingPathsForCategory(info, QUrl::fromLocalFile(info.origDirRoot)));
    }
}

void SafeModeBackupRestore::updateAvailableCategories()
{
    for (const auto &info : m_categoryInfo) {
        auto &sources = m_availableBackupSourcePaths[info.category];
        sources = info.existingSourcePaths(info.origDirRoot);
        m_backupCategories->setAvailable(info.category, !sources.isEmpty());
    }

    for (const auto &info : m_categoryInfo) {
        auto &sources = m_availableRestoreSourcePaths[info.category];
        sources = info.existingSourcePaths(info.backupCategoryRoot);
        m_restoreCategories->setAvailable(info.category, !sources.isEmpty());
    }

    updateConflicts();
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
                                         i18nc("@info:status backup/restore log error - %1 is a filesystem path, %2 is the error message",
                                               "Could not create `%1`: %2",
                                               path,
                                               mkpathJob->errorString()));
        } else {
            Q_EMIT compositeJob->infoMessage(compositeJob,
                                             i18nc("@info:status successful backup/restore log - %1 is a folder path", "Created directory `%1`", path));
        }
    });

    compositeJob->addSubjob(mkpathJob.release());
}

static std::unique_ptr<KJob> makeCategoryMoveJob(const CategoryInfo &categoryInfo,
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

static void addParentDirs(const QString &sourceRoot, const QString &relativePath, QSet<QString> &dirs)
{
    if (sourceRoot.isEmpty()) {
        return;
    }
    dirs.insert(sourceRoot);

    QString relativeDir = QFileInfo(relativePath).path();
    while (!relativeDir.isEmpty() && relativeDir != u"."_s) {
        const QString absoluteDir = subPath(sourceRoot, relativeDir);
        if (dirs.contains(absoluteDir)) {
            // This directory and all of its ancestors are already queued.
            break;
        }
        dirs.insert(absoluteDir);
        relativeDir = QFileInfo(relativeDir).path();
    }
}

bool SafeModeBackupRestore::checkValidFilesForCategory(const CategoryInfo &categoryInfo,
                                                       const QSet<QString> &relativeSourcePaths,
                                                       const QUrl &sourceDir,
                                                       const QUrl &targetDir)
{
    const auto formatPathsForLog = [](const QList<QUrl> &paths) -> QString {
        if (paths.size() == 1) {
            return '`'_L1 + paths.first().path() + '`'_L1;
        }
        QString str;
        for (const QUrl &path : paths) {
            str += "\n  - `"_L1 + path.path() + '`'_L1;
        }
        return str;
    };

    if (relativeSourcePaths.isEmpty()) {
        userLog(MessageType::Error,
                i18nc("@info:status backup log error - %1 is a backup category, %2 is a folder path",
                      "%1: Aborting - no source files found in `%2`",
                      categoryInfo.logTitle(),
                      sourceDir.toLocalFile()));
        return false;
    }
    if (const auto conflictingPaths = conflictingPathsForCategory(categoryInfo, targetDir); !conflictingPaths.isEmpty()) {
        userLog(MessageType::Error,
                i18nc("@info:status backup log error - %1 is a backup category, %2 is a folder path or a collection of files",
                      "%1: Aborting - target backup files already exist: %2",
                      categoryInfo.logTitle(),
                      formatPathsForLog(conflictingPaths)));
        return false;
    }
    return true;
}

bool SafeModeBackupRestore::moveCustomizationsToBackupDir(KJob *previousJob)
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
        QObject::connect(createBackupDirJob, &KJob::result, this, &SafeModeBackupRestore::moveCustomizationsToBackupDir);
        createBackupDirJob->start();
        return true;
    } else if (!backupDirInfo.isDir()) {
        qCWarning(WELCOME_LOG) << "Didn't move customization dirs - backup directory exists but is not a directory:" << m_backupDir;
        return false;
    }
    updateAvailableCategories();

    QDir backupDir(backupDirInfo.filePath());

    resetUserLog(backupDir.filePath(QDateTime::currentDateTime().toString(u"yyyy-MM-dd hhmm.ss 'Customizations Backup Log.txt'")));

    userLog(MessageType::Intention,
            i18nc("@info:status restore log - %1 is a folder path", "Resetting customizations and creating backup in `%1`", backupDir.path()));
    userLog(MessageType::CosmeticSpacing, "=====\n"_L1);

    auto compositeJob = std::make_unique<SequentialCompositeJob>();
    compositeJob->setAbortOnError(false);

    for (const auto &info : m_categoryInfo) {
        if (!m_backupCategories->isSelected(info.category)) {
            continue;
        }
        const QUrl sourceDir = QUrl::fromLocalFile(info.origDirRoot);
        const QString targetDirPath = info.backupCategoryRoot;
        const QUrl targetDir = QUrl::fromLocalFile(targetDirPath);
        const auto relativeSourcePaths = m_availableBackupSourcePaths.value(info.category);

        userLog(
            MessageType::Intention,
            i18nc("@info:status backup log - %1 is a backup category, %2 is a folder path", "%1: Backing up files to `%2`", info.logTitle(), targetDirPath));

        if (!checkValidFilesForCategory(info, relativeSourcePaths, sourceDir, targetDir)) {
            return false;
        }
        std::unique_ptr<KJob> categoryJob = makeCategoryMoveJob(info, sourceDir, targetDir, m_backupDir, relativeSourcePaths);

        QObject::connect(categoryJob.get(), &KJob::result, this, [this, category = info.category](KJob *categoryJob) {
            if (!categoryJob->error()) {
                m_backupCategories->setSuccessful(category, true);

                // Pre-select for restoring, in case the user wants to move it back right away.
                m_restoreCategories->setAvailable(category, true);
                m_restoreCategories->setSelected(category, true);
            }
        });
        connectJobUpdatesToUserLog(categoryJob.get(), Operation::Backup, info.logTitle(), targetDirPath);
        compositeJob->addSubjob(categoryJob.release());
    }

    userLog(MessageType::CosmeticSpacing, ""_L1);
    startOperation(std::move(compositeJob), Operation::Backup);
    return true;
}

bool SafeModeBackupRestore::restoreCustomizationsFromBackupDir()
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
    updateAvailableCategories();

    resetUserLog(backupDir.filePath(QDateTime::currentDateTime().toString(u"yyyy-MM-dd hhmm.ss 'Customizations Restore Log.txt'")));

    userLog(MessageType::Intention, i18nc("@info:status restore log - %1 is a folder path", "Restoring customizations backup from `%1`", backupDir.path()));
    userLog(MessageType::CosmeticSpacing, "=====\n"_L1);

    auto compositeJob = std::make_unique<SequentialCompositeJob>();
    compositeJob->setAbortOnError(false);

    // Only for the restore operation: Remove empty backup subdirs after moving files back to original dir(s)
    QSet<QString> sourceDirsToPrune;

    for (const auto &info : m_categoryInfo) {
        if (!m_restoreCategories->isSelected(info.category)) {
            continue;
        }
        const QString sourceDirPath = info.backupCategoryRoot;
        const QUrl sourceDir = QUrl::fromLocalFile(sourceDirPath);
        const QUrl targetDir = QUrl::fromLocalFile(info.origDirRoot);
        const auto relativeSourcePaths = m_availableRestoreSourcePaths.value(info.category);

        userLog(MessageType::Intention,
                i18nc("@info:status restore log - %1 is a backup category, %2 is a folder path",
                      "%1: Restoring backup files from `%2`",
                      info.logTitle(),
                      sourceDirPath));

        if (!checkValidFilesForCategory(info, relativeSourcePaths, sourceDir, targetDir)) {
            return false;
        }

        if (!info.isEntireDir()) {
            for (const QString &relativePath : relativeSourcePaths) {
                addParentDirs(info.backupCategoryRoot, relativePath, sourceDirsToPrune);
            }
        }

        std::unique_ptr<KJob> categoryJob = makeCategoryMoveJob(info, sourceDir, targetDir, QUrl(), relativeSourcePaths);

        QObject::connect(categoryJob.get(), &KJob::result, this, [this, category = info.category](KJob *categoryJob) {
            if (!categoryJob->error()) {
                m_restoreCategories->setSuccessful(category, true);

                // Pre-select for backup, in case the user wants to back it up again right away.
                m_backupCategories->setAvailable(category, true);
                m_backupCategories->setSelected(category, true);
            }
        });
        connectJobUpdatesToUserLog(categoryJob.get(), Operation::Restore, info.logTitle(), sourceDirPath);
        compositeJob->addSubjob(categoryJob.release());
    }

    if (!sourceDirsToPrune.isEmpty()) {
        QList<QString> dirsToPrune = sourceDirsToPrune.values();
        // Children sort after their parents, so remove in reverse order.
        std::ranges::sort(dirsToPrune);

        QObject::connect(compositeJob.get(), &KJob::result, this, [dirsToPrune] {
            for (auto it = dirsToPrune.crbegin(); it != dirsToPrune.crend(); ++it) {
                QDir().rmdir(*it);
            }
        });
    }

    userLog(MessageType::CosmeticSpacing, ""_L1);
    startOperation(std::move(compositeJob), Operation::Restore);
    return true;
}

void SafeModeBackupRestore::connectJobUpdatesToUserLog(KJob *job, Operation operation, const QString &categoryTitle, const QString &categoryBackupRoot)
{
    QObject::connect(job, &KJob::infoMessage, this, [this, categoryTitle](KJob *, const QString &message) {
        userLog(MessageType::Intention,
                i18nc("@info:status backup/restore log - %1 is a backup category, %2 is an info message from the move job", "%1: %2", categoryTitle, message));
    });
    QObject::connect(job, &KJob::warning, this, [this, categoryTitle](KJob *, const QString &message) {
        userLog(MessageType::Warning,
                i18nc("@info:status backup/restore log - %1 is a backup category, %2 is an info message from the move job", "%1: %2", categoryTitle, message));
    });
    QObject::connect(job, &KJob::result, this, [this, operation, categoryTitle, categoryBackupRoot](KJob *categoryJob) {
        if (categoryJob->error()) {
            userLog(MessageType::Error,
                    i18nc("@info:status backup/restore log error - %1 is a backup category, %2 is a folder path, %3 is the error message",
                          "%1: Error moving files into `%2`: %3",
                          categoryTitle,
                          categoryBackupRoot,
                          categoryJob->errorString()));
            return;
        }
        switch (operation) {
        case Operation::Backup:
            userLog(MessageType::Progress,
                    i18nc("@info:status successful backup/restore log - %1 is a backup category, %2 is a folder path",
                          "%1: Successfully reset and backed up into `%2`",
                          categoryTitle,
                          categoryBackupRoot));
            break;
        case Operation::Restore:
            userLog(MessageType::Progress,
                    i18nc("@info:status successful backup/restore log - %1 is a backup category, %2 is a folder path",
                          "%1: Successfully restored from `%2`",
                          categoryTitle,
                          categoryBackupRoot));
            break;
        }
        userLog(MessageType::CosmeticSpacing, ""_L1);
    });
}

void SafeModeBackupRestore::startOperation(std::unique_ptr<KJob> job, Operation operation)
{
    Q_ASSERT(operation == Operation::Backup || operation == Operation::Restore);

    QObject::connect(job.get(), &KJob::result, this, [this, operation](KJob *finishedJob) {
        const bool isBackup = operation == Operation::Backup;
        if (finishedJob->error()) {
            userLog(MessageType::Error,
                    isBackup ? i18nc("@info:status backup log", "Errors encountered while backing up customizations, see above.")
                             : i18nc("@info:status restore log", "Errors encountered while restoring customizations, see above."));
        } else {
            userLog(MessageType::Progress,
                    isBackup ? i18nc("@info:status backup log", "Customizations were successfully backed up.")
                             : i18nc("@info:status restore log", "Customizations were successfully restored."));
        }
        activateDirWatches();
    });

    suspendDirWatches();
    job->start();
    job.release(); // asynchronous, self-deleting KIO jobs
}

void SafeModeBackupRestore::userLog(MessageType msgType, const QString &msg)
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

void SafeModeBackupRestore::resetUserLog(const QString &filepath)
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

bool SafeModeBackupRestore::hasUserLogError() const
{
    return m_hasUserLogError;
}

void SafeModeBackupRestore::openUserLog()
{
    auto job = new KIO::OpenUrlJob(QUrl::fromLocalFile(m_userLogFile.fileName()));
    QObject::connect(job, &KJob::result, this, [this](KJob *openJob) {
        if (openJob->error()) {
            qCWarning(WELCOME_LOG) << openJob->errorString();
        }
    });
    job->start();
}

void SafeModeBackupRestore::openBackupDirWithHighlightedUserLog()
{
    auto job = KIO::highlightInFileManager({QUrl::fromLocalFile(m_userLogFile.fileName())});
    QObject::connect(job, &KJob::result, this, [this, fileName = m_userLogFile.fileName()](KJob *openJob) {
        if (openJob->error()) {
            qCWarning(WELCOME_LOG) << "Could not open backup dir (with user log" << fileName << "highlighted):" << openJob->errorString();
        }
    });
    // highlightInFileManager() starts the job automatically
}

static void collectWatchDirsForSource(const CategoryInfo &info, const QString &categorySourceDir, QSet<QString> &watchDirs)
{
    if (categorySourceDir.isEmpty()) {
        return;
    }

    const QSet<QString> knownPaths = info.knownRelativePaths();

    if (info.isEntireDir() || knownPaths.isEmpty()) {
        watchDirs.insert(categorySourceDir);
    } else {
        for (const QString &relPath : knownPaths) {
            const QString absolutePath = subPath(categorySourceDir, relPath);
            watchDirs.insert(QFileInfo(absolutePath).path());
        }
    }
}

static void collectWatchDirsForTarget(const CategoryInfo &info,
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

                if (info.containsPartsOfRelativeDir(relativeDir)) {
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

void SafeModeBackupRestore::activateDirWatches()
{
    QSet<QString> origDirWatches;
    QSet<QString> backupSubDirWatches;

    for (const auto &info : m_categoryInfo) {
        QString backupSubDir = info.backupCategoryRoot;

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

    updateAvailableCategories();
}

void SafeModeBackupRestore::suspendDirWatches()
{
    for (const auto &dir : m_origDirWatches) {
        m_origDirWatch->removeDir(dir);
    }
    m_origDirWatches.clear();

    for (const auto &dir : m_backupDirWatches) {
        m_backupDirWatch->removeDir(dir);
    }
    m_backupDirWatches.clear();
}

#include "moc_safemodebackuprestore.cpp"
#include "safemodebackuprestore.moc" // SequentialCompositeJob
