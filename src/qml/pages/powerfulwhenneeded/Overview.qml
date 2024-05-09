/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome

GenericPage {
    heading: i18nc("@info:window The name of a KWin effect", "Overview")
    description: xi18nc("@info:usagetip", "Overview is a full-screen overlay that shows all of your open windows, letting you easily access any of them. It also shows your current Virtual Desktops, allowing you to add more, remove some, and switch between them. Finally, it offers a KRunner-powered search field that can also filter through open windows.")

    ColumnLayout {
        anchors.fill: parent

        spacing: Kirigami.Units.gridUnit

        Kirigami.AbstractCard {
            Layout.fillWidth: true
            Layout.fillHeight: true

            MockDesktop {
                anchors.centerIn: parent

                width: (parent.width - Kirigami.Units.smallSpacing * 2) * (1 / scale)
                height: (parent.height - Kirigami.Units.smallSpacing * 2) * (1 / scale)

                // Rather than set scale factor, only scale if we need to
                scale: Math.max(0.5, Math.min(1, parent.width / (Kirigami.Units.gridUnit * 30), parent.height / (Kirigami.Units.gridUnit * 40)))

                Component.onCompleted: console.log(scale)
                onScaleChanged: console.log(scale)

                layer.enabled: true
                layer.smooth: true

                backgroundAlignment: Qt.AlignCenter
                blurRadius: 64

                MockOverview {
                    anchors.fill: parent
                }
            }
        }

        QQC2.Label {
            Layout.fillWidth: true

            text: xi18nc("@info:usagetip", "You can access Overview using the <shortcut>Meta+W</shortcut> keyboard shortcut, or by moving your mouse into the top-left corner of the screen. You can also press <shortcut>Meta+G</shortcut> for Grid View, which shows Virtual Desktops in a grid.")
            wrapMode: Text.WordWrap
        }
    }
}
