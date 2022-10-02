/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <QDir>
#include <QFile>
#include <QProcess>
#include <QStandardPaths>
#include <QString>

#include "controller.h"

#include <KIO/ApplicationLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KService>
#include <NetworkManagerQt/Manager>

void Controller::open(const QString &program)
{
    auto *job = new KIO::ApplicationLauncherJob(KService::serviceByDesktopName(program));
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
    job->start();
}

bool Controller::networkAlreadyConnected()
{
    return NetworkManager::connectivity() == NetworkManager::Connectivity::Full;
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

void Controller::setPlasmaUpgradeVersion(const QString &version)
{
    if (m_newPlasmaVersion == version) {
        return;
    }

    m_newPlasmaVersion = version;
    Q_EMIT newPlasmaVersionChanged();
}
