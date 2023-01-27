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

import org.kde.plasma.welcome 1.0

GenericPage {
    heading: i18nc("@title:window", "Get Involved")
    description: xi18nc("@info:usagetip", "KDE is not a big company; it's an international volunteer community, and its software is made by people like you donating their time and passion. You too can help make things better, whether it's through translation, visual design, and promotion, or programming and bug triaging.<nl/><nl/>By contributing to KDE, you can become part of something special, meet new friends, learn new skills, and make a difference to millions while working with people from around the globe to deliver a stunning free software computing experience.")

    topContent: [
        Kirigami.UrlButton {
            id: link
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Start Contributing!")
            url: "https://community.kde.org/Get_Involved?source=plasma-welcome"
        }
    ]

    Image {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Kirigami.Units.gridUnit * 2
        height: Kirigami.Units.gridUnit * 16
        fillMode: Image.PreserveAspectFit
        source: "konqi-build.png"

        HoverHandler {
            id: hoverhandler
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: Qt.openUrlExternally(link.url)
        }
        QQC2.ToolTip {
            visible: hoverhandler.hovered
            text: i18nc("@action:button clicking on this takes the user to a web page", "Visit %1", link.url)
        }
    }
}
