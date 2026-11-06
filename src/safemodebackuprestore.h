/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include "safemodebackupcategories.h"

#include <QFile>
#include <QHash>
#include <QObject>
#include <QSet>
#include <QUrl>
#include <qqmlintegration.h>

#include <memory>

class KDirWatch;
class KJob;

class SafeModeBackupRestore : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("access via Private.SafeModeBackupRestore instead")

private:
    Q_PROPERTY(QUrl backupDir READ backupDir WRITE setBackupDir NOTIFY backupDirChanged FINAL)
    Q_PROPERTY(SafeModeBackup::CategoryModel *backupCategories READ backupCategories CONSTANT FINAL)
    Q_PROPERTY(SafeModeBackup::CategoryModel *restoreCategories READ restoreCategories CONSTANT FINAL)
    Q_PROPERTY(bool hasUserLogError READ hasUserLogError NOTIFY userLogErrorChanged FINAL)

public:
    SafeModeBackupRestore(QObject *parent = nullptr);
    ~SafeModeBackupRestore();

    void setBackupDir(const QUrl &dir);
    QUrl backupDir() const;

    SafeModeBackup::CategoryModel *backupCategories() const;
    SafeModeBackup::CategoryModel *restoreCategories() const;

    Q_INVOKABLE void resetSuccessfulBackupCategories();
    Q_INVOKABLE void resetSuccessfulRestoreCategories();

    bool hasUserLogError() const;

    Q_SCRIPTABLE bool moveCustomizationsToBackupDir(KJob *previousJob = nullptr);
    Q_SCRIPTABLE void openBackupDirWithHighlightedUserLog();
    Q_SCRIPTABLE void openUserLog();
    Q_SCRIPTABLE bool restoreCustomizationsFromBackupDir();

Q_SIGNALS:
    void backupDirChanged();
    void userLogErrorChanged();

private:
    using Category = SafeModeBackup::Category;
    using Categories = SafeModeBackup::Categories;
    using CategoryInfo = SafeModeBackup::CategoryInfo;
    using Operation = SafeModeBackup::Operation;

    void updateBackupCategoryRoots();
    QList<QUrl> conflictingPathsForCategory(const CategoryInfo &, const QUrl &categoryTargetDir) const;
    void updateConflicts();
    bool checkValidFilesForCategory(const CategoryInfo &, const QSet<QString> &relativeSourcePaths, const QUrl &sourceDir, const QUrl &targetDir);
    void connectJobUpdatesToUserLog(KJob *job, Operation operation, const QString &categoryTitle, const QString &backupCategoryRoot);
    void startOperation(std::unique_ptr<KJob> job, Operation operation);

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

private Q_SLOTS:
    void updateAvailableBackupSources();
    void updateAvailableRestoreSources();

private:
    QUrl m_backupDir;
    std::vector<CategoryInfo> m_categoryInfo;
    SafeModeBackup::CategoryModel *m_backupCategories = nullptr;
    SafeModeBackup::CategoryModel *m_restoreCategories = nullptr;
    KDirWatch *m_origDirWatch = nullptr;
    KDirWatch *m_backupDirWatch = nullptr;
    QSet<QString> m_origDirWatches;
    QSet<QString> m_backupDirWatches;
    QHash<Category, QSet<QString>> m_availableBackupSourcePaths;
    QHash<Category, QSet<QString>> m_availableRestoreSourcePaths;
    QFile m_userLogFile;
    bool m_hasUserLogError = false;
};
