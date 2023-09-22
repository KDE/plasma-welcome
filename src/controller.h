/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include "version.h"
#include <QObject>
#include <qqmlregistration.h>

class Controller : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    Controller();

    Q_INVOKABLE static void launchApp(const QString &program);
    Q_INVOKABLE static void runCommand(const QString &command);
    Q_INVOKABLE static void runCommand(const QString &command, const QString &desktopFilename);
    Q_INVOKABLE bool networkAlreadyConnected();
    Q_INVOKABLE bool userFeedbackAvailable();
    Q_INVOKABLE bool accountsAvailable();
    Q_INVOKABLE QStringList distroPages();
    Q_INVOKABLE QString distroName();
    Q_INVOKABLE QString distroIcon();
    Q_INVOKABLE QString distroUrl();
    Q_INVOKABLE QString installPrefix();

    Q_PROPERTY(Mode mode MEMBER m_mode NOTIFY modeChanged)
    Q_PROPERTY(QString customIntroText MEMBER m_customIntroText CONSTANT)
    Q_PROPERTY(QString customIntroIcon MEMBER m_customIntroIcon CONSTANT)
    Q_PROPERTY(QString customIntroIconLink MEMBER m_customIntroIconLink CONSTANT)
    Q_PROPERTY(QString customIntroIconCaption MEMBER m_customIntroIconCaption CONSTANT)
    Q_PROPERTY(QString plasmaVersion MEMBER m_plasmaVersion CONSTANT)
    Q_PROPERTY(QString simplePlasmaVersion MEMBER m_simplePlasmaVersion CONSTANT)
    Q_PROPERTY(QStringList plasmaVersionSplit MEMBER m_plasmaVersionSplit CONSTANT)
    Q_PROPERTY(bool orcaAvailable READ orcaAvailable CONSTANT)
    Q_PROPERTY(bool screenReaderEnabled READ screenReaderEnabled WRITE setScreenReaderEnabled NOTIFY screenReaderChanged)

    enum Mode { Update, Live, Welcome };
    Q_ENUM(Mode)

    void setMode(Mode mode);

    bool orcaAvailable() const;
    bool screenReaderEnabled() const;
    void setScreenReaderEnabled(bool enabled);

    Q_INVOKABLE void launchOrcaConfiguration();

Q_SIGNALS:
    void modeChanged();
    void screenReaderChanged();

private:
    Mode m_mode = Mode::Welcome;
    const QString m_plasmaVersion = QString::fromLatin1(PROJECT_VERSION);
    const QString m_simplePlasmaVersion = m_plasmaVersion.chopped(m_plasmaVersion.length() - m_plasmaVersion.lastIndexOf(QStringLiteral(".")));
    const QStringList m_plasmaVersionSplit = m_plasmaVersion.split(QStringLiteral("."));
    QString m_customIntroText;
    QString m_customIntroIcon;
    QString m_customIntroIconLink;
    QString m_customIntroIconCaption;
};
