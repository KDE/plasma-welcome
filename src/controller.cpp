/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <QDir>
#include <QFileInfo>
#include <QNetworkInterface>
#include <QStandardPaths>
#include <QString>

#include "config-plasma-welcome.h"
#include "controller.h"
#include "plasma-welcome-version.h"

#include <KDesktopFile>
#include <KIO/ApplicationLauncherJob>
#include <KIO/CommandLauncherJob>
#include <KLocalizedString>
#include <KNotificationJobUiDelegate>
#include <KOSRelease>
#include <KPluginMetaData>
#include <KService>

Controller::Controller()
{
    m_mode = Mode::Welcome;

    // Version
    m_version = QVersionNumber::fromString(QString::fromLatin1(PLASMA_WELCOME_VERSION_STRING));
    m_patchVersion = m_version.microVersion();

    // Release URL
    if constexpr (PLASMA_WELCOME_VERSION_PATCH >= 90) {
        // Beta version
        m_releaseUrl = QStringLiteral("https://kde.org/announcements/plasma/%1.%2.90/?source=plasma-welcome")
                           .arg(QString::number(m_version.majorVersion()), QString::number(m_version.minorVersion()));
    } else if constexpr (PLASMA_WELCOME_VERSION_PATCH >= 80) {
        // Development version
        m_releaseUrl = QStringLiteral("https://invent.kde.org/groups/plasma/-/activity");
    } else {
        // Release version
        m_releaseUrl = QStringLiteral("https://kde.org/announcements/plasma/%1.%2.0/?source=plasma-welcome")
                           .arg(QString::number(m_version.majorVersion()), QString::number(m_version.minorVersion()));
    }

    // Shown version string, matching desktop preview banner
    if constexpr (PLASMA_WELCOME_VERSION_PATCH >= 80 || PLASMA_WELCOME_VERSION_MINOR >= 80) {
        // Beta or development version
        // finalMajor, finalMinor is the final version in the line
        // and should be updated after the final Plasma 6 release
        constexpr int finalMajor = 5;
        constexpr int finalMinor = 27;

        // Incremented minor, which is zeroed and major incremented when
        // we reach the final version in the major release line
        int major = (PLASMA_WELCOME_VERSION_MAJOR == finalMajor && PLASMA_WELCOME_VERSION_MINOR == finalMinor) ? PLASMA_WELCOME_VERSION_MAJOR + 1
                                                                                                               : PLASMA_WELCOME_VERSION_MAJOR;
        int minor = (PLASMA_WELCOME_VERSION_MAJOR == finalMajor && PLASMA_WELCOME_VERSION_MINOR == finalMinor) ? 0 : PLASMA_WELCOME_VERSION_MINOR + 1;
        const QString version = QStringLiteral("%1.%2").arg(QString::number(major), QString::number(minor));

        if constexpr (PLASMA_WELCOME_VERSION_MINOR == 80 && PLASMA_WELCOME_VERSION_MINOR <= 70) {
                m_shownVersion = i18nc("@label %1 is the Plasma version", "6 Alpha (%1)", version);
        } else if constexpr (PLASMA_WELCOME_VERSION_MINOR == 90 && PLASMA_WELCOME_VERSION_MINOR <= 70) {
                m_shownVersion = i18nc("@label %1 is the Plasma version", "6 Beta 1 (%1)", version);
        } else if constexpr (PLASMA_WELCOME_VERSION_MINOR == 91 && PLASMA_WELCOME_VERSION_MINOR <= 70) {
                m_shownVersion = i18nc("@label %1 is the Plasma version", "6 Beta 2 (%1)", version);
        } else if constexpr (PLASMA_WELCOME_VERSION_MINOR == 92 && PLASMA_WELCOME_VERSION_MINOR <= 70) {
                m_shownVersion = i18nc("@label %1 is the Plasma version", "6 RC 1 (%1)", version);
        } else if constexpr (PLASMA_WELCOME_VERSION_MINOR == 93 && PLASMA_WELCOME_VERSION_MINOR <= 70) {
                m_shownVersion = i18nc("@label %1 is the Plasma version", "6 RC 2 (%1)", version);
        } else if constexpr (PLASMA_WELCOME_VERSION_PATCH >= 80 && PLASMA_WELCOME_VERSION_PATCH <= 90) {
            // Development version
            m_shownVersion = i18nc("@label %1 is the Plasma version", "%1 Dev", version);
        } else if constexpr (PLASMA_WELCOME_VERSION_PATCH >= 90) {
            // Beta version
            if constexpr (PLASMA_WELCOME_VERSION_PATCH == 90) {
                m_shownVersion = i18nc("@label %1 is the Plasma version", "%1 Beta", version);
            } else {
                constexpr int betaNumber = PLASMA_WELCOME_VERSION_PATCH - 89;
                m_shownVersion = i18nc("@label %1 is the Plasma version, %2 is the beta release number", "%1 Beta %2", version, betaNumber);
            }
        }
    } else {
        // Release version
        m_shownVersion = QStringLiteral("%1.%2").arg(QString::number(m_version.majorVersion()), QString::number(m_version.minorVersion()));
    }

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

void Controller::launchApp(const QString &program)
{
    auto *job = new KIO::ApplicationLauncherJob(KService::serviceByDesktopName(program));
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
    job->start();
}

void Controller::runCommand(const QString &command)
{
    runCommand(command, QString());
}

void Controller::runCommand(const QString &command, const QString &desktopFilename)
{
    auto *job = new KIO::CommandLauncherJob(command);
    if (!desktopFilename.isEmpty()) {
        job->setDesktopName(desktopFilename);
    }
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
    job->start();
}

bool Controller::networkAlreadyConnected()
{
    if constexpr (PLASMA_WELCOME_VERSION_PATCH == 80 || PLASMA_WELCOME_VERSION_MINOR >= 80) {
        // NOTE: Force visible so we notice regressions during development
        return false;
    } else {
        for (QNetworkInterface interface : QNetworkInterface::allInterfaces()) {
            if (interface.addressEntries().count() >= 1) {
                const QFlags flags = interface.flags();
                if (flags.testFlag(QNetworkInterface::IsUp) && !flags.testFlag(QNetworkInterface::IsLoopBack)) {
                    return true;
                }
            }
        }
        return false;
    }
}

bool Controller::userFeedbackAvailable()
{
    KPluginMetaData data(QStringLiteral("plasma/kcms/systemsettings/kcm_feedback"));
    return data.isValid();
}

QStringList Controller::distroPages()
{
    const QString dirname = QStringLiteral(DISTRO_CUSTOM_PAGE_FOLDER);
    const QDir distroPagePath = QDir(dirname);

    if (!distroPagePath.exists() || distroPagePath.isEmpty()) {
        return {};
    }

    QStringList pages = distroPagePath.entryList(QDir::NoDotAndDotDot | QDir::Files | QDir::Readable, QDir::Name);
    for (int i = 0; i < pages.length(); i++) {
        pages[i] = QStringLiteral("file://") + dirname + pages[i];
    }

    return pages;
}

QString Controller::installPrefix()
{
    return QString::fromLatin1(PLASMA_WELCOME_INSTALL_DIR);
}

QString Controller::distroName()
{
    return KOSRelease().name();
}

QString Controller::distroIcon()
{
    return KOSRelease().logo();
}

QString Controller::distroUrl()
{
    return KOSRelease().homeUrl();
}

void Controller::setMode(Mode mode)
{
    if (m_mode == mode) {
        return;
    }

    m_mode = mode;
    Q_EMIT modeChanged();
}

#include "moc_controller.cpp"
