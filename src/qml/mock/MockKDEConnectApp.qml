/*
 *  SPDX-FileCopyrightText: 2026 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts

import QtQuick.Controls as Controls

Item {
    id: kdeConnectAppContainer

    readonly property int phoneWidth: 1080
    readonly property int phoneHeight: 2340

    clip: true

    Rectangle {
        width: kdeConnectAppContainer.phoneWidth
        height: kdeConnectAppContainer.phoneHeight

        scale: kdeConnectAppContainer.width / kdeConnectAppContainer.phoneWidth
        transformOrigin: Item.TopLeft
        layer.enabled: GraphicsInfo.api !== GraphicsInfo.Software
        layer.smooth: true

        color: "black"

        Column {
            anchors.fill: parent

            spacing: 0

            Rectangle {
                id: systemBar

                width: parent.width
                height: 101
            }

            Rectangle {
                id: appHeader

                Controls.Label {
                    anchors.centerIn: parent
                    text: "My Desktop"
                    font.pixelSize: 78
                }

                width: parent.width
                height: 168
            }
        }
    }

}
