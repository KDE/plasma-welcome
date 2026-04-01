/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
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
    id: root

    heading: i18nc("@title:window", "Find Great Apps")
    description: xi18nc("@info:usagetip %1 is 'Discover', the name of KDE's software center app, and %2 is the distro name.", "There’s no need to search the web to download app installers or use a command-line package manager; KDE’s app store <application>%1</application> does it all for you!<nl/><nl/>Click on any of the icons below to give it a try!", application.name)

    show: application.exists

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Kirigami.Units.gridUnit

        Welcome.ApplicationIcon {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true

            application: Welcome.ApplicationInfo {
                id: application
                desktopName: "org.kde.discover"
            }

            size: Kirigami.Units.gridUnit * (applicationGrid.twoRowlayout ? 6 : 10)
        }

        GridLayout {
            id: applicationGrid

            readonly property int appIconSize: Kirigami.Units.iconSizes.large
            readonly property int buttonPadding: Kirigami.Units.largeSpacing
            readonly property int buttonSize: Kirigami.Units.gridUnit * 5
            readonly property int oneRowWidth: ((buttonSize + columnSpacing) * appsModel.count) - columnSpacing
            readonly property bool twoRowlayout:  oneRowWidth > root.width - (root.padding * 2)

            Layout.alignment: Qt.AlignHCenter

            columns: twoRowlayout ? 3 : -1
            rows: twoRowlayout ? 2 : 1
            columnSpacing: Kirigami.Units.largeSpacing
            rowSpacing: Kirigami.Units.largeSpacing

            Repeater {
                model: ListModel {
                    id: appsModel
                    ListElement { name: "Krita"; appstream: "org.kde.krita"; snap: "krita"; icon: "krita.svg" }
                    ListElement { name: "Blender"; appstream: "org.blender.Blender"; snap: "blender"; icon: "blender.svg" }
                    ListElement { name: "VLC"; appstream: "org.videolan.VLC"; snap: "vlc"; icon: "vlc.png" }
                    ListElement { name: "GIMP"; appstream: "org.gimp.GIMP"; snap: "gimp"; icon: "gimp.svg" }
                    ListElement { name: "KStars"; appstream: "org.kde.kstars.desktop"; snap: "kstars"; icon: "kstars.svg" }
                    ListElement { name: "Endless Sky"; appstream: "io.github.endless_sky.endless_sky"; snap: "endlesssky"; icon: "endlesssky.png" }
                }

                delegate: QQC2.ToolButton {
                    Layout.preferredWidth: applicationGrid.buttonSize
                    Layout.preferredHeight: applicationGrid.buttonSize
                    padding: applicationGrid.buttonPadding

                    Accessible.name: model.name

                    contentItem: ColumnLayout {
                        spacing: Kirigami.Units.smallSpacing

                        Image {
                            Layout.preferredWidth: applicationGrid.appIconSize
                            Layout.preferredHeight: applicationGrid.appIconSize
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom

                            source: model.icon
                            mipmap: true
                        }

                        QQC2.Label {
                            Layout.fillWidth: true
                            text: model.name
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignTop
                        }
                    }

                    onClicked: {
                        let url = Private.App.isDistroSnapOnly ? `snap://${model.snap}` : `appstream://${model.appstream}`
                        Qt.openUrlExternally(url)
                    }

                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                    QQC2.ToolTip.text: i18nc("@action:button %1 is the name of an app", "Show %1 in Discover", model.name)
                }
            }
        }
    }
}
