/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QAbstractListModel>
#include <QHash>
#include <QList>
#include <QSet>
#include <QString>
#include <QUrl>
#include <qqmlintegration.h>

#include <memory>
#include <vector>

namespace SafeModeBackup
{
// Opaque identifier for a customization category. Values are assigned in makeCategoryInfo().
using Category = int;

enum class Operation {
    Backup,
    Restore,
};

struct CategoryInfo {
    struct FileAndDirPaths {
        virtual ~FileAndDirPaths() = default;
        virtual bool containsRelativePath(const QString &testedPath) const = 0;
        virtual bool containsPartsOfRelativeDir(const QString &testedDir) const = 0;
        virtual QSet<QString> knownRelativePaths() const = 0;
    };

    struct Strings {
        QString logTitle;
        QString description;
        QString backupTitle;
        QString backupSuccessTitle;
        QString restoreTitle;
        QString restoreSuccessTitle;
    };

    const Category category;
    const QString origDirRoot;
    const QString backupSubDirName;
    std::unique_ptr<FileAndDirPaths> files;
    const Strings strings;
    const bool backupSelectedByDefault;
    QString backupCategoryRoot; // gets updated as backup dir changes

    bool isEntireDir() const
    {
        return !files;
    }

    QString logTitle() const
    {
        return strings.logTitle;
    }

    bool containsRelativePath(const QString &relativePath) const
    {
        return files && files->containsRelativePath(relativePath);
    }

    bool containsPartsOfRelativeDir(const QString &relativeDir) const
    {
        return files && files->containsPartsOfRelativeDir(relativeDir);
    }

    QSet<QString> knownRelativePaths() const
    {
        return files ? files->knownRelativePaths() : QSet<QString>{};
    }

    QSet<QString> existingSourcePaths(const QString &categorySourceDir) const;
};

std::vector<CategoryInfo> makeCategoryInfo();

class CategoryModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ANONYMOUS

    Q_PROPERTY(bool hasSelectedCategories READ hasSelectedCategories NOTIFY hasSelectedCategoriesChanged FINAL)
    Q_PROPERTY(bool hasSuccessfulCategories READ hasSuccessfulCategories NOTIFY hasSuccessfulCategoriesChanged FINAL)
    Q_PROPERTY(QList<QUrl> conflictingPaths READ conflictingPaths NOTIFY conflictingPathsChanged FINAL)

public:
    enum Role {
        CategoryRole = Qt::UserRole + 1,
        CategoryTitleRole,
        CategorySuccessTitleRole,
        CategoryDescriptionRole,
        AvailableRole,
        SelectedRole,
        SuccessfulRole,
        ConflictingPathsRole,
    };
    Q_ENUM(Role)

    CategoryModel(const std::vector<CategoryInfo> &categoryInfo, Operation operation, QObject *parent = nullptr);
    ~CategoryModel() override = default;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool hasSelectedCategories() const;
    bool hasSuccessfulCategories() const;
    QList<QUrl> conflictingPaths() const;

    bool isSelected(Category category) const;

    void setAvailable(Category category, bool available);
    Q_INVOKABLE void setSelected(Category category, bool selected);
    void selectDefaultCategories();
    void setSuccessful(Category category, bool successful);
    void setConflictingPaths(Category category, const QList<QUrl> &paths);
    void resetSuccessful();

Q_SIGNALS:
    void hasSelectedCategoriesChanged();
    void hasSuccessfulCategoriesChanged();
    void conflictingPathsChanged();

private:
    struct Row {
        Category category;
        QString title;
        QString successTitle;
        QString description;
        bool selectedByDefault = false;
        bool available = false;
        bool selected = false;
        bool successful = false;
        QList<QUrl> conflictingPaths;
    };

    int rowFor(Category category) const;

    std::vector<Row> m_rows;
};

} // namespace SafeModeBackup
