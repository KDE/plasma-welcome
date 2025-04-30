/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Welcome.Page {
    id: root

    property bool installerAvailable: Private.Config.liveInstaller.length !== 0

    heading: i18nc("@title:window %1 is the name of the user's distro", "Welcome to %1!", Welcome.Distro.name)
    description: installerAvailable
                 ? xi18nc("@info:usagetip %1 is the name of the user's distro",
                          "Pressing the icon below will begin installing %1. Alternatively, you can close the window to explore the live environment or continue here to find out about KDE Plasma.", Welcome.Distro.name)
                 : xi18nc("@info:usagetip %1 is the name of the user's distro",
                          "You can close the window to explore the live environment or continue here to find out about KDE Plasma.")

    topContent: [
        Kirigami.UrlButton {
            id: link
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Visit home page")
            url: Welcome.Distro.homeUrl
            visible: url.length !== 0
        }
    ]

    Kirigami.Icon {
        anchors.centerIn: parent
        width: Math.min(parent.height, Kirigami.Units.gridUnit * 16)
        height: width

        layer.enabled: installerAvailable && GraphicsInfo.api !== GraphicsInfo.Software
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 1.0
            blurMax: 10
        }
        opacity: installerAvailable ? 0.1 : 1

        source: Welcome.Distro.logo
        fallback: ""
    }

    Welcome.ApplicationIcon {
        anchors.centerIn: parent
        application: Welcome.ApplicationInfo {
            id: application
            desktopName: Private.Config.liveInstaller
        }
        size: Kirigami.Units.gridUnit * 10
        visible: root.installerAvailable
    }
}
