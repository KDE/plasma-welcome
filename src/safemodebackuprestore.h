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
#include <qqmlintegration.h>

class CategoryInfo;
class KDirWatch;
class KJob;

class SafeModeBackupRestore : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("access via Private.SafeMode.xdgBackup instead")

public:
    enum class Category {
        PlasmaConfig = 0x1,
        NonPlasmaConfig = 0x2,
        State = 0x4,
        Data = 0x8,
    };
    Q_DECLARE_FLAGS(Categories, Category)
    Q_FLAG(Categories)

private:
    Q_PROPERTY(QUrl backupDir READ backupDir WRITE setBackupDir NOTIFY backupDirChanged FINAL)

    Q_PROPERTY(Categories availableBackupSources READ availableBackupSources NOTIFY availableBackupSourcesChanged FINAL)
    Q_PROPERTY(Categories selectedBackupCategories READ selectedBackupCategories WRITE setSelectedBackupCategories NOTIFY selectedBackupCategoriesChanged FINAL)
    Q_PROPERTY(Categories successfulBackupCategories READ successfulBackupCategories NOTIFY successfulBackupCategoriesChanged FINAL)
    Q_PROPERTY(QList<QUrl> preExistingBackupTargetPaths READ preExistingBackupTargetPaths NOTIFY preExistingBackupTargetPathsChanged FINAL)

    Q_PROPERTY(Categories availableRestoreSources READ availableRestoreSources NOTIFY availableRestoreSourcesChanged FINAL)
    Q_PROPERTY(
        Categories selectedRestoreCategories READ selectedRestoreCategories WRITE setSelectedRestoreCategories NOTIFY selectedRestoreCategoriesChanged FINAL)
    Q_PROPERTY(Categories successfulRestoreCategories READ successfulRestoreCategories NOTIFY successfulRestoreCategoriesChanged FINAL)
    Q_PROPERTY(QList<QUrl> preExistingRestoreTargetPaths READ preExistingRestoreTargetPaths NOTIFY preExistingRestoreTargetPathsChanged FINAL)

    Q_PROPERTY(bool hasUserLogError READ hasUserLogError NOTIFY userLogErrorChanged FINAL)

public:
    SafeModeBackupRestore(QObject *parent = nullptr);
    ~SafeModeBackupRestore();

    void setBackupDir(const QUrl &dir);
    QUrl backupDir() const;

    Categories availableBackupSources() const;
    QMap<Category, QUrl> availableBackupSourceDirs() const;

    Categories availableRestoreSources() const;
    QMap<Category, QUrl> availableRestoreSourceDirs() const;

    void setSelectedBackupCategories(Categories);
    Categories selectedBackupCategories() const;

    Categories successfulBackupCategories() const;
    Q_SCRIPTABLE void resetSuccessfulBackupCategories();

    void setSelectedRestoreCategories(Categories);
    Categories selectedRestoreCategories() const;

    Categories successfulRestoreCategories() const;
    Q_SCRIPTABLE void resetSuccessfulRestoreCategories();

    QList<QUrl> preExistingBackupTargetPaths() const;
    QList<QUrl> preExistingRestoreTargetPaths() const;

    bool hasUserLogError() const;

    Q_SCRIPTABLE bool moveCustomizationsToBackupDir(KJob *previousJob = nullptr);
    Q_SCRIPTABLE void openBackupDirWithHighlightedUserLog();
    Q_SCRIPTABLE void openUserLog();
    Q_SCRIPTABLE bool restoreCustomizationsFromBackupDir();

Q_SIGNALS:
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
    void updateBackupCategoryRoots();
    QList<QUrl> conflictingPathsForCategory(const CategoryInfo &categoryInfo, const QUrl &categoryTargetDir) const;

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
    Categories m_availableBackupSources;
    Categories m_selectedBackupCategories;
    Categories m_successfulBackupCategories;
    Categories m_availableRestoreSources;
    Categories m_selectedRestoreCategories;
    Categories m_successfulRestoreCategories;
    KDirWatch *m_origDirWatch;
    KDirWatch *m_backupDirWatch;
    QSet<QString> m_origDirWatches;
    QSet<QString> m_backupDirWatches;
    QHash<Category, QSet<QString>> m_availableBackupSourcePaths;
    QHash<Category, QSet<QString>> m_availableRestoreSourcePaths;
    QFile m_userLogFile;
    bool m_hasUserLogError = false;
};
