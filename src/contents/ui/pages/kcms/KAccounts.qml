/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick

import org.kde.plasma.welcome

KCM {
    id: kcm_kaccounts

    heading: i18nc("@title: window", "Connect Online Accounts")
    description: i18nc("@info:usagetip", "This will let you access their content in KDE apps. You can set it up in System Settings, and here too.")
    path: "kcm_kaccounts"
}
