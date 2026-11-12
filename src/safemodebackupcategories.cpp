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

CategoryTree makeCategoryTree(const QString &homeDir)
{
    const QString origConfigDir = QDir::cleanPath(QFile::decodeName(qgetenv("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME")));
    const QString origDataDir = QDir::cleanPath(QFile::decodeName(qgetenv("KDE_SAFEMODE_ORIG_XDG_DATA_HOME")));
    const QString origStateDir = QDir::cleanPath(QFile::decodeName(qgetenv("KDE_SAFEMODE_ORIG_XDG_STATE_HOME")));
    const QString flatpakDir = homeDir.isEmpty() ? QString() : (homeDir + "/.var/app"_L1);

    auto plasmaConfigPaths = std::make_unique<KnownFileAndDirPaths>(makePlasmaConfigPaths());
    auto nonPlasmaConfigPaths = std::make_unique<RemainingFileAndDirPaths>(plasmaConfigPaths.get());

    CategoryTree tree;

    const auto addGroup = [&tree](const bool backupSelectedByDefault, CategoryGroupInfo::Strings strings) -> CategoryGroup {
        const auto group = static_cast<CategoryGroup>(tree.groups.size());
        tree.groups.emplace_back(group, std::move(strings), backupSelectedByDefault, std::vector<Category>{});
        return group;
    };
    const auto addCategory = [&tree](const CategoryGroup group,
                                     const QString &origDirRoot,
                                     const QString &backupSubDirName,
                                     std::unique_ptr<CategoryInfo::FileAndDirPaths> files,
                                     QString logTitle) {
        if (origDirRoot.isEmpty()) {
            return;
        }
        const auto category = static_cast<Category>(tree.categories.size());
        tree.categories.emplace_back(category, group, origDirRoot, backupSubDirName, std::move(files), std::move(logTitle));
        tree.groups[group].categories.push_back(category);
    };

    const bool BackupSelectedByDefault = true;
    const bool NoBackupByDefault = false;

    const auto plasmaConfigGroup = addGroup( //
        BackupSelectedByDefault,
        CategoryGroupInfo::Strings{
            .description = i18nc("@info possible contents of Plasma-related XDG config files, for reset, backup, and restore",
                                 "System settings, desktop & applet settings."),
            .backupTitle = i18nc("@title:row checkbox label in the Reset Customizations page", "Reset KDE Plasma configuration"),
            .backupSuccessTitle = i18nc("@title:row checkbox label after this category was successfully backed up", "KDE Plasma configuration was backed up"),
            .restoreTitle = i18nc("@title:row checkbox label in the Restore Customizations page", "Restore KDE Plasma configuration"),
            .restoreSuccessTitle = i18nc("@title:row checkbox label after this category was successfully restored", "KDE Plasma configuration was restored"),
        });
    addCategory(plasmaConfigGroup,
                origConfigDir,
                u"config-plasma"_s,
                std::move(plasmaConfigPaths),
                i18nc("@info backup/restore category name used in status logs", "KDE Plasma configuration"));

    const auto appMiscGroup = addGroup( //
        NoBackupByDefault,
        CategoryGroupInfo::Strings{
            .description = i18nc("@info possible contents of non-Plasma XDG config files, for reset, backup, and restore",
                                 "Settings for Flatpak apps and other software apart from KDE Plasma."),
            .backupTitle = i18nc("@title:row checkbox label in the Reset Customizations page", "Reset app & miscellaneous configuration"),
            .backupSuccessTitle =
                i18nc("@title:row checkbox label after this category was successfully backed up", "App & miscellaneous configuration was backed up"),
            .restoreTitle = i18nc("@title:row checkbox label in the Restore Customizations page", "Restore app & miscellaneous configuration"),
            .restoreSuccessTitle =
                i18nc("@title:row checkbox label after this category was successfully restored", "App & miscellaneous configuration was restored"),
        });
    addCategory(appMiscGroup,
                origConfigDir,
                u"config"_s,
                std::move(nonPlasmaConfigPaths),
                i18nc("@info backup/restore category name used in status logs", "Non-Plasma configuration"));
    addCategory(appMiscGroup,
                flatpakDir,
                u"var-app"_s,
                nullptr,
                i18nc("@info backup/restore category name used in status logs", "Flatpak app settings & data"));

    const auto stateGroup = addGroup( //
        BackupSelectedByDefault,
        CategoryGroupInfo::Strings{
            .description = i18nc("@info possible contents of XDG state folder, for reset, backup, and restore",
                                 "Recent file history, restored window sizes, power draw history, …"),
            .backupTitle = i18nc("@title:row checkbox label in the Reset Customizations page", "Reset state"),
            .backupSuccessTitle = i18nc("@title:row checkbox label after this category was successfully backed up", "State was backed up"),
            .restoreTitle = i18nc("@title:row checkbox label in the Restore Customizations page", "Restore state"),
            .restoreSuccessTitle = i18nc("@title:row checkbox label after this category was successfully restored", "State was restored"),
        });
    addCategory(stateGroup, origStateDir, u"state"_s, nullptr, i18nc("@info backup/restore category name used in status logs", "State"));

    const auto dataGroup = addGroup( //
        NoBackupByDefault,
        CategoryGroupInfo::Strings{
            .description = i18nc("@info possible contents of XDG data folder, for reset, backup, and restore",
                                 "Favorites, downloaded extensions, application sessions, custom menu entries, …"),
            .backupTitle = i18nc("@title:row checkbox label in the Reset Customizations page", "Reset desktop & application data"),
            .backupSuccessTitle = i18nc("@title:row checkbox label after this category was successfully backed up", "Desktop & application data was backed up"),
            .restoreTitle = i18nc("@title:row checkbox label in the Restore Customizations page", "Restore desktop & application data"),
            .restoreSuccessTitle = i18nc("@title:row checkbox label after this category was successfully restored", "Desktop & application data was restored"),
        });
    addCategory(dataGroup, origDataDir, u"data"_s, nullptr, i18nc("@info backup/restore category name used in status logs", "Desktop & application data"));

    // Only include non-empty groups. std::erase_if() can't copy structs with const members, so create a new list.
    std::vector<CategoryGroupInfo> nonEmptyGroups;
    nonEmptyGroups.reserve(tree.groups.size());
    for (CategoryGroupInfo &group : tree.groups) {
        if (!group.categories.empty()) {
            nonEmptyGroups.push_back(std::move(group));
        }
    }
    tree.groups = std::move(nonEmptyGroups);

    return tree;
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

CategoryModel::CategoryModel(const CategoryTree &categoryTree, Operation operation, QObject *parent)
    : QAbstractListModel(parent)
{
    m_rows.reserve(categoryTree.groups.size());

    for (const CategoryGroupInfo &info : categoryTree.groups) {
        Row row;
        row.group = info.group;
        row.description = info.strings.description;
        row.categories = info.categories;

        switch (operation) {
        case Operation::Backup:
            row.title = info.strings.backupTitle;
            row.successTitle = info.strings.backupSuccessTitle;
            row.selectedByDefault = info.backupSelectedByDefault;
            break;
        case Operation::Restore:
            row.title = info.strings.restoreTitle;
            row.successTitle = info.strings.restoreSuccessTitle;
            row.selectedByDefault = true;
            break;
        }

        m_rowForGroup.insert(row.group, static_cast<int>(m_rows.size()));
        for (const Category category : row.categories) {
            m_groupForCategory.insert(category, row.group);
            m_categoryState.insert(category, CategoryState{});
        }

        m_rows.push_back(std::move(row));
    }
}

int CategoryModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : static_cast<int>(m_rows.size());
}

QVariant CategoryModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= rowCount()) {
        return {};
    }

    const Row &row = m_rows[index.row()];

    switch (role) {
    case Qt::DisplayRole:
    case TitleRole:
        return row.title;
    case CategoryGroupRole:
        return row.group;
    case SuccessTitleRole:
        return row.successTitle;
    case DescriptionRole:
        return row.description;
    case AvailableRole:
        return groupAvailable(row);
    case SelectionStateRole:
        return groupSelectionState(row);
    case SuccessfulRole:
        return groupSuccessful(row);
    case ConflictingPathsRole:
        return QVariant::fromValue(groupConflictingPaths(row));
    default:
        return {};
    }
}

QHash<int, QByteArray> CategoryModel::roleNames() const
{
    return {
        {CategoryGroupRole, "categoryGroup"},
        {TitleRole, "title"},
        {SuccessTitleRole, "successTitle"},
        {DescriptionRole, "description"},
        {AvailableRole, "isAvailable"},
        {SelectionStateRole, "selectionState"},
        {SuccessfulRole, "wasSuccessful"},
        {ConflictingPathsRole, "conflictingPaths"},
    };
}

bool CategoryModel::hasSelectedCategories() const
{
    for (const CategoryState &state : m_categoryState) {
        if (state.selected) {
            return true;
        }
    }
    return false;
}

bool CategoryModel::hasSuccessfulCategories() const
{
    for (const Row &row : m_rows) {
        if (groupSuccessful(row)) {
            return true;
        }
    }
    return false;
}

QList<QUrl> CategoryModel::conflictingPaths() const
{
    QList<QUrl> paths;
    for (const Row &row : m_rows) {
        paths += groupConflictingPaths(row);
    }
    return paths;
}

int CategoryModel::rowIndexForGroup(CategoryGroup group) const
{
    auto it = m_rowForGroup.constFind(group);
    return it != m_rowForGroup.constEnd() ? *it : -1;
}

bool CategoryModel::isCategorySelected(Category category) const
{
    auto it = m_categoryState.constFind(category);
    return it != m_categoryState.constEnd() && it->selected;
}

bool CategoryModel::groupAvailable(const Row &row) const
{
    for (const Category category : row.categories) {
        auto it = m_categoryState.constFind(category);
        if (it != m_categoryState.constEnd() && it->available) {
            return true;
        }
    }
    return false;
}

bool CategoryModel::groupSuccessful(const Row &row) const
{
    bool anySucceeded = false;

    for (const Category category : row.categories) {
        auto it = m_categoryState.constFind(category);
        if (it == m_categoryState.constEnd()) {
            continue;
        }

        if (it->result == Result::Failed || it->result == Result::Operating) {
            return false;
        }
        if (it->result == Result::Succeeded) {
            anySucceeded = true;
        }
    }

    return anySucceeded;
}

Qt::CheckState CategoryModel::groupSelectionState(const Row &row) const
{
    bool anyAvailable = false;
    bool anySelected = false;
    bool anyUnselected = false;

    for (const Category category : row.categories) {
        auto it = m_categoryState.constFind(category);
        if (it == m_categoryState.constEnd() || !it->available) {
            continue;
        }

        anyAvailable = true;
        if (it->selected) {
            anySelected = true;
        } else {
            anyUnselected = true;
        }
    }

    if (!anyAvailable || !anySelected) {
        return Qt::Unchecked;
    }
    return anyUnselected ? Qt::PartiallyChecked : Qt::Checked;
}

QList<QUrl> CategoryModel::groupConflictingPaths(const Row &row) const
{
    QList<QUrl> paths;
    for (const Category category : row.categories) {
        auto it = m_categoryState.constFind(category);
        if (it != m_categoryState.constEnd() && it->selected) {
            paths += it->conflictingPaths;
        }
    }
    return paths;
}

void CategoryModel::emitGroupChanged(CategoryGroup group, const QList<int> &roles)
{
    const int rowIndex = rowIndexForGroup(group);
    if (rowIndex < 0) {
        return;
    }

    const QModelIndex modelIndex = index(rowIndex);
    Q_EMIT dataChanged(modelIndex, modelIndex, roles);
}

void CategoryModel::setCategoryAvailable(Category category, bool available)
{
    auto it = m_categoryState.find(category);
    if (it == m_categoryState.end() || it->available == available) {
        return;
    }

    // This model does not allow selecting an unavailable category.
    const bool selectionCleared = it->available && !available && it->selected;

    it->available = available;
    if (selectionCleared) {
        it->selected = false;
    }

    if (selectionCleared) {
        emitGroupChanged(m_groupForCategory.value(category), {AvailableRole, SelectionStateRole, ConflictingPathsRole});
        Q_EMIT hasSelectedCategoriesChanged();
        Q_EMIT conflictingPathsChanged();
    } else {
        // A single-category availability change can also affect the group selection tristate.
        emitGroupChanged(m_groupForCategory.value(category), {AvailableRole, SelectionStateRole});
    }
}

void CategoryModel::setCategorySelected(Category category, bool selected)
{
    auto it = m_categoryState.find(category);
    if (it == m_categoryState.end() || it->selected == selected) {
        return;
    }

    // This model does not allow selecting an unavailable category. If needed, set it available first.
    if (selected && !it->available) {
        return;
    }

    it->selected = selected;

    emitGroupChanged(m_groupForCategory.value(category), {SelectionStateRole});
    Q_EMIT hasSelectedCategoriesChanged();
    Q_EMIT conflictingPathsChanged();
}

void CategoryModel::setGroupSelected(CategoryGroup group, Qt::CheckState checkState)
{
    const int rowIndex = rowIndexForGroup(group);
    if (rowIndex < 0) {
        return;
    }

    const bool selected = checkState != Qt::Unchecked;
    bool changed = false;

    for (const Category category : m_rows[rowIndex].categories) {
        auto it = m_categoryState.find(category);
        if (it == m_categoryState.end() || it->selected == selected) {
            continue;
        }
        if (selected && !it->available) {
            continue;
        }

        it->selected = selected;
        changed = true;
    }

    if (changed) {
        emitGroupChanged(group, {SelectionStateRole});
        Q_EMIT hasSelectedCategoriesChanged();
        Q_EMIT conflictingPathsChanged();
    }
}

void CategoryModel::selectDefaultCategories()
{
    bool changed = false;

    for (size_t i = 0; i < m_rows.size(); ++i) {
        const Row &row = m_rows[i];
        bool rowChanged = false;

        for (const Category category : row.categories) {
            auto it = m_categoryState.find(category);
            if (it == m_categoryState.end()) {
                continue;
            }

            const bool selected = it->available && row.selectedByDefault;
            if (it->selected == selected) {
                continue;
            }

            it->selected = selected;
            rowChanged = true;
            changed = true;
        }

        if (rowChanged) {
            const QModelIndex modelIndex = index(static_cast<int>(i));
            Q_EMIT dataChanged(modelIndex, modelIndex, {SelectionStateRole});
        }
    }

    if (changed) {
        Q_EMIT hasSelectedCategoriesChanged();
        Q_EMIT conflictingPathsChanged();
    }
}

void CategoryModel::setCategoryResult(Category category, Result result)
{
    auto it = m_categoryState.find(category);
    if (it == m_categoryState.end() || it->result == result) {
        return;
    }

    it->result = result;

    emitGroupChanged(m_groupForCategory.value(category), {SuccessfulRole});
    Q_EMIT hasSuccessfulCategoriesChanged();
}

void CategoryModel::setCategoryConflictingPaths(Category category, const QList<QUrl> &paths)
{
    auto it = m_categoryState.find(category);
    if (it == m_categoryState.end() || it->conflictingPaths == paths) {
        return;
    }

    it->conflictingPaths = paths;

    emitGroupChanged(m_groupForCategory.value(category), {ConflictingPathsRole});

    if (it->selected) {
        Q_EMIT conflictingPathsChanged();
    }
}

void CategoryModel::resetCategoryResults()
{
    resetCategoryResults({Result::Succeeded, Result::Failed, Result::Operating});
}

void CategoryModel::resetCategoryResults(std::initializer_list<Result> which)
{
    bool anySuccessfulChanged = false;

    for (size_t i = 0; i < m_rows.size(); ++i) {
        const Row &row = m_rows[i];
        const bool wasSuccessful = groupSuccessful(row);
        bool rowChanged = false;

        for (const Category category : row.categories) {
            auto it = m_categoryState.find(category);
            if (it == m_categoryState.end()) {
                continue;
            }

            if (std::ranges::contains(which, it->result)) {
                it->result = Result::NotAttempted;
                rowChanged = true;
            }
        }

        if (!rowChanged) {
            continue;
        }
        if (groupSuccessful(row) != wasSuccessful) {
            anySuccessfulChanged = true;
        }
        const QModelIndex modelIndex = index(static_cast<int>(i));
        Q_EMIT dataChanged(modelIndex, modelIndex, {SuccessfulRole});
    }

    if (anySuccessfulChanged) {
        Q_EMIT hasSuccessfulCategoriesChanged();
    }
}

} // namespace SafeModeBackup

#include "moc_safemodebackupcategories.cpp"
