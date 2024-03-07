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
    heading: i18nc("@info:window", "Get New Stuff")
    description: xi18nc("@info:usagetip", "Throughout Plasma, System Settings, and KDE apps, you'll find buttons marked \"Get New <emphasis>thing</emphasis>…\". Clicking on them will show you 3rd-party content to extend the system, made by other people like you! In this way, it is often possible to add functionality you want without having to ask KDE developers to implement it themselves.<nl/><nl/>Note that content acquired this way has not been reviewed by your distributor for functionality or stability.")

    actions: [
        Kirigami.Action {
            icon.name: "get-hot-new-stuff"
            text: i18nc("@action:button", "See 3rd-Party Content…")
            onTriggered: Controller.launchApp("org.kde.knewstuff-dialog6")
        }
    ]
}
