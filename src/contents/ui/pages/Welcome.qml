/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

import org.kde.welcome 1.0

Kirigami.Page {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Kirigami.Units.largeSpacing

        Image {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 16
            source: "konqi-kde-hi.png"
            fillMode: Image.PreserveAspectFit
        }
        Kirigami.Heading {
            Layout.fillWidth: true
            level: 1
            horizontalAlignment: Text.AlignHCenter
            text: i18nc("@title", "Welcome to KDE Plasma!")
        }
        QQC2.Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Math.round(root.width/1.5)
            text: i18nc("@info:usagetip", "KDE Plasma is a free and open-source desktop environment made by volunteers around the globe. It's simple by default for a smooth experience, but powerful when needed if you need to really get things done.")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }
}
