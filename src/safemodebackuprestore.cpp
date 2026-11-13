/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "safemodebackuprestore.h"

#include <KCompositeJob>
#include <KIO/CopyJob>
#include <KIO/MkpathJob>
#include <KIO/OpenUrlJob>
#include <KJob>

#include <QDir>
#include <QFileInfo>

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
    , m_backupCategories(new CategoryModel(m_categoryInfo, this))
    , m_restoreCategories(new CategoryModel(m_categoryInfo, this))
{
    updateBackupCategoryRoots();
    updateAvailableCategories();
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

    m_backupDir = dir;
    updateBackupCategoryRoots();
    updateAvailableCategories();
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
    m_backupCategories->resetSuccessful();
}

void SafeModeBackupRestore::resetSuccessfulRestoreCategories()
{
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

    QObject::connect(moveJob.get(), &KJob::result, compositeJob, [compositeJob](KJob *moveJob) {
        if (moveJob->error()) {
            compositeJob->setSubJobError(moveJob);
        }
    });

    compositeJob->addSubjob(moveJob.release());
}

static void addMkpathSubJob(SequentialCompositeJob *compositeJob, const QUrl &dir, const QUrl &baseUrl = QUrl())
{
    std::unique_ptr<KJob> mkpathJob(KIO::mkpath(dir, baseUrl));

    QObject::connect(mkpathJob.get(), &KJob::result, compositeJob, [compositeJob](KJob *mkpathJob) {
        if (mkpathJob->error()) {
            compositeJob->setSubJobError(mkpathJob);
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

bool SafeModeBackupRestore::checkValidFilesForCategory(const CategoryInfo &categoryInfo,
                                                       const QSet<QString> &relativeSourcePaths,
                                                       const QUrl &sourceDir,
                                                       const QUrl &targetDir)
{
    if (relativeSourcePaths.isEmpty()) {
        qCWarning(WELCOME_LOG) << "Aborting - no source files found in" << sourceDir.toLocalFile();
        return false;
    }
    if (const auto conflictingPaths = conflictingPathsForCategory(categoryInfo, targetDir); !conflictingPaths.isEmpty()) {
        qCWarning(WELCOME_LOG) << "Aborting - target files already exist:" << conflictingPaths;
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

    auto compositeJob = std::make_unique<SequentialCompositeJob>();
    compositeJob->setAbortOnError(false);

    for (const auto &info : m_categoryInfo) {
        const auto relativeSourcePaths = m_availableBackupSourcePaths.value(info.category);
        if (relativeSourcePaths.isEmpty()) {
            continue;
        }
        const QUrl sourceDir = QUrl::fromLocalFile(info.origDirRoot);
        const QString targetDirPath = info.backupCategoryRoot;
        const QUrl targetDir = QUrl::fromLocalFile(targetDirPath);

        if (!checkValidFilesForCategory(info, relativeSourcePaths, sourceDir, targetDir)) {
            return false;
        }
        std::unique_ptr<KJob> categoryJob = makeCategoryMoveJob(info, sourceDir, targetDir, m_backupDir, relativeSourcePaths);

        QObject::connect(categoryJob.get(), &KJob::result, this, [this, category = info.category](KJob *categoryJob) {
            if (!categoryJob->error()) {
                m_backupCategories->setSuccessful(category, true);

                // The moved files now exist in the backup directory, so this category
                // can be made available for restoring.
                m_restoreCategories->setAvailable(category, true);
            }
        });
        compositeJob->addSubjob(categoryJob.release());
    }

    startOperation(std::move(compositeJob));
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

    auto compositeJob = std::make_unique<SequentialCompositeJob>();
    compositeJob->setAbortOnError(false);

    for (const auto &info : m_categoryInfo) {
        const auto relativeSourcePaths = m_availableRestoreSourcePaths.value(info.category);
        if (relativeSourcePaths.isEmpty()) {
            continue;
        }
        const QString sourceDirPath = info.backupCategoryRoot;
        const QUrl sourceDir = QUrl::fromLocalFile(sourceDirPath);
        const QUrl targetDir = QUrl::fromLocalFile(info.origDirRoot);

        if (!checkValidFilesForCategory(info, relativeSourcePaths, sourceDir, targetDir)) {
            return false;
        }
        std::unique_ptr<KJob> categoryJob = makeCategoryMoveJob(info, sourceDir, targetDir, QUrl(), relativeSourcePaths);

        QObject::connect(categoryJob.get(), &KJob::result, this, [this, category = info.category](KJob *categoryJob) {
            if (!categoryJob->error()) {
                m_restoreCategories->setSuccessful(category, true);

                // The restored files now exist in the original directory, so this category
                // can be made available for backing up again.
                m_backupCategories->setAvailable(category, true);
            }
        });
        compositeJob->addSubjob(categoryJob.release());
    }

    startOperation(std::move(compositeJob));
    return true;
}

void SafeModeBackupRestore::startOperation(std::unique_ptr<KJob> job)
{
    QObject::connect(job.get(), &KJob::result, this, &SafeModeBackupRestore::updateAvailableCategories);

    job->start();
    job.release(); // asynchronous, self-deleting KIO jobs
}

void SafeModeBackupRestore::openBackupDir()
{
    auto job = new KIO::OpenUrlJob(m_backupDir);
    QObject::connect(job, &KJob::result, this, [](KJob *openJob) {
        if (openJob->error()) {
            qCWarning(WELCOME_LOG) << "Could not open backup dir:" << openJob->errorString();
        }
    });
    job->start();
}

#include "moc_safemodebackuprestore.cpp"
#include "safemodebackuprestore.moc" // SequentialCompositeJob
