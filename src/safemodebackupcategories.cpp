/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "safemodebackupcategories.h"

#include <QDir>
#include <QFile>
#include <QtEnvironmentVariables>

using namespace Qt::StringLiterals;

namespace SafeModeBackup
{
std::vector<CategoryInfo> makeCategoryInfo()
{
    const QString origConfigDir = QDir::cleanPath(QFile::decodeName(qgetenv("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME")));
    const QString origDataDir = QDir::cleanPath(QFile::decodeName(qgetenv("KDE_SAFEMODE_ORIG_XDG_DATA_HOME")));
    const QString origStateDir = QDir::cleanPath(QFile::decodeName(qgetenv("KDE_SAFEMODE_ORIG_XDG_STATE_HOME")));

    std::vector<CategoryInfo> categoryInfo;

    const auto addCategory = [&categoryInfo](const QString &origDirRoot, const QString &backupSubDirName) {
        const auto category = static_cast<Category>(categoryInfo.size());
        categoryInfo.emplace_back(category, origDirRoot, backupSubDirName);
    };

    addCategory(origConfigDir, u"config"_s);
    addCategory(origStateDir, u"state"_s);
    addCategory(origDataDir, u"data"_s);

    return categoryInfo;
}

QSet<QString> CategoryInfo::existingSourcePaths(const QString &categorySourceDir) const
{
    return QDir(categorySourceDir).exists() ? QSet<QString>{"."_L1} : QSet<QString>{};
}

CategoryModel::CategoryModel(const std::vector<CategoryInfo> &categoryInfo, QObject *parent)
    : QObject(parent)
{
    m_rows.reserve(categoryInfo.size());

    for (const CategoryInfo &info : categoryInfo) {
        Row row;
        row.category = info.category;
        m_rows.push_back(std::move(row));
    }
}

bool CategoryModel::hasAvailableCategories() const
{
    for (const Row &row : m_rows) {
        if (row.available) {
            return true;
        }
    }
    return false;
}

bool CategoryModel::hasSuccessfulCategories() const
{
    for (const Row &row : m_rows) {
        if (row.successful) {
            return true;
        }
    }
    return false;
}

QList<QUrl> CategoryModel::conflictingPaths() const
{
    QList<QUrl> paths;
    for (const Row &row : m_rows) {
        if (row.available) {
            paths += row.conflictingPaths;
        }
    }
    return paths;
}

int CategoryModel::rowFor(Category category) const
{
    for (size_t i = 0; i < m_rows.size(); ++i) {
        if (m_rows[i].category == category) {
            return static_cast<int>(i);
        }
    }
    return -1;
}

void CategoryModel::setAvailable(Category category, bool available)
{
    const int rowIndex = rowFor(category);
    if (rowIndex < 0) {
        return;
    }

    Row &row = m_rows[rowIndex];
    if (row.available == available) {
        return;
    }

    row.available = available;

    Q_EMIT hasAvailableCategoriesChanged();
}

void CategoryModel::setSuccessful(Category category, bool successful)
{
    const int rowIndex = rowFor(category);
    if (rowIndex < 0) {
        return;
    }

    Row &row = m_rows[rowIndex];
    if (row.successful == successful) {
        return;
    }

    row.successful = successful;

    Q_EMIT hasSuccessfulCategoriesChanged();
}

void CategoryModel::resetSuccessful()
{
    bool changed = false;

    for (size_t i = 0; i < m_rows.size(); ++i) {
        if (!m_rows[i].successful) {
            continue;
        }

        m_rows[i].successful = false;
        changed = true;
    }

    if (changed) {
        Q_EMIT hasSuccessfulCategoriesChanged();
    }
}

void CategoryModel::setConflictingPaths(Category category, const QList<QUrl> &paths)
{
    const int rowIndex = rowFor(category);
    if (rowIndex < 0) {
        return;
    }

    Row &row = m_rows[rowIndex];
    if (row.conflictingPaths == paths) {
        return;
    }

    row.conflictingPaths = paths;

    Q_EMIT conflictingPathsChanged();
}

} // namespace SafeModeBackup

#include "moc_safemodebackupcategories.cpp"
