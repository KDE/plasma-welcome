/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <QApplication>
#include <QClipboard>
#include <QProcess>
#include <QStandardPaths>

#include <KIO/ApplicationLauncherJob>
#include <KLocalizedString>
#include <KNotificationJobUiDelegate>

#include "utils.h"

#include "controller.h"

Controller::Controller(QObject *parent)
    : QObject(parent)
{
}

void Controller::launchApp(const QString &program) const
{
    qWarning() << "Controller.launchApp() is deprecated — use Utils.launchApp() instead.";
    Utils::instance()->launchApp(program);
}

void Controller::runCommand(const QString &command, QJSValue callback) const
{
    qWarning() << "Controller.runCommand() is deprecated — use Utils.runCommand() instead.";
    Utils::instance()->runCommand(command, callback);
}

void Controller::copyToClipboard(const QString &text) const
{
    qWarning() << "Controller.copyToClipboard() is deprecated — use Utils.copyToClipboard() instead.";
    Utils::instance()->copyToClipboard(text);
}

#include "moc_controller.cpp"
