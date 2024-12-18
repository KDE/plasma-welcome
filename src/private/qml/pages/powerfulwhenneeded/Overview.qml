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

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Welcome.Page {
    heading: i18nc("@info:window The name of a KWin effect", "Overview")
    description: xi18nc("@info:usagetip", "Overview is a full-screen overlay that shows all of your open windows, letting you easily access any of them. It also shows your current Virtual Desktops, allowing you to add more, remove some, and switch between them. Finally, it offers a KRunner-powered search field that can also filter through open windows.")

    ColumnLayout {
        anchors.fill: parent

        spacing: Kirigami.Units.gridUnit

        Private.MockCard {
            Layout.fillWidth: true
            Layout.fillHeight: true

            backgroundAlignment: Qt.AlignCenter
            backgroundScale: mockOverview.scale
            blurRadius: 64

            Private.MockOverview {
                id: mockOverview
                anchors.fill: parent
            }
        }

        QQC2.Label {
            Layout.fillWidth: true

            text: xi18nc("@info:usagetip", "You can access Overview using the <shortcut>Meta+W</shortcut> keyboard shortcut, or by moving your mouse into the top-left corner of the screen. You can also press <shortcut>Meta+G</shortcut> for Grid View, which shows Virtual Desktops in a grid.")
            wrapMode: Text.WordWrap
        }
    }
}
