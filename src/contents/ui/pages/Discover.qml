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
import QtGraphicalEffects 1.15

import org.kde.welcome 1.0

GenericPage {
    heading: i18nc("@title:window", "Managing Software")
    description: i18nc("@info:usagetip","Discover helps you find and install applications, games, and tools. You can search or browse by category, and look at screenshots and read reviews to help you pick the perfect app.")

    Kirigami.Icon {
        id: image
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Kirigami.Units.gridUnit * 4
        width: Kirigami.Units.gridUnit * 10
        height: Kirigami.Units.gridUnit * 10
        source: "plasmadiscover"

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: Controller.open("plasma-discover")
        }

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 1
            radius: 20
            samples: 20
            color: Qt.rgba(0, 0, 0, 0.2)
        }
    }

    Kirigami.Heading {
        id: label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: image.bottom
        text: i18nc("@title the name of the app 'Discover'", "Discover")
        wrapMode: Text.WordWrap
        level: 3
    }

    GridLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: label.bottom
        anchors.topMargin: Kirigami.Units.gridUnit * 2
        columns: 5
        columnSpacing: Kirigami.Units.largeSpacing * 4
        rowSpacing: Kirigami.Units.largeSpacing * 4

        Repeater {
            model: ListModel {
                ListElement { name: "Krita"; appstream: "org.kde.krita"; icon: "org.kde.krita" }
                ListElement { name: "Blender"; appstream: "org.blender.Blender"; icon: "blender" }
                ListElement { name: "Inkscape"; appstream: "org.inkscape.Inkscape"; icon: "inkscape" }
                ListElement { name: "VLC"; appstream: "org.videolan.VLC"; icon: "vlc" }
                ListElement { name: "Gimp"; appstream: "org.gimp.GIMP"; icon: "gimp" }
            }
            delegate: ColumnLayout {
                id: applicationItem
                spacing: Kirigami.Units.smallSpacing

                readonly property int itemSize: Kirigami.Units.iconSizes.huge

                Kirigami.Icon {
                    Layout.preferredWidth: applicationItem.itemSize
                    Layout.preferredHeight: applicationItem.itemSize
                    source: model.icon
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: applicationItem.itemSize
                    Layout.minimumHeight: Kirigami.Units.gridUnit * 5
                    text: model.name
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignTop
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: Qt.openUrlExternally(`appstream://${model.appstream}`)
                }
            }
        }
    }
}
