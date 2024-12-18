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

// org.kde.plasma.welcome.private, Release
// Provides release information for Welcome Center

class PLASMA_WELCOME_PRIVATE_EXPORT Release : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    WELCOME_SINGLETON(Release)

    int patchVersion() const;
    QString announcementUrl() const;

    Q_PROPERTY(QString friendlyVersion MEMBER m_friendlyVersion CONSTANT)
    Q_PROPERTY(int patchVersion READ patchVersion CONSTANT)
    Q_PROPERTY(QString announcementUrl READ announcementUrl CONSTANT)

private:
    Release(QObject *parent = nullptr);

    QVersionNumber m_version;
    QString m_friendlyVersion;
    QString m_announcementUrl;
};
