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

GenericPage {
    heading: i18nc("@title:window", "Getting Involved")
    description: xi18nc("@info:usagetip", "KDE's software is made by people like you--mostly volunteers. That means you can help make it better! There are many ways to contribute on topics as diverse as bug triaging, programming, translation, visual design, and promotion.<nl/><nl/>By contributing to KDE, you will become part of something special, meet new friends, learn new skills, and make a difference to millions while working with people from around the globe to deliver a stunning free software computing experience.")

    topContent: [
        QQC2.Button {
            Layout.topMargin: Kirigami.Units.largeSpacing
            icon.name: "love"
            text: i18nc("@action:button", "Start Contributing")
            onClicked: Qt.openUrlExternally("https://community.kde.org/Get_Involved")
        }
    ]

    Image {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Kirigami.Units.gridUnit * 2
        height: Kirigami.Units.gridUnit * 16
        fillMode: Image.PreserveAspectFit
        source: "konqi-build.png"
    }
}
