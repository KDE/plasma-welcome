/*
 *  SPDX-FileCopyrightText: 2025 Kristen McWilliam <kristen@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Welcome.Page {
    id: root

    // heading: i18nc("@title:window %1 is the name of the user's distro", "Welcome to your amazing new computer!")
    // description: xi18nc("@info:usagetip %1 is the name of the user's distro", "You can close the window make kittens sad.")

    heading: ""
    description: ""

    // topContent: [
    //     Kirigami.UrlButton {
    //         id: link
    //         Layout.topMargin: Kirigami.Units.largeSpacing
    //         text: i18nc("@action:button", "Visit home page")
    //         url: "https://www.kde.org"
    //         visible: url.length !== 0
    //     }
    // ]

    Kirigami.Heading {
        text: i18nc("@info:usagetip", "Welcome! Let's get started.")
        type: Kirigami.Heading.Type.Primary
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Kirigami.Icon {
        anchors.centerIn: parent
        implicitHeight: Kirigami.Units.iconSizes.enormous * 1.5
        implicitWidth: Kirigami.Units.iconSizes.enormous * 1.5
        source: "kde"
        fallback: ""
    }
}
