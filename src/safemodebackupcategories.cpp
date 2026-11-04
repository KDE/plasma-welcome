/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "safemodebackupcategories.h"

#include <KLocalizedString>

#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QtEnvironmentVariables>

using namespace Qt::StringLiterals;

namespace SafeModeBackup
{
QSet<QString> makePlasmaConfigPaths()
{
    return QSet<QString>{
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
        "baloofileinformationrc"_L1,
        "baloofilerc"_L1,
        "bluedevilglobalrc"_L1,
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
        "kmenueditrc"_L1,
        "kmixctrlrc"_L1,
        "kmixrc"_L1,
        "knighttimerc"_L1,
        "krdpserverrc"_L1,
        "krunnerrc"_L1,
        "kscreenlockerrc"_L1,
        "kservicemenurc"_L1,
        "ksmserverrc"_L1,
        "ksysguardrc"_L1,
        "ktimezonedrc"_L1,
        "ktrashrc"_L1,
        "kuprc"_L1,
        "kwalletrc"_L1,
        "kwinoutputconfig.json"_L1,
        "kwinrc"_L1,
        "kxkbrc"_L1,
        "mimeapps.list"_L1,
        "plasma.emojierrc"_L1,
        "plasma-localerc"_L1,
        "plasma-nm"_L1,
        "plasma-org.kde.plasma.desktop-appletsrc"_L1,
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

QString withoutTrailingSlash(const QByteArray &path)
{
    return path.length() > 1 && path.endsWith('/') ? path.chopped(1) : path;
}

class KnownFileAndDirPaths : public CategoryInfo::FileAndDirPaths
{
public:
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

class RemainingFileAndDirPaths : public CategoryInfo::FileAndDirPaths
{
public:
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
    QString origConfigDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME"));
    QString origDataDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_DATA_HOME"));
    QString origStateDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_STATE_HOME"));

    auto plasmaConfigPaths = std::make_unique<KnownFileAndDirPaths>(makePlasmaConfigPaths());
    auto nonPlasmaConfigPaths = std::make_unique<RemainingFileAndDirPaths>(plasmaConfigPaths.get());

    std::vector<CategoryInfo> categoryInfo;

    categoryInfo.emplace_back(Category::PlasmaConfig, //
                              i18nc("name for backup category (in logs, etc.)", "Plasma Configuration"),
                              origConfigDir,
                              u"config-plasma"_s,
                              std::move(plasmaConfigPaths));
    categoryInfo.emplace_back(Category::NonPlasmaConfig, //
                              i18nc("name for backup category (in logs, etc.)", "App & Miscellaneous Configuration"),
                              origConfigDir,
                              u"config"_s,
                              std::move(nonPlasmaConfigPaths));
    categoryInfo.emplace_back(Category::State, //
                              i18nc("name for backup category (in logs, etc.)", "State"),
                              origStateDir,
                              u"state"_s);
    categoryInfo.emplace_back(Category::Data, //
                              i18nc("name for backup category (in logs, etc.)", "Desktop & Application Data"),
                              origDataDir,
                              u"data"_s);

    return categoryInfo;
}

QSet<QString> existingSourcePaths(const CategoryInfo &categoryInfo, const QString &categorySourceDir)
{
    if (categoryInfo.isEntireDir()) {
        return QDir(categorySourceDir).exists() ? QSet<QString>{"."_L1} : QSet<QString>{};
    }

    Q_ASSERT(categoryInfo.files != nullptr);

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
                if (categoryInfo.files->containsRelativePath(relativePath)) {
                    sourcePaths.insert(relativePath);
                } else if (categoryInfo.files->containsPartsOfRelativeDir(relativePath)) {
                    nextRecursedDirs.append(entry.filePath());
                }
            }
        }
        recursedDirs = nextRecursedDirs;
    }
    return sourcePaths;
}
} // namespace SafeModeBackup

#include "moc_safemodebackupcategories.cpp"
