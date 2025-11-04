/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <QApplication>
#include <QClipboard>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QStandardPaths>
#include <QTextStream>

#include <KIO/ApplicationLauncherJob>
#include <KLocalizedString>
#include <KNotificationJobUiDelegate>

#include "welcome_debug.h"

#include "utils.h"

Utils::Utils(QObject *parent)
    : QObject(parent)
{
}

void Utils::launchApp(const QString &program)
{
    auto *job = new KIO::ApplicationLauncherJob(KService::serviceByDesktopName(program));
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
    job->start();
}

void Utils::runCommand(const QString &command, QJSValue callback)
{
    const bool resultHandled = callback.isCallable();

    QStringList args = command.split(QLatin1String(" "));
    const QString program = args.first();

    if (QStandardPaths::findExecutable(program).isEmpty()) {
        const QString errorMessage = xi18nc("@info:progress", "The command <command>%1</command> could not be found.", program);

        qCWarning(WELCOME_LOG) << "The command" << program << "could not be found";
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

        qCWarning(WELCOME_LOG) << "The command" << command << "failed:" << intermediateText;
        callback.call({exitCode, finalOutputText});
        return;
    });
}

void Utils::copyToClipboard(const QString &content) const
{
    QApplication::clipboard()->setText(content);
}

bool Utils::isMac() const
{
    bool isMac = false;

    const QStringList possibleVendorNameFiles = {
        QStringLiteral("/sys/class/dmi/id/sys_vendor"), // PCs and Intel macs
        QStringLiteral("/proc/device-tree/model") // Arm and PPC macs
    };
    for (const QString &path : possibleVendorNameFiles) {
        QFileInfo fileInfo(path);
        if (fileInfo.exists()) {
            QFile file(path);
            if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
                QTextStream in(&file);
                const QString vendor = in.readLine().trimmed();
                file.close();
                if (vendor.startsWith("Apple"), Qt::CaseInsensitive) {
                    isMac = true;
                    break;
                }
            }
        }
    }

    return isMac;
}

#include "moc_utils.cpp"
