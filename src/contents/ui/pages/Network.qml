/*
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15
import QtQuick.Window 2.15

import org.kde.welcome 1.0

GenericPage {
    heading: i18nc("@info:window", "Accessing the Internet")
    // TODO: handle the case where there's already a wired connection
    description: xi18nc("@info:usagetip", "You can connect to the internet and manage your network connections with the <interface>Networks applet</interface>. To access it, click on the <interface>Networks</interface> icon in your <interface>System Tray</interface>, which lives in the bottom-right corner of the screen.")

    Kirigami.ShadowedRectangle {
        anchors.centerIn: parent
        implicitWidth: image.width + Kirigami.Units.largeSpacing
        implicitHeight: image.height + Kirigami.Units.largeSpacing
        radius: Kirigami.Units.smallSpacing
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor
        shadow.xOffset: 0
        shadow.yOffset: 2
        shadow.size: 10
        shadow.color: Qt.rgba(0, 0, 0, 0.3)

        Image {
            id: image
            width: Math.round(implicitWidth / Screen.devicePixelRatio)
            height: Math.round(implicitHeight / Screen.devicePixelRatio)
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            source: "system-tray-network-icon.png"
        }
    }
}
