/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <QFile>
#include <QProcess>
#include <QStandardPaths>
#include <QString>

#include "controller.h"

#include "welcomeconfig.h"

void Controller::open(const QString& program)
{
    QProcess::startDetached(program, {});
}

void Controller::removeFromAutostart()
{
    if (WelcomeConfig::self()->skip() == true) {
        QString configPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
        QString autoStart = QString::fromUtf8("/autostart/");
        QString fileName = QString::fromUtf8("welcome.desktop");
        QString fullPath = configPath + autoStart + fileName;
        QFile file = fullPath;
        file.remove();
    }
}
