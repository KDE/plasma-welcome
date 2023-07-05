/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <QDir>
#include <QNetworkInterface>
#include <QStandardPaths>
#include <QString>

#include "config-plasma-welcome.h"
#include "controller.h"

#include <KIO/ApplicationLauncherJob>
#include <KIO/CommandLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KOSRelease>
#include <KPluginMetaData>
#include <KService>

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
    for (QNetworkInterface interface : QNetworkInterface::allInterfaces()) {
        const QFlags flags = interface.flags();
        if (flags.testFlag(QNetworkInterface::IsUp) && !flags.testFlag(QNetworkInterface::IsLoopBack)) {
            if (interface.addressEntries().count() >= 1) {
                return true;
            }
        }
    }
    return false;
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
    const QString dirname = QStringLiteral(DISTRO_PAGE_PATH);
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
