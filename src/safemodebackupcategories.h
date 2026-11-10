/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QList>
#include <QObject>
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
    };

    const Category category;
    const QString origDirRoot;
    const QString backupSubDirName;
    std::unique_ptr<FileAndDirPaths> files;
    const Strings strings;
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

class CategoryModel : public QObject
{
    Q_OBJECT
    QML_ANONYMOUS

    Q_PROPERTY(bool hasAvailableCategories READ hasAvailableCategories NOTIFY hasAvailableCategoriesChanged FINAL)
    Q_PROPERTY(bool hasSuccessfulCategories READ hasSuccessfulCategories NOTIFY hasSuccessfulCategoriesChanged FINAL)
    Q_PROPERTY(QList<QUrl> conflictingPaths READ conflictingPaths NOTIFY conflictingPathsChanged FINAL)

public:
    CategoryModel(const std::vector<CategoryInfo> &categoryInfo, QObject *parent = nullptr);
    ~CategoryModel() override = default;

    bool hasAvailableCategories() const;
    bool hasSuccessfulCategories() const;
    QList<QUrl> conflictingPaths() const;

    void setAvailable(Category category, bool available);
    void setSuccessful(Category category, bool successful);
    void setConflictingPaths(Category category, const QList<QUrl> &paths);
    void resetSuccessful();

Q_SIGNALS:
    void hasAvailableCategoriesChanged();
    void hasSuccessfulCategoriesChanged();
    void conflictingPathsChanged();

private:
    struct Row {
        Category category;
        bool available = false;
        bool successful = false;
        QList<QUrl> conflictingPaths;
    };

    int rowFor(Category category) const;

    std::vector<Row> m_rows;
};

} // namespace SafeModeBackup
