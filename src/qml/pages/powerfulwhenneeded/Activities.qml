/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils

import org.kde.plasma.welcome

GenericPage {
    heading: i18nc("@info:window", "Activities")
    description: xi18nc("@info:usagetip", "Activities can be used to separate high-level projects or workflows so you can focus on one at a time. You can have an activity for \"Home\", \"School\", \"Work\", and so on. Each Activity has access to all your files but has its own set of open apps and windows, recent documents, \"Favorite\" apps, and desktop widgets.<nl/><nl/>To get started, launch <interface>System Settings</interface> and search for \"Activities\". On that page, you can create more Activities. You can then switch between them using the <shortcut>Meta+Tab</shortcut> keyboard shortcut.")

    actions: [
        Kirigami.Action {
            icon.name: "preferences-desktop-activities"
            text: i18nc("@action:button", "Open Settings…")
            onTriggered: KCMUtils.KCMLauncher.openSystemSettings("kcm_activities")
        }
    ]
}
