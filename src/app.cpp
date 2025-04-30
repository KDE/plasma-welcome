/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024-2025 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <QFileInfo>

#include <KAuthorized>
#include <KConfigGroup>
#include <KDesktopFile>
#include <KOSRelease>

#include "config-plasma-welcome.h"

#include "app.h"

const QMap<App::Mode, App::ModeConfig> App::ModeConfigs = {{App::Update, {QStringLiteral("WelcomeOrder"), {QStringLiteral("org.kde.update")}}},
                                                           {App::Live,
                                                            {QStringLiteral("LiveOrder"),
                                                             {QStringLiteral("org.kde.live"),
                                                              QStringLiteral("org.kde.welcome"),
                                                              QStringLiteral("org.kde.network"),
                                                              QStringLiteral("org.kde.simplebydefault"),
                                                              QStringLiteral("org.kde.powerfulwhenneeded"),
                                                              QStringLiteral("org.kde.discover"),
                                                              QStringLiteral("$distroPages"),
                                                              QStringLiteral("org.kde.enjoy")}}},
                                                           {App::Welcome,
                                                            {QStringLiteral("WelcomeOrder"),
                                                             {QStringLiteral("org.kde.welcome"),
                                                              QStringLiteral("org.kde.network"),
                                                              QStringLiteral("org.kde.simplebydefault"),
                                                              QStringLiteral("org.kde.powerfulwhenneeded"),
                                                              QStringLiteral("org.kde.discover"),
                                                              QStringLiteral("$distroPages"),
                                                              QStringLiteral("org.kde.enjoy")}}}};

App::App(QObject *parent)
    : QObject(parent)
    , m_appConfig(new KConfig(QStringLiteral(DISTRO_CUSTOM_CONFIG_FILE), KConfig::SimpleConfig))
    , m_mode(Mode::Welcome)
    , m_pagesModel(new PagesModel(this))
{
    const QFileInfo introTextFile = QFileInfo(QStringLiteral(DISTRO_CUSTOM_INTRO_FILE));
    if (introTextFile.exists()) {
        const KDesktopFile desktopFile(introTextFile.absoluteFilePath());
        m_customIntroText = desktopFile.readName();
        m_customIntroIcon = desktopFile.readIcon();
        m_customIntroIconLink = desktopFile.readUrl();
        m_customIntroIconCaption = desktopFile.readComment();
    }
}

void App::setMode(App::Mode mode)
{
    m_mode = mode;
}

void App::loadPages(const QStringList &requestedPages)
{
    QStringList pages;
    if (m_mode == Mode::Pages) {
        pages = requestedPages;
    } else {
        const auto modeConfig = ModeConfigs.value(m_mode);
        KConfigGroup pageConfig = m_appConfig->group("Pages");
        // TODO: If key is "", what happens? would be default for any mode not in map
        pages = pageConfig.readEntry(modeConfig.configKey, modeConfig.pageIds);
    }

    if (pages.count() == 0) {
        qWarning() << "No pages loaded with mode" << m_mode;
    }

    if (m_mode == Mode::Update && pages.count() > 1) {
        qWarning() << "Update mode provides a custom footer and should not have more than one page";
    }

    m_pagesModel->load(pages);
}

QStringList App::availablePages() const
{
    return m_pagesModel->availablePages();
}

PagesModel *App::pagesModel() const
{
    return m_pagesModel; // TODO: rm?
}

QString App::installPrefix() const
{
    return QString::fromLatin1(PLASMA_WELCOME_INSTALL_DIR);
}

// Workaround for lack of appstream info in snaps for advertised items on Discover page
bool App::isDistroSnapOnly() const
{
    return KOSRelease().extraValue("UBUNTU_VARIANT") == QStringLiteral("core");
}

bool App::kcmAvailable(const QString &kcm) const
{
    KPluginMetaData data(QStringLiteral("plasma/kcms/systemsettings/%1").arg(kcm));
    return data.isValid() && KAuthorized::authorizeControlModule(kcm + QLatin1String(".desktop"));
}

#include "moc_app.cpp"
