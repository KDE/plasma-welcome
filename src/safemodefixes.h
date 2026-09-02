/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QByteArray>
#include <QObject>
#include <QUrl>
#include <qqmlregistration.h>

class KDirWatch;
class KJob;

class SafeModeFixes : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("access via Private.App.safeMode instead")

public:
    enum class BackupCategory {
        DataDir = 0x1,
        ConfigDir = 0x2,
        StateDir = 0x4,
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
    Q_PROPERTY(QList<QUrl> preExistingBackupTargetDirs READ preExistingBackupTargetDirs NOTIFY preExistingBackupTargetDirsChanged FINAL)

    Q_PROPERTY(BackupCategories availableRestoreSources READ availableRestoreSources NOTIFY availableRestoreSourcesChanged FINAL)
    Q_PROPERTY(BackupCategories selectedRestoreCategories READ selectedRestoreCategories WRITE setSelectedRestoreCategories NOTIFY
                   selectedRestoreCategoriesChanged FINAL)
    Q_PROPERTY(BackupCategories successfulRestoreCategories READ successfulRestoreCategories NOTIFY successfulRestoreCategoriesChanged FINAL)
    Q_PROPERTY(QList<QUrl> preExistingRestoreTargetDirs READ preExistingRestoreTargetDirs NOTIFY preExistingRestoreTargetDirsChanged FINAL)

public:
    SafeModeFixes(QObject *parent = nullptr);

    QUrl origCacheDir() const;
    bool origCacheDirExists() const;

    QUrl origCustomizationDir(BackupCategory which) const;

    void setBackupDir(const QUrl &dir);
    QUrl backupDir() const;
    QUrl backupSubDir(BackupCategory which) const;

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

    QList<QUrl> preExistingBackupTargetDirs() const;
    QList<QUrl> preExistingRestoreTargetDirs() const;

    Q_SCRIPTABLE void clearCache();
    Q_SCRIPTABLE bool moveCustomizationsToBackupDir(KJob *previousJob = nullptr);
    Q_SCRIPTABLE void openBackupDir();
    Q_SCRIPTABLE bool restoreCustomizationsFromBackupDir();

    Q_SCRIPTABLE void logOut();

Q_SIGNALS:
    void origCacheDirExistsChanged();

    void backupDirChanged();

    void availableBackupSourcesChanged();
    void selectedBackupCategoriesChanged();
    void successfulBackupCategoriesChanged();
    void preExistingBackupTargetDirsChanged();

    void availableRestoreSourcesChanged();
    void selectedRestoreCategoriesChanged();
    void successfulRestoreCategoriesChanged();
    void preExistingRestoreTargetDirsChanged();

private:
    enum class MessageType {
        Progress,
        Error,
    };

    void addOrigDirWatches();
    void setOrigDirExists(const QString &path, bool exists);

    void addBackupSubDirWatches();
    void removeBackupSubDirWatches();
    void setBackupSubDirExists(const QString &path, bool exists);

    void userLog(MessageType, const QString &msg);
    void resetUserLog();

private:
    QString m_origDataDir;
    QString m_origConfigDir;
    QString m_origStateDir;
    QString m_origCacheDir;
    QUrl m_backupDir;
    BackupCategories m_selectedBackupCategories;
    BackupCategories m_successfulBackupCategories;
    BackupCategories m_availableBackupSources;
    BackupCategories m_selectedRestoreCategories;
    BackupCategories m_successfulRestoreCategories;
    BackupCategories m_availableRestoreSources;
    bool m_origCacheDirExists = false;
    KDirWatch *m_origDirWatch;
    KDirWatch *m_backupDirWatch;
};
