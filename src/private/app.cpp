/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <QDir>

#include <KDesktopFile>
#include <KOSRelease>
#include <KPluginMetaData>

#include "config-plasma-welcome.h"

#include "app.h"

App::App(QObject *parent)
    : QObject(parent)
{
    m_mode = Mode::Welcome;

    // Welcome page customisation
    m_customIntroText = QString();
    m_customIntroIcon = QString();
    m_customIntroIconCaption = QString();

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

void App::setPages(const QStringList &pages)
{
    m_pages = pages;
}

QString App::installPrefix() const
{
    return QString::fromLatin1(PLASMA_WELCOME_INSTALL_DIR);
}

QString App::distroPagesDir() const
{
    return QString::fromLatin1(DISTRO_CUSTOM_PAGE_FOLDER);
}

QStringList App::distroPages() const
{
    const QString dirname = QStringLiteral(DISTRO_CUSTOM_PAGE_FOLDER);
    const QDir distroPageDir = QDir(dirname);

    if (!distroPageDir.exists() || distroPageDir.isEmpty()) {
        return {};
    }

    QStringList pages = distroPageDir.entryList(QDir::NoDotAndDotDot | QDir::Files | QDir::Readable, QDir::Name);
    for (QString &page : pages) {
        page = QStringLiteral("file://") + dirname + page;
    }

    return pages;
}

bool App::userFeedbackAvailable() const
{
    KPluginMetaData data(QStringLiteral("plasma/kcms/systemsettings/kcm_feedback"));
    return data.isValid();
}

// Workaround for lack of appstream info in snaps for advertised items on Discover page
bool App::isDistroSnapOnly() const
{
    return KOSRelease().extraValue("UBUNTU_VARIANT") == QStringLiteral("core");
}

#include "moc_app.cpp"
