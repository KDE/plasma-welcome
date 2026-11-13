/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include "safemodebackupcategories.h"

#include <QHash>
#include <QObject>
#include <QSet>
#include <QUrl>
#include <qqmlintegration.h>

#include <memory>

class KJob;

class SafeModeBackupRestore : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("access via Private.SafeMode.backupRestore instead")

private:
    Q_PROPERTY(QUrl backupDir READ backupDir WRITE setBackupDir NOTIFY backupDirChanged FINAL)
    Q_PROPERTY(SafeModeBackup::CategoryModel *backupCategories READ backupCategories CONSTANT FINAL)
    Q_PROPERTY(SafeModeBackup::CategoryModel *restoreCategories READ restoreCategories CONSTANT FINAL)

public:
    SafeModeBackupRestore(const QString &homeDir, QObject *parent = nullptr);
    ~SafeModeBackupRestore();

    void setBackupDir(const QUrl &dir);
    QUrl backupDir() const;

    SafeModeBackup::CategoryModel *backupCategories() const;
    SafeModeBackup::CategoryModel *restoreCategories() const;

    Q_INVOKABLE void updateAvailableCategories();

    Q_INVOKABLE void resetSuccessfulBackupCategories();
    Q_INVOKABLE void resetSuccessfulRestoreCategories();

    Q_SCRIPTABLE bool moveCustomizationsToBackupDir(KJob *previousJob = nullptr);
    Q_SCRIPTABLE void openBackupDir();
    Q_SCRIPTABLE bool restoreCustomizationsFromBackupDir();

Q_SIGNALS:
    void backupDirChanged();

private:
    using Category = SafeModeBackup::Category;
    using CategoryInfo = SafeModeBackup::CategoryInfo;

    void updateBackupCategoryRoots();
    QList<QUrl> conflictingPathsForCategory(const CategoryInfo &, const QUrl &categoryTargetDir) const;
    void updateConflicts();
    bool checkValidFilesForCategory(const CategoryInfo &, const QSet<QString> &relativeSourcePaths, const QUrl &sourceDir, const QUrl &targetDir);
    void startOperation(std::unique_ptr<KJob> job);

private:
    QUrl m_backupDir;
    std::vector<CategoryInfo> m_categoryInfo;
    SafeModeBackup::CategoryModel *m_backupCategories = nullptr;
    SafeModeBackup::CategoryModel *m_restoreCategories = nullptr;
    QHash<Category, QSet<QString>> m_availableBackupSourcePaths;
    QHash<Category, QSet<QString>> m_availableRestoreSourcePaths;
};
