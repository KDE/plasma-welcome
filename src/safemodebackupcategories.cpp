/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "safemodebackupcategories.h"

#include <KLocalizedString>

#include <QDir>
#include <QDirListing>
#include <QFile>
#include <QFileInfo>
#include <QtEnvironmentVariables>

#include <algorithm>

using namespace Qt::StringLiterals;

namespace SafeModeBackup
{
QSet<QString> makePlasmaConfigPaths()
{
    return QSet<QString>{
        // folders
        "autostart"_L1,
        "fontconfig"_L1,
        "glib-2.0"_L1,
        "gtk-2.0"_L1,
        "gtk-3.0"_L1,
        "gtk-4.0"_L1,
        "KDE/kunifiedpush-distributor.conf"_L1,
        "KDE/Sonnet.conf"_L1,
        "KDE/UserFeedback.conf"_L1,
        "kde.org/systemsettings.conf"_L1,
        "kdeconnect"_L1,
        "kdedefaults"_L1,
        "menus"_L1,
        "plasma-workspace"_L1,
        "qtvirtualkeyboard"_L1,
        "session"_L1,
        "systemd"_L1,

        // files
        "baloofileinformationrc"_L1,
        "baloofilerc"_L1,
        "bluedevilglobalrc"_L1,
        "breezerc"_L1,
        "device_automounter_kcmrc"_L1,
        "discoverrc"_L1,
        "dolphinrc"_L1,
        "drkonqirc"_L1,
        "filetypesrc"_L1,
        "gtkrc"_L1,
        "gtkrc-2.0"_L1,
        "kaccessrc"_L1,
        "kactivitymanagerd-pluginsrc"_L1,
        "kactivitymanagerd-statsrc"_L1,
        "kactivitymanagerd-switcher"_L1,
        "kactivitymanagerdrc"_L1,
        "kcminputrc"_L1,
        "kcmshell6rc"_L1,
        "kconf_updaterc"_L1,
        "kded5rc"_L1,
        "kdeglobals"_L1,
        "kdialogrc"_L1,
        "kfontinstuirc"_L1,
        "kgammarc"_L1,
        "kglobalshortcutsrc"_L1,
        "khotkeysrc"_L1, // obsolete
        "kinfocenterrc"_L1,
        "kiorc"_L1,
        "klipperrc"_L1,
        "kmenueditrc"_L1,
        "kmixctrlrc"_L1,
        "kmixrc"_L1,
        "knighttimerc"_L1,
        "krdpserverrc"_L1,
        "krunnerrc"_L1,
        "kscreenlockerrc"_L1,
        "kservicemenurc"_L1,
        "ksmserverrc"_L1,
        "ksplashrc"_L1,
        "ksysguardrc"_L1,
        "ktimezonedrc"_L1,
        "ktrashrc"_L1,
        "kuprc"_L1,
        "Kvantum"_L1,
        "kwalletrc"_L1,
        "kwinoutputconfig.json"_L1,
        "kwinrc"_L1,
        "kwinrulesrc"_L1,
        "kxkbrc"_L1,
        "mimeapps.list"_L1,
        "oxygenrc"_L1,
        "plasma.emojierrc"_L1,
        "plasma_calendar_holiday_regions"_L1,
        "plasma-localerc"_L1,
        "plasma-nm"_L1,
        "plasma-org.kde.plasma.desktop-appletsrc"_L1,
        "plasma-systemmonitorrc"_L1,
        "plasma-welcomerc"_L1,
        "PlasmaDiscoverUpdates"_L1,
        "plasmanotifyrc"_L1,
        "plasmaparc"_L1,
        "plasmarc"_L1,
        "plasmashellrc"_L1,
        "plasmoidviewer-appletsrc"_L1,
        "powerdevil.notifyrc"_L1,
        "powerdevilrc"_L1,
        "powermanagementprofilesrc"_L1, // obsolete
        "print-manager"_L1,
        "QtProject.conf"_L1,
        "spectaclerc"_L1,
        "systemmonitorrc"_L1,
        "systemsettingsrc"_L1,
        "touchpadrc"_L1,
        "touchpadxlibinputrc"_L1, // obsolete
        "trashrc"_L1,
        "Trolltech.conf"_L1,
        "user-dirs.dirs"_L1,
        "user-dirs.locale"_L1,
        "xdg-desktop-portal-kderc"_L1,
    };
}

struct KnownFileAndDirPaths : public CategoryInfo::FileAndDirPaths {
    KnownFileAndDirPaths(const QSet<QString> &relativePaths)
        : m_relativePaths(relativePaths)
    {
    }

    bool containsRelativePath(const QString &testedRelativePath) const override
    {
        if (m_relativePaths.contains(testedRelativePath)) {
            return true;
        } else if (QString parentPath = QFileInfo(testedRelativePath).path(); parentPath != "."_L1 && parentPath != ".."_L1) {
            return containsRelativePath(parentPath);
        } else {
            return false;
        }
    }

    bool containsPartsOfRelativeDir(const QString &testedRelativeDir) const override
    {
        if (m_relativePaths.contains(testedRelativeDir)) {
            return false; // this contains the entire directory, not just parts of it
        }
        return std::ranges::any_of(m_relativePaths, [testedRelativeDir](const QString &path) {
            return path.startsWith(testedRelativeDir) && path.at(testedRelativeDir.size()) == '/'_L1;
        });
    }

    QSet<QString> knownRelativePaths() const override
    {
        return m_relativePaths;
    }

private:
    QSet<QString> m_relativePaths;
};

struct RemainingFileAndDirPaths : public CategoryInfo::FileAndDirPaths {
    RemainingFileAndDirPaths(const CategoryInfo::FileAndDirPaths *excludedFiles)
        : m_excludedFiles(excludedFiles)
    {
    }

    bool containsRelativePath(const QString &testedPath) const override
    {
        // If m_excludedFiles contains parts of the tested path (interpreted as a directory),
        // then we must also return false here, so we don't claim the entire directory.
        return !m_excludedFiles->containsRelativePath(testedPath) && !m_excludedFiles->containsPartsOfRelativeDir(testedPath);
    }

    bool containsPartsOfRelativeDir(const QString &testedDir) const override
    {
        // If m_excludedFiles encompasses the entire tested directory, containsRelativePath() will be true.
        // It returns false for partially claimed directories; we'll claim the remaining files in there.
        return !m_excludedFiles->containsRelativePath(testedDir);
    }

    QSet<QString> knownRelativePaths() const override
    {
        return {};
    }

private:
    const CategoryInfo::FileAndDirPaths *m_excludedFiles;
};

std::vector<CategoryInfo> makeCategoryInfo()
{
    const QString origConfigDir = QDir::cleanPath(QFile::decodeName(qgetenv("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME")));
    const QString origDataDir = QDir::cleanPath(QFile::decodeName(qgetenv("KDE_SAFEMODE_ORIG_XDG_DATA_HOME")));
    const QString origStateDir = QDir::cleanPath(QFile::decodeName(qgetenv("KDE_SAFEMODE_ORIG_XDG_STATE_HOME")));

    auto plasmaConfigPaths = std::make_unique<KnownFileAndDirPaths>(makePlasmaConfigPaths());
    auto nonPlasmaConfigPaths = std::make_unique<RemainingFileAndDirPaths>(plasmaConfigPaths.get());

    std::vector<CategoryInfo> categoryInfo;

    const auto addCategory = [&categoryInfo](const QString &origDirRoot,
                                             const QString &backupSubDirName,
                                             std::unique_ptr<CategoryInfo::FileAndDirPaths> files,
                                             CategoryInfo::Strings strings) {
        const auto category = static_cast<Category>(categoryInfo.size());
        categoryInfo.emplace_back(category, origDirRoot, backupSubDirName, std::move(files), std::move(strings));
    };

    addCategory( //
        origConfigDir,
        u"config-plasma"_s,
        std::move(plasmaConfigPaths),
        CategoryInfo::Strings{
            .logTitle = i18nc("@info backup/restore category name used in status logs", "KDE Plasma configuration"),
        });
    addCategory( //
        origConfigDir,
        u"config"_s,
        std::move(nonPlasmaConfigPaths),
        CategoryInfo::Strings{
            .logTitle = i18nc("@info backup/restore category name used in status logs", "App & miscellaneous configuration"),
        });
    addCategory( //
        origStateDir,
        u"state"_s,
        nullptr,
        CategoryInfo::Strings{
            .logTitle = i18nc("@info backup/restore category name used in status logs", "State"),
        });
    addCategory( //
        origDataDir,
        u"data"_s,
        nullptr,
        CategoryInfo::Strings{
            .logTitle = i18nc("@info backup/restore category name used in status logs", "Desktop & application data"),
        });

    return categoryInfo;
}

QSet<QString> CategoryInfo::existingSourcePaths(const QString &categorySourceDir) const
{
    if (isEntireDir()) {
        return QDir(categorySourceDir).exists() ? QSet<QString>{"."_L1} : QSet<QString>{};
    }

    Q_ASSERT(files != nullptr);

    using F = QDirListing::IteratorFlag;

    // Recurse directories only if they contain files that are relevant for this category.
    QStringList recursedDirs{categorySourceDir};
    QStringList nextRecursedDirs;
    QSet<QString> sourcePaths;

    while (!recursedDirs.isEmpty()) {
        nextRecursedDirs.clear();

        for (const auto &dir : recursedDirs) {
            for (const QDirListing::DirEntry &entry : QDirListing(dir, F::IncludeHidden | F::IncludeBrokenSymlinks | F::ExcludeOther)) {
                QString relativePath = QDir(categorySourceDir).relativeFilePath(entry.filePath());
                if (containsRelativePath(relativePath)) {
                    sourcePaths.insert(relativePath);
                } else if (containsPartsOfRelativeDir(relativePath)) {
                    nextRecursedDirs.append(entry.filePath());
                }
            }
        }
        recursedDirs = nextRecursedDirs;
    }
    return sourcePaths;
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
