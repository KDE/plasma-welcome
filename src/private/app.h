/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include "singleton.h"

#include "plasma-welcome-private_export.h"

// org.kde.plasma.welcome.private, App
// Provides core functionality for Welcome Center not intended for distro pages

class PLASMA_WELCOME_PRIVATE_EXPORT App : public QObject, public Singleton<App>
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    WELCOME_SINGLETON(App)

public:
    enum Mode {
        Pages, // Specified subset of pages via m_pages
        Update, // Post-Plasma update
        Beta, // Post-Plasma update to a beta release
        Live, // Welcome with added Live page
        Welcome // Normal experience with all pages
    };
    Q_ENUM(Mode)

    QString installPrefix() const;
    QString distroPagesDir() const;
    QStringList distroPages() const;
    bool userFeedbackAvailable() const;
    bool isDistroSnapOnly() const;

    Q_PROPERTY(Mode mode MEMBER m_mode CONSTANT)
    Q_PROPERTY(QStringList pages MEMBER m_pages CONSTANT)
    Q_PROPERTY(QString installPrefix READ installPrefix CONSTANT)
    Q_PROPERTY(QString distroPagesDir READ distroPagesDir CONSTANT)
    Q_PROPERTY(QStringList distroPages READ distroPages CONSTANT)
    Q_PROPERTY(bool userFeedbackAvailable READ userFeedbackAvailable CONSTANT)
    Q_PROPERTY(bool isDistroSnapOnly READ isDistroSnapOnly CONSTANT)
    Q_PROPERTY(QString customIntroText MEMBER m_customIntroText CONSTANT)
    Q_PROPERTY(QString customIntroIcon MEMBER m_customIntroIcon CONSTANT)
    Q_PROPERTY(QString customIntroIconLink MEMBER m_customIntroIconLink CONSTANT)
    Q_PROPERTY(QString customIntroIconCaption MEMBER m_customIntroIconCaption CONSTANT)

    void setMode(App::Mode mode);
    void setPages(const QStringList &pages);

private:
    App(QObject *parent = nullptr);

    // These properties must be set by the app before the QML engine loads Main
    Mode m_mode;
    QStringList m_pages;

    QString m_customIntroText;
    QString m_customIntroIcon;
    QString m_customIntroIconLink;
    QString m_customIntroIconCaption;
};