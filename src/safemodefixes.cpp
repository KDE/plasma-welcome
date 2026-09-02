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
#include <QFileInfo>
#include <QStandardPaths>
#include <QtEnvironmentVariables>

#include <array>
#include <memory>
#include <vector>

#include "welcome_debug.h"

using namespace Qt::StringLiterals;

constexpr std::array<SafeModeFixes::BackupCategory, 3> s_allBackupCategories = {
    SafeModeFixes::BackupCategory::DataDir,
    SafeModeFixes::BackupCategory::ConfigDir,
    SafeModeFixes::BackupCategory::StateDir,
};

namespace
{
QString withoutTrailingSlash(const QByteArray &path)
{
    return path.length() > 1 && path.endsWith('/') ? path.chopped(1) : path;
}

QUrl subDir(const QUrl &url, const QString &subdirname)
{
    QUrl newUrl = url;
    newUrl.setPath(url.path() + (url.path().endsWith('/') ? QString() : u"/"_s) + subdirname);
    return newUrl;
}

class WaitForAllCompositeJob : public KCompositeJob
{
    Q_OBJECT

public:
    bool addSubjob(KJob *job) override; // original addSubjob() is protected, so we can't use it directly
    void start() override;

protected Q_SLOTS:
    void slotResult(KJob *job) override;
};

bool WaitForAllCompositeJob::addSubjob(KJob *job)
{
    return KCompositeJob::addSubjob(job);
}

void WaitForAllCompositeJob::start()
{
    if (hasSubjobs()) {
        subjobs().first()->start();
    } else {
        emitResult();
    }
}

void WaitForAllCompositeJob::slotResult(KJob *job)
{
    if (job->error() && !error()) {
        // Store it in the parent only if first error
        setError(job->error());
        setErrorText(job->errorText());
        // Unlike KCompositeJob, wait for all jobs to complete before emitResult()
    }
    removeSubjob(job);
    start(); // a.k.a. continue/finish
}
} // anonymous namespace

SafeModeFixes::SafeModeFixes(QObject *parent)
    : QObject(parent)
    , m_selectedBackupCategories({BackupCategory::ConfigDir, BackupCategory::StateDir})
    , m_origDirWatch(new KDirWatch(this))
    , m_backupDirWatch(new KDirWatch(this))
{
    m_origDataDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_DATA_HOME"));
    m_origConfigDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME"));
    m_origStateDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_STATE_HOME"));
    m_origCacheDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_CACHE_HOME"));

    QObject::connect(m_origDirWatch, &KDirWatch::created, this, [this](const QString &path) {
        setOrigDirExists(path, true);
    });
    QObject::connect(m_origDirWatch, &KDirWatch::deleted, this, [this](const QString &path) {
        setOrigDirExists(path, false);
    });
    addOrigDirWatches();

    // re-evaluate if directories already exist
    QObject::connect(this, &SafeModeFixes::backupDirChanged, this, &SafeModeFixes::preExistingBackupTargetDirsChanged);
    QObject::connect(this, &SafeModeFixes::selectedBackupCategoriesChanged, this, &SafeModeFixes::preExistingBackupTargetDirsChanged);
    QObject::connect(this, &SafeModeFixes::selectedRestoreCategoriesChanged, this, &SafeModeFixes::preExistingRestoreTargetDirsChanged);

    m_selectedBackupCategories &= m_availableBackupSources; // as initialized by addOrigDirWatches()
    m_backupDir = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + "/CustomizationsBackup"_L1);

    QObject::connect(m_backupDirWatch, &KDirWatch::created, this, [this](const QString &path) {
        setBackupSubDirExists(path, true);
    });
    QObject::connect(m_backupDirWatch, &KDirWatch::deleted, this, [this](const QString &path) {
        setBackupSubDirExists(path, false);
    });
    addBackupSubDirWatches();

    m_selectedRestoreCategories = m_availableRestoreSources; // as initialized by addBackupSubDirWatches()
}

QUrl SafeModeFixes::origCacheDir() const
{
    return m_origCacheDirExists ? QUrl() : QUrl::fromLocalFile(m_origCacheDir);
}

bool SafeModeFixes::origCacheDirExists() const
{
    return m_origCacheDirExists;
}

QUrl SafeModeFixes::origCustomizationDir(BackupCategory which) const
{
    switch (which) {
    case BackupCategory::ConfigDir:
        return QUrl::fromLocalFile(m_origConfigDir);
    case BackupCategory::StateDir:
        return QUrl::fromLocalFile(m_origStateDir);
    case BackupCategory::DataDir:
        return QUrl::fromLocalFile(m_origDataDir);
    default:
        return QUrl();
    }
}

void SafeModeFixes::setBackupDir(const QUrl &dir)
{
    if (m_backupDir == dir) {
        return;
    }
    resetSuccessfulBackupCategories();
    resetSuccessfulRestoreCategories();

    removeBackupSubDirWatches();
    m_backupDir = dir;
    addBackupSubDirWatches();
    Q_EMIT backupDirChanged();
}

QUrl SafeModeFixes::backupDir() const
{
    return m_backupDir;
}

QUrl SafeModeFixes::backupSubDir(BackupCategory which) const
{
    if (!m_backupDir.isLocalFile()) {
        return QUrl();
    }

    switch (which) {
    case BackupCategory::DataDir:
        return subDir(m_backupDir, u"data"_s);
    case BackupCategory::ConfigDir:
        return subDir(m_backupDir, u"config"_s);
    case BackupCategory::StateDir:
        return subDir(m_backupDir, u"state"_s);
    default:
        return QUrl();
    }
}

SafeModeFixes::BackupCategories SafeModeFixes::availableBackupSources() const
{
    return m_availableBackupSources;
}

QMap<SafeModeFixes::BackupCategory, QUrl> SafeModeFixes::availableBackupSourceDirs() const
{
    QMap<BackupCategory, QUrl> dirs;
    for (BackupCategory category : s_allBackupCategories) {
        if (m_availableBackupSources.testFlag(category)) {
            dirs.insert(category, origCustomizationDir(category));
        }
    }
    return dirs;
}

SafeModeFixes::BackupCategories SafeModeFixes::availableRestoreSources() const
{
    return m_availableRestoreSources;
}

QMap<SafeModeFixes::BackupCategory, QUrl> SafeModeFixes::availableRestoreSourceDirs() const
{
    QMap<BackupCategory, QUrl> dirs;
    for (BackupCategory category : s_allBackupCategories) {
        if (m_availableRestoreSources.testFlag(category)) {
            dirs.insert(category, backupSubDir(category));
        }
    }
    return dirs;
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

QList<QUrl> SafeModeFixes::preExistingBackupTargetDirs() const
{
    QList<QUrl> dirs;

    for (BackupCategory category : s_allBackupCategories) {
        if (!m_selectedBackupCategories.testFlag(category)) {
            continue;
        }
        // Yes, use QFileInfo::exists() instead of QDir::exists(), because we also don't want to
        // overwrite any regular files when moving the source directories.
        if (const QUrl &dir = backupSubDir(category); dir.isLocalFile() && QFileInfo::exists(dir.toLocalFile())) {
            dirs.append(dir);
        }
    }
    return dirs;
}

QList<QUrl> SafeModeFixes::preExistingRestoreTargetDirs() const
{
    QList<QUrl> dirs;

    for (BackupCategory category : s_allBackupCategories) {
        if (!m_selectedRestoreCategories.testFlag(category)) {
            continue;
        }
        if (const QUrl &dir = origCustomizationDir(category); dir.isLocalFile() && QFileInfo::exists(dir.toLocalFile())) {
            dirs.append(dir);
        }
    }
    return dirs;
}

void SafeModeFixes::clearCache()
{
    if (m_origCacheDir.isEmpty()) {
        qCWarning(WELCOME_LOG) << "Didn't user cache dir (not in Safe Mode)";
        return;
    }
    auto job = KIO::del(QUrl::fromLocalFile(m_origCacheDir));
    job->start();
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

    auto compositeJob = std::make_unique<WaitForAllCompositeJob>();

    for (const auto category : s_allBackupCategories) {
        if (!m_selectedBackupCategories.testFlag(category)) {
            continue;
        }
        const auto sourceDir = origCustomizationDir(category);
        const auto targetDir = backupSubDir(category);
        const QString &sourceDirPath = sourceDir.toLocalFile();
        const QString &targetDirPath = targetDir.toLocalFile();
        userLog(MessageType::Intention,
                i18nc("@info:status backup log - %1 is a backup category, %2 is a folder path",
                      "Backing up %1 files to `%2`",
                      i18nCategoryName(category),
                      targetDirPath));

        if (!QDir(sourceDirPath).exists()) {
            userLog(MessageType::Error,
                    i18nc("@info:status backup log error - %1 is folder path, %2 is backup category",
                          "Didn't move customization dirs - source customization directory doesn't exist: `%1` (%2)",
                          sourceDirPath,
                          i18nCategoryName(category)));
            return false;
        }
        if (QFileInfo::exists(targetDirPath)) {
            userLog(MessageType::Error,
                    i18nc("@info:status backup log error - %1 is folder path, %2 is backup category",
                          "Didn't move customization dirs - target backup directory already exists: `%1` (%2)",
                          targetDirPath,
                          i18nCategoryName(category)));
            return false;
        }
        std::unique_ptr<KJob> moveJob{KIO::moveAs(sourceDir, targetDir)};

        QObject::connect(moveJob.get(), &KJob::infoMessage, this, [this, category](KJob *, const QString &message) {
            userLog(MessageType::Intention,
                    i18nc("@info:status backup/restore log error - %1 is backup category, %2 is an info message from the move job",
                          "%1: %2",
                          i18nCategoryName(category),
                          message));
        });
        QObject::connect(moveJob.get(), &KJob::result, this, [this, category, sourceDirPath, targetDirPath](KJob *moveJob) {
            if (moveJob->error()) {
                userLog(MessageType::Error,
                        i18nc("@info:status backup/restore log error - %1 and %2 are folder paths, %3 is the error message",
                              "Error moving `%1` to `%2`: %3",
                              sourceDirPath,
                              targetDirPath,
                              moveJob->errorString()));
            } else {
                userLog(MessageType::Progress,
                        i18nc("@info:status successful backup/restore log - %1 and %2 are folder paths", "Moved `%1` to `%2`", sourceDirPath, targetDirPath));
                m_successfulBackupCategories |= category;
                Q_EMIT successfulBackupCategoriesChanged();

                // Also pre-select it for restoring this backup, in case the user wants to move it right back.
                m_selectedRestoreCategories |= category;
                Q_EMIT selectedRestoreCategoriesChanged();
            }
        });
        compositeJob->addSubjob(moveJob.release());
    }

    userLog(MessageType::CosmeticSpacing, ""_L1);

    QObject::connect(compositeJob.get(), &KJob::result, this, [this](KJob *job) {
        userLog(MessageType::CosmeticSpacing, ""_L1);
        if (job->error()) {
            userLog(MessageType::Error, i18nc("@info:status backup log", "Errors encountered while backing up customizations, see above."));
        } else {
            userLog(MessageType::Progress, i18nc("@info:status backup log", "Customizations were successfully backed up."));
        }
        resumeDirWatches();
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

    auto compositeJob = std::make_unique<WaitForAllCompositeJob>();

    for (const auto category : s_allBackupCategories) {
        if (!m_selectedRestoreCategories.testFlag(category)) {
            continue;
        }
        const auto sourceDir = backupSubDir(category);
        const auto targetDir = origCustomizationDir(category);
        const QString &sourceDirPath = sourceDir.toLocalFile();
        const QString &targetDirPath = targetDir.toLocalFile();
        userLog(MessageType::Intention,
                i18nc("@info:status restore log - %1 is a backup category, %2 is a folder path",
                      "Restoring %1 backup files from `%2`",
                      i18nCategoryName(category),
                      sourceDirPath));

        if (!QDir(sourceDirPath).exists()) {
            userLog(MessageType::Error,
                    i18nc("@info:status restore log error: %1 is folder path, %2 is backup category",
                          "Didn't restore customization dirs - source backup directory doesn't exist: `%1` (%2)",
                          sourceDirPath,
                          i18nCategoryName(category)));
            return false;
        }
        if (QFileInfo::exists(targetDirPath)) {
            userLog(MessageType::Error,
                    i18nc("@info:status restore log error: %1 is folder path, %2 is backup category",
                          "Didn't restore customization dirs - target customization directory already exists:",
                          targetDirPath,
                          i18nCategoryName(category)));
            return false;
        }
        std::unique_ptr<KJob> moveJob{KIO::moveAs(sourceDir, targetDir)};

        QObject::connect(moveJob.get(), &KJob::infoMessage, this, [this, category](KJob *, const QString &message) {
            userLog(MessageType::Intention,
                    i18nc("@info:status backup/restore log error - %1 is backup category, %2 is an info message from the move job",
                          "%1: %2",
                          i18nCategoryName(category),
                          message));
        });
        QObject::connect(moveJob.get(), &KJob::result, this, [this, category, sourceDirPath, targetDirPath](KJob *moveJob) {
            if (moveJob->error()) {
                userLog(MessageType::Error,
                        i18nc("@info:status backup/restore log error - %1 and %2 are folder paths, %3 is the error message",
                              "Error moving %1 to %2: %3",
                              sourceDirPath,
                              targetDirPath,
                              moveJob->errorString()));
            } else {
                userLog(MessageType::Progress,
                        i18nc("@info:status successful backup/restore log - %1 and %2 are folder paths", "Moved `%1` to `%2`", sourceDirPath, targetDirPath));
                m_successfulRestoreCategories |= category;
                Q_EMIT successfulRestoreCategoriesChanged();

                // Also pre-select it for backup, in case the user wants to back it up again right away.
                m_selectedBackupCategories |= category;
                Q_EMIT selectedBackupCategoriesChanged();
            }
        });
        compositeJob->addSubjob(moveJob.release());
    }

    userLog(MessageType::CosmeticSpacing, ""_L1);

    QObject::connect(compositeJob.get(), &KJob::result, this, [this](KJob *job) {
        userLog(MessageType::CosmeticSpacing, ""_L1);
        if (job->error()) {
            userLog(MessageType::Error, i18nc("@info:status restore log", "Errors encountered while restoring customizations, see above."));
        } else {
            userLog(MessageType::Progress, i18nc("@info:status restore log", "Customizations were successfully restored."));
        }
        resumeDirWatches();
    });
    suspendDirWatches();
    compositeJob->start();
    compositeJob.release(); // asynchronous, self-deleting KIO jobs

    return true;
}

QString SafeModeFixes::i18nCategoryName(BackupCategory category) const
{
    switch (category) {
    case BackupCategory::ConfigDir:
        return i18nc("name for backup category (in logs, etc.)", "Configuration");
    case BackupCategory::StateDir:
        return i18nc("name for backup category (in logs, etc.)", "State");
    case BackupCategory::DataDir:
        return i18nc("name for backup category (in logs, etc.)", "Desktop & Application Data");
    }
    return QVariant::fromValue(category).toString();
}

void SafeModeFixes::userLog(MessageType msgType, const QString &msg)
{
    if (m_userLogFile.isOpen()) {
        QTextStream out(&m_userLogFile);

        if (msgType == MessageType::Error) {
            out << "🗙 ";
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

void SafeModeFixes::addOrigDirWatches()
{
    for (const QString &path : {m_origConfigDir, m_origStateDir, m_origDataDir, m_origCacheDir}) {
        if (!path.isEmpty()) {
            m_origDirWatch->addDir(path);
            setOrigDirExists(path, QDir(path).exists());
        }
    }
}

void SafeModeFixes::removeOrigDirWatches()
{
    for (const QString &path : {m_origConfigDir, m_origStateDir, m_origDataDir, m_origCacheDir}) {
        if (!path.isEmpty()) {
            m_origDirWatch->removeDir(path);
            setOrigDirExists(path, false); // even if it does exist, we can't know about it now
        }
    }
}

void SafeModeFixes::setOrigDirExists(const QString &path, bool exists)
{
    if (path == m_origCacheDir) {
        m_origCacheDirExists = exists;
        Q_EMIT origCacheDirExistsChanged();
    } else if (path == m_origDataDir) {
        m_availableBackupSources.setFlag(BackupCategory::DataDir, exists);
        Q_EMIT availableBackupSourcesChanged();
        Q_EMIT preExistingRestoreTargetDirsChanged();
    } else if (path == m_origConfigDir) {
        m_availableBackupSources.setFlag(BackupCategory::ConfigDir, exists);
        Q_EMIT availableBackupSourcesChanged();
        Q_EMIT preExistingRestoreTargetDirsChanged();
    } else if (path == m_origStateDir) {
        m_availableBackupSources.setFlag(BackupCategory::StateDir, exists);
        Q_EMIT availableBackupSourcesChanged();
        Q_EMIT preExistingRestoreTargetDirsChanged();
    }
}

void SafeModeFixes::addBackupSubDirWatches()
{
    if (!m_backupDir.isLocalFile()) {
        return;
    }
    for (BackupCategory category : s_allBackupCategories) {
        if (const QUrl dir = backupSubDir(category); dir.isLocalFile()) {
            const QString path = dir.toLocalFile();
            m_backupDirWatch->addDir(path);
            setBackupSubDirExists(path, QDir(path).exists());
        }
    }
}

void SafeModeFixes::removeBackupSubDirWatches()
{
    if (!m_backupDir.isLocalFile()) {
        return;
    }
    for (BackupCategory category : s_allBackupCategories) {
        if (const QUrl &dir = backupSubDir(category); dir.isLocalFile()) {
            const QString path = dir.toLocalFile();
            m_backupDirWatch->removeDir(path);
            setBackupSubDirExists(path, false); // even if it does exist, we can't know about it now
        }
    }
}

void SafeModeFixes::setBackupSubDirExists(const QString &path, bool exists)
{
    for (BackupCategory category : s_allBackupCategories) {
        if (path == backupSubDir(category).toLocalFile()) {
            m_availableRestoreSources.setFlag(category, exists);
            Q_EMIT availableRestoreSourcesChanged();
            Q_EMIT preExistingBackupTargetDirsChanged();
            break;
        }
    }
}

void SafeModeFixes::suspendDirWatches()
{
    removeOrigDirWatches();
    removeBackupSubDirWatches();
}

void SafeModeFixes::resumeDirWatches()
{
    addOrigDirWatches();
    addBackupSubDirWatches();
}

#include "moc_safemodefixes.cpp"
#include "safemodefixes.moc" // WaitForAllCompositeJob
