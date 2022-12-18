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
import org.kde.plasma.welcome 1.0

GenericPage {
    heading: i18nc("@title:window", "Manage Software")
    description: xi18nc("@info:usagetip","The <application>Discover</application> app helps you find and install applications, games, and tools. You can search or browse by category, look at screenshots, and read reviews to help you find the perfect app.")

    Kirigami.Icon {
        id: image
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Kirigami.Units.gridUnit * 4
        width: Kirigami.Units.gridUnit * 10
        height: Kirigami.Units.gridUnit * 10
        source: "plasmadiscover"

        HoverHandler {
            id: hoverhandler
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: Controller.launchApp("org.kde.discover");
        }

        QQC2.ToolTip {
            visible: hoverhandler.hovered
            text: i18nc("@action:button", "Launch Discover now")
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

    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: label.bottom
        anchors.topMargin: Kirigami.Units.gridUnit * 2

        spacing: Kirigami.Units.largeSpacing * 4

        Repeater {
            model: ListModel {
                id: appsModel
                ListElement { name: "Krita"; appstream: "org.kde.krita"; icon: "krita.png" }
                ListElement { name: "Blender"; appstream: "org.blender.Blender"; icon: "blender" }
                ListElement { name: "VLC"; appstream: "org.videolan.VLC"; icon: "vlc" }
                ListElement { name: "GIMP"; appstream: "org.gimp.GIMP"; icon: "gimp" }
                ListElement { name: "KStars"; appstream: "org.kde.kstars.desktop"; icon: "kstars" }
                ListElement { name: "Endless Sky"; appstream: "io.github.endless_sky.endless_sky"; icon: "endlesssky.png" }
            }
            delegate: ColumnLayout {
                id: applicationItem
                spacing: Kirigami.Units.smallSpacing

                readonly property int itemSize: Kirigami.Units.iconSizes.huge

                Loader {
                    Layout.preferredWidth: applicationItem.itemSize
                    Layout.preferredHeight: applicationItem.itemSize

                    sourceComponent : model.icon.endsWith(".png") ? imageComponent : iconComponent

                    Component {
                        id: iconComponent
                        Kirigami.Icon { source: model.icon }
                    }
                    Component {
                        id: imageComponent
                        Image { source: model.icon }
                    }
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
                    id: hoverhandler
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: Qt.openUrlExternally(`appstream://${model.appstream}`)
                }

                QQC2.ToolTip {
                    visible: hoverhandler.hovered
                    text: i18nc("@action:button %1 is the name of an app", "Show %1 in Discover", model.name)
                }
            }
        }
    }
}
