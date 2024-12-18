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

#include "controller.h"

Controller::Controller(QObject *parent)
    : QObject(parent)
{
}

void Controller::launchApp(const QString &program) const
{
    qWarning() << "Controller.launchApp() is deprecated — use Utils.launchApp() instead.";

    auto *job = new KIO::ApplicationLauncherJob(KService::serviceByDesktopName(program));
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
    job->start();
}

void Controller::runCommand(const QString &command, QJSValue callback)
{
    qWarning() << "Controller.runCommand() is deprecated — use Utils.runCommand() instead.";

    const bool resultHandled = callback.isCallable();

    QStringList args = command.split(QLatin1String(" "));
    const QString program = args.first();

    if (QStandardPaths::findExecutable(program).isEmpty()) {
        const QString errorMessage = xi18nc("@info:progress", "The command <command>%1</command> could not be found.", program);

        qWarning() << errorMessage;
        if (resultHandled) {
            callback.call({-1, errorMessage});
        }
        return;
    }

    args.removeFirst();

    QProcess *process = new QProcess(this);
    process->start(program, args);

    if (!resultHandled) {
        return;
    }

    connect(process, &QProcess::finished, [=](int exitCode, QProcess::ExitStatus exitStatus) {
        process->deleteLater();
        const QString stdout = QString(process->readAllStandardOutput().trimmed());

        // Success
        if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
            callback.call({exitCode, stdout});
            return;
        }

        // Failure
        QString intermediateText = QString(process->readAllStandardError().trimmed());
        if (intermediateText.isEmpty()) {
            intermediateText = stdout;
            if (intermediateText.isEmpty()) {
                intermediateText = i18nc("@info:progress", "No error message provided");
            }
        }
        const QString finalOutputText = xi18nc("@info:progress %1 is the command being run, and %2 is the human-readable error text returned by the command",
                                               "The command <command>%1</command> failed: %2",
                                               command,
                                               intermediateText);

        qWarning() << finalOutputText;
        callback.call({exitCode, finalOutputText});
        return;
    });
}

void Controller::copyToClipboard(const QString &text) const
{
    qWarning() << "Controller.copyToClipboard() is deprecated — use Utils.copyToClipboard() instead.";

    QApplication::clipboard()->setText(text);
}

#include "moc_controller.cpp"
