/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QSet>
#include <QString>
#include <qqmlintegration.h>

#include <memory>
#include <vector>

namespace SafeModeBackup
{
Q_NAMESPACE
QML_ELEMENT

enum class Category {
    PlasmaConfig = 0x1,
    NonPlasmaConfig = 0x2,
    State = 0x4,
    Data = 0x8,
};
Q_FLAG_NS(Category)
using Categories = QFlags<Category>;

struct CategoryInfo {
    class FileAndDirPaths
    {
    public:
        virtual ~FileAndDirPaths() = default;
        virtual bool containsRelativePath(const QString &testedPath) const = 0;
        virtual bool containsPartsOfRelativeDir(const QString &testedDir) const = 0;
        virtual QSet<QString> knownRelativePaths() const = 0;
    };

    const Category category;
    const QString localizedName;
    const QString origDirRoot;
    const QString backupSubDirName;
    std::unique_ptr<FileAndDirPaths> files;
    QString backupCategoryRoot; // gets updated as backup dir changes

    bool isEntireDir() const
    {
        return files ? false : true;
    }
};

std::vector<CategoryInfo> makeCategoryInfo();

QSet<QString> existingSourcePaths(const CategoryInfo &categoryInfo, const QString &categorySourceDir);

} // namespace SafeModeBackup
