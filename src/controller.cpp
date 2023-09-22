/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <QDir>
#include <QFileInfo>
#include <QNetworkInterface>
#include <QProcess>
#include <QStandardPaths>
#include <QString>

#include "config-plasma-welcome.h"
#include "controller.h"

#include <KConfigGroup>
#include <KDesktopFile>
#include <KIO/ApplicationLauncherJob>
#include <KIO/CommandLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KOSRelease>
#include <KPluginMetaData>
#include <KService>

Controller::Controller()
{
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
#if PROJECT_VERSION_PATCH == 80
    // NOTE: Force visible so we notice regressions during development
    return false;
#else
    for (QNetworkInterface interface : QNetworkInterface::allInterfaces()) {
        const QFlags flags = interface.flags();
        if (flags.testFlag(QNetworkInterface::IsUp) && !flags.testFlag(QNetworkInterface::IsLoopBack)) {
            if (interface.addressEntries().count() >= 1) {
                return true;
            }
        }
    }
    return false;
#endif
}

bool Controller::userFeedbackAvailable()
{
    KPluginMetaData data(QStringLiteral("plasma/kcms/systemsettings/kcm_feedback"));
    return data.isValid();
}

bool Controller::accountsAvailable()
{
    KPluginMetaData data(QStringLiteral("plasma/kcms/systemsettings/kcm_kaccounts"));
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

bool Controller::orcaAvailable() const
{
    const int tryOrcaRun = QProcess::execute(QStringLiteral("orca"), {QStringLiteral("--version")});
    // If the process cannot be started, -2 is returned.
    return tryOrcaRun != -2;
}

void Controller::launchOrcaConfiguration()
{
    const QStringList gsettingArgs = {QStringLiteral("set"),
                                      QStringLiteral("org.gnome.desktop.a11y.applications"),
                                      QStringLiteral("screen-reader-enabled"),
                                      QStringLiteral("true")};

    QProcess::execute(QStringLiteral("gsettings"), gsettingArgs);
    QProcess::startDetached(QStringLiteral("orca"), {QStringLiteral("--setup")});
}

bool Controller::screenReaderEnabled() const
{
    KConfig _cfg(QStringLiteral("kaccessrc"), KConfig::NoGlobals);
    KConfigGroup cfg(&_cfg, "ScreenReader");

    return cfg.readEntry("Enabled", false);
}

void Controller::setScreenReaderEnabled(const bool enabled)
{
    KConfig _cfg(QStringLiteral("kaccessrc"), KConfig::NoGlobals);
    KConfigGroup cfg(&_cfg, "ScreenReader");
    cfg.writeEntry("Enabled", enabled);
    cfg.sync();

    // Make kaccess reread the configuration.
    QProcess::startDetached(QStringLiteral("kaccess"), {});

    Q_EMIT screenReaderChanged();
}

#include "moc_controller.cpp"
