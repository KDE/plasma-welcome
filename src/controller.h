/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "QObject"

class Controller : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE static void launchApp(const QString &program);
    Q_INVOKABLE static void runCommand(const QString &command);
    Q_INVOKABLE static void runCommand(const QString &command, const QString &desktopFilename);
    Q_INVOKABLE bool networkAlreadyConnected();
    Q_INVOKABLE bool userFeedbackAvailable();
    Q_INVOKABLE QStringList distroPages();

    Q_PROPERTY(QString newPlasmaVersion MEMBER m_newPlasmaVersion NOTIFY newPlasmaVersionChanged)

    void setPlasmaUpgradeVersion(const QString &version);

Q_SIGNALS:
    void newPlasmaVersionChanged();

private:
    QString m_newPlasmaVersion;
};
