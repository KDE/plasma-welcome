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

#include <initializer_list>
#include <memory>
#include <vector>

namespace SafeModeBackup
{
// Opaque identifiers for operation and UI selections, respectively. Values are assigned in makeCategoryTree().
using Category = int;
using CategoryGroup = int;

enum class Operation {
    Backup,
    Restore,
};

// Most recent operation outcome for a Category.
enum class Result {
    NotAttempted,
    Succeeded,
    Failed,
    Operating,
};

struct CategoryInfo {
    struct FileAndDirPaths {
        virtual ~FileAndDirPaths() = default;
        virtual bool containsRelativePath(const QString &testedPath) const = 0;
        virtual bool containsPartsOfRelativeDir(const QString &testedDir) const = 0;
        virtual QSet<QString> knownRelativePaths() const = 0;
    };

    const Category category;
    const CategoryGroup group;
    const QString origDirRoot;
    const QString backupSubDirName;
    std::unique_ptr<FileAndDirPaths> files;
    const QString logTitle;
    QString backupCategoryRoot; // gets updated as backup dir changes

    bool isEntireDir() const
    {
        return !files;
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

struct CategoryGroupInfo {
    struct Strings {
        QString description;
        QString backupTitle;
        QString backupSuccessTitle;
        QString restoreTitle;
        QString restoreSuccessTitle;
    };

    const CategoryGroup group;
    const Strings strings;
    const bool backupSelectedByDefault;
    std::vector<Category> categories;
};

struct CategoryTree {
    std::vector<CategoryGroupInfo> groups;
    std::vector<CategoryInfo> categories;
};

CategoryTree makeCategoryTree(const QString &homeDir);

class CategoryModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ANONYMOUS

    Q_PROPERTY(bool hasSelectedCategories READ hasSelectedCategories NOTIFY hasSelectedCategoriesChanged FINAL)
    Q_PROPERTY(bool hasSuccessfulCategories READ hasSuccessfulCategories NOTIFY hasSuccessfulCategoriesChanged FINAL)
    Q_PROPERTY(QList<QUrl> conflictingPaths READ conflictingPaths NOTIFY conflictingPathsChanged FINAL)

public:
    enum Role {
        CategoryGroupRole = Qt::UserRole + 1,
        TitleRole,
        SuccessTitleRole,
        DescriptionRole,
        AvailableRole,
        SelectionStateRole,
        SuccessfulRole,
        ConflictingPathsRole,
    };
    Q_ENUM(Role)

    CategoryModel(const CategoryTree &categoryTree, Operation operation, QObject *parent = nullptr);
    ~CategoryModel() override = default;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool hasSelectedCategories() const;
    bool hasSuccessfulCategories() const;
    QList<QUrl> conflictingPaths() const;

    bool isCategorySelected(Category category) const;

    void setCategoryAvailable(Category category, bool available);
    Q_INVOKABLE void setCategorySelected(Category category, bool selected);
    void setCategoryResult(Category category, Result result);
    void setCategoryConflictingPaths(Category category, const QList<QUrl> &paths);

    Q_INVOKABLE void setGroupSelected(CategoryGroup group, Qt::CheckState checkState);

    void selectDefaultCategories();
    void resetCategoryResults();
    void resetCategoryResults(std::initializer_list<Result> which);

Q_SIGNALS:
    void hasSelectedCategoriesChanged();
    void hasSuccessfulCategoriesChanged();
    void conflictingPathsChanged();

private:
    struct Row {
        CategoryGroup group;
        QString title;
        QString successTitle;
        QString description;
        bool selectedByDefault = false;
        std::vector<Category> categories;
    };

    struct CategoryState {
        bool available = false;
        bool selected = false;
        Result result = Result::NotAttempted;
        QList<QUrl> conflictingPaths;
    };

    int rowIndexForGroup(CategoryGroup group) const;
    bool groupAvailable(const Row &row) const;
    bool groupSuccessful(const Row &row) const;
    Qt::CheckState groupSelectionState(const Row &row) const;
    QList<QUrl> groupConflictingPaths(const Row &row) const;
    void emitGroupChanged(CategoryGroup group, const QList<int> &roles);

    std::vector<Row> m_rows;
    QHash<Category, CategoryGroup> m_groupForCategory;
    QHash<CategoryGroup, int> m_rowForGroup;
    QHash<Category, CategoryState> m_categoryState;
};

} // namespace SafeModeBackup
