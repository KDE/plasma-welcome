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
import Qt5Compat.GraphicalEffects

import org.kde.plasma.welcome 1.0

GenericPage {
    id: root

    heading: i18nc("@title:window", "Manage Software")
    description: xi18nc("@info:usagetip","The <application>Discover</application> app helps you find and install applications, games, and tools. You can search or browse by category, look at screenshots, and read reviews to help you find the perfect app.")

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Kirigami.Units.gridUnit

        ApplicationIcon {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true

            application: "org.kde.discover"
            size: Kirigami.Units.gridUnit * (applicationGrid.twoRowlayout ? 6 : 10)
        }

        GridLayout {
            id: applicationGrid

            readonly property int itemSize: Kirigami.Units.iconSizes.huge
            readonly property int oneRowWidth: ((itemSize + columnSpacing) * appsModel.count) - columnSpacing
            property bool twoRowlayout:  oneRowWidth > root.width - (root.margins * 2)

            Layout.alignment: Qt.AlignHCenter

            columns: twoRowlayout ? 3 : -1
            rows: twoRowlayout ? 2 : 1
            columnSpacing: Kirigami.Units.largeSpacing * 4
            rowSpacing: Kirigami.Units.largeSpacing

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
                    spacing: Kirigami.Units.smallSpacing


                    Loader {
                        Layout.preferredWidth: applicationGrid.itemSize
                        Layout.preferredHeight: applicationGrid.itemSize

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
                        Layout.maximumWidth: applicationGrid.itemSize
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
}
