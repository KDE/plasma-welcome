/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QFile>
#include <QHash>
#include <QObject>
#include <QSet>
#include <QUrl>
#include <qqmlregistration.h>

class BackupCategoryInfo;
class KDirWatch;
class KJob;

class SafeModeFixes : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("access via Private.App.safeModeFixes instead")

public:
    enum class BackupCategory {
        PlasmaConfig = 0x1,
        NonPlasmaConfig = 0x2,
        StateDir = 0x4,
        DataDir = 0x8,
    };
    Q_DECLARE_FLAGS(BackupCategories, BackupCategory)
    Q_FLAG(BackupCategories)

private:
    Q_PROPERTY(QUrl origCacheDir READ origCacheDir CONSTANT FINAL)
    Q_PROPERTY(bool origCacheDirExists READ origCacheDirExists NOTIFY origCacheDirExistsChanged FINAL)

    Q_PROPERTY(QUrl backupDir READ backupDir WRITE setBackupDir NOTIFY backupDirChanged FINAL)

    Q_PROPERTY(BackupCategories availableBackupSources READ availableBackupSources NOTIFY availableBackupSourcesChanged FINAL)
    Q_PROPERTY(
        BackupCategories selectedBackupCategories READ selectedBackupCategories WRITE setSelectedBackupCategories NOTIFY selectedBackupCategoriesChanged FINAL)
    Q_PROPERTY(BackupCategories successfulBackupCategories READ successfulBackupCategories NOTIFY successfulBackupCategoriesChanged FINAL)
    Q_PROPERTY(QList<QUrl> preExistingBackupTargetPaths READ preExistingBackupTargetPaths NOTIFY preExistingBackupTargetPathsChanged FINAL)

    Q_PROPERTY(BackupCategories availableRestoreSources READ availableRestoreSources NOTIFY availableRestoreSourcesChanged FINAL)
    Q_PROPERTY(BackupCategories selectedRestoreCategories READ selectedRestoreCategories WRITE setSelectedRestoreCategories NOTIFY
                   selectedRestoreCategoriesChanged FINAL)
    Q_PROPERTY(BackupCategories successfulRestoreCategories READ successfulRestoreCategories NOTIFY successfulRestoreCategoriesChanged FINAL)
    Q_PROPERTY(QList<QUrl> preExistingRestoreTargetPaths READ preExistingRestoreTargetPaths NOTIFY preExistingRestoreTargetPathsChanged FINAL)

    Q_PROPERTY(bool hasUserLogError READ hasUserLogError NOTIFY userLogErrorChanged FINAL)

public:
    SafeModeFixes(QObject *parent = nullptr);
    ~SafeModeFixes();

    QUrl origCacheDir() const;
    bool origCacheDirExists() const;

    void setBackupDir(const QUrl &dir);
    QUrl backupDir() const;

    BackupCategories availableBackupSources() const;
    QMap<BackupCategory, QUrl> availableBackupSourceDirs() const;

    BackupCategories availableRestoreSources() const;
    QMap<BackupCategory, QUrl> availableRestoreSourceDirs() const;

    void setSelectedBackupCategories(BackupCategories);
    BackupCategories selectedBackupCategories() const;

    BackupCategories successfulBackupCategories() const;
    Q_SCRIPTABLE void resetSuccessfulBackupCategories();

    void setSelectedRestoreCategories(BackupCategories);
    BackupCategories selectedRestoreCategories() const;

    BackupCategories successfulRestoreCategories() const;
    Q_SCRIPTABLE void resetSuccessfulRestoreCategories();

    QList<QUrl> preExistingBackupTargetPaths() const;
    QList<QUrl> preExistingRestoreTargetPaths() const;

    bool hasUserLogError() const;

    Q_SCRIPTABLE void clearCache();
    Q_SCRIPTABLE bool moveCustomizationsToBackupDir(KJob *previousJob = nullptr);
    Q_SCRIPTABLE void openBackupDir();
    Q_SCRIPTABLE void openUserLog();
    Q_SCRIPTABLE bool restoreCustomizationsFromBackupDir();

    Q_SCRIPTABLE void logOut();

Q_SIGNALS:
    void origCacheDirExistsChanged();

    void backupDirChanged();

    void availableBackupSourcesChanged();
    void selectedBackupCategoriesChanged();
    void successfulBackupCategoriesChanged();
    void preExistingBackupTargetPathsChanged();

    void availableRestoreSourcesChanged();
    void selectedRestoreCategoriesChanged();
    void successfulRestoreCategoriesChanged();
    void preExistingRestoreTargetPathsChanged();

    void userLogErrorChanged();

private:
    QList<QUrl> conflictingPathsForCategory(const BackupCategoryInfo &categoryInfo, const QUrl &categoryTargetDir) const;

    enum class MessageType {
        Intention,
        Progress,
        Warning,
        Error,
        CosmeticSpacing,
    };
    void userLog(MessageType, const QString &msg);
    void resetUserLog(const QString &filepath = QString());

    void activateDirWatches();
    void suspendDirWatches();

    void updateOrigCacheDirExists();
    void updateAvailableBackupSources();
    void updateAvailableRestoreSources();

private Q_SLOTS:
    void onOrigDirChanged(const QString &path);
    void onBackupSubDirChanged(const QString &path);

private:
    QString m_origDataDir;
    QString m_origConfigDir;
    QString m_origStateDir;
    QString m_origCacheDir;
    QUrl m_backupDir;
    std::vector<BackupCategoryInfo> m_backupCategoryInfo;
    BackupCategories m_selectedBackupCategories;
    BackupCategories m_successfulBackupCategories;
    BackupCategories m_availableBackupSources;
    BackupCategories m_selectedRestoreCategories;
    BackupCategories m_successfulRestoreCategories;
    BackupCategories m_availableRestoreSources;
    KDirWatch *m_origDirWatch;
    KDirWatch *m_backupDirWatch;
    QSet<QString> m_origDirWatches;
    QSet<QString> m_backupDirWatches;
    QHash<BackupCategory, QSet<QString>> m_availableBackupSourcePaths;
    QHash<BackupCategory, QSet<QString>> m_availableRestoreSourcePaths;
    QFile m_userLogFile;
    bool m_hasUserLogError = false;
    bool m_origCacheDirExists = false;
};
