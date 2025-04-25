/*
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras

import org.kde.plasma.welcome.private as Private

Item {
    id: root

    // We're intentionally ignoring our 16:10 desktop wallpaper (MockDesktop) - whilst that fits the square
    // window, we want to be more representative of what a user will see - most use a 16:9 display.
    readonly property string wallpaper: "file:" + Private.App.installPrefix + "/share/wallpapers/Next/contents/images/5120x2880.png"
    readonly property double scale: layout.scale

    // Underlay
    Rectangle {
        anchors.fill: parent

        opacity: 0.7
        color: Kirigami.Theme.backgroundColor
    }

    // Contents
    ColumnLayout {
        id: layout
        anchors.centerIn: parent

        // Scale nicely (and dynamically, not with a fixed factor)
        width: (parent.width - Kirigami.Units.smallSpacing * 2) * (1 / scale)
        height: (parent.height - Kirigami.Units.smallSpacing * 2) * (1 / scale)
        scale: Math.max(0.5, Math.min(1, parent.width / (Kirigami.Units.gridUnit * 30), parent.height / (Kirigami.Units.gridUnit * 40)))
        layer.enabled: GraphicsInfo.api !== GraphicsInfo.Software
        layer.smooth: true

        spacing: 0

        // Desktop bar
        Row {
            Layout.topMargin: Kirigami.Units.smallSpacing * 2
            Layout.alignment: Qt.AlignHCenter

            spacing: Kirigami.Units.largeSpacing

            Column {
                Item {
                    width: desktopThumbnailImage.width
                    height: desktopThumbnailImage.height

                    Image {
                        id: desktopThumbnailImage
                        width: Math.round(height * (sourceSize.width / sourceSize.height))
                        height: Kirigami.Units.gridUnit * 5

                        source: root.wallpaper
                        mipmap: true

                        layer.enabled: GraphicsInfo.api !== GraphicsInfo.Software
                        // MultiEffect does not work for this, so using Qt5Compat.GraphicalEffects
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                anchors.centerIn: parent
                                width: desktopThumbnailImage.width
                                height: desktopThumbnailImage.height
                                radius: width / 20 // This is the behaviour in overview's DesktopBar
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent

                        radius: Kirigami.Units.cornerRadius
                        color: "transparent"
                        border.width: 2
                        border.color: Kirigami.Theme.activeTextColor
                    }
                }

                Item {
                    width: desktopThumbnailImage.width
                    height: Kirigami.Units.gridUnit + Kirigami.Units.smallSpacing * 2

                    PC3.Label {
                        anchors.fill: parent

                        elide: Text.ElideRight
                        text: i18nc("@title The default name of a Plasma desktop as seen in the overview", "Desktop 1")
                        textFormat: Text.PlainText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            PC3.Button {
                implicitWidth: desktopThumbnailImage.width
                implicitHeight: desktopThumbnailImage.height

                icon.name: "list-add"
                display: PC3.AbstractButton.IconOnly
                opacity: 0.75

                // For some reason, these are not inherited from MockDesktop
                Kirigami.Theme.inherit: false
                Kirigami.Theme.textColor: Private.PlasmaColors.textColor
            }
        }

        // Top bar
        PlasmaExtras.SearchField {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            Layout.preferredWidth: Kirigami.Units.gridUnit * 20

            // For some reason, these are not inherited from MockDesktop
            Kirigami.Theme.inherit: false
            Kirigami.Theme.textColor: Private.PlasmaColors.textColor
        }

        // Desktop
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Kirigami.Units.gridUnit

            Image {
                id: desktop
                anchors.centerIn: parent

                width: Math.min(parent.width, parent.height * (sourceSize.width / sourceSize.height))
                height: Math.min(parent.height, parent.width * (sourceSize.height / sourceSize.width))

                visible: GraphicsInfo.api === GraphicsInfo.Software

                source: root.wallpaper
                mipmap: true
            }

            Kirigami.ShadowedTexture {
                anchors.fill: desktop

                visible: GraphicsInfo.api !== GraphicsInfo.Software

                source: desktop
                radius: Kirigami.Units.cornerRadius * 2

                shadow {
                    size: Kirigami.Units.gridUnit * 2
                    color: Qt.rgba(0, 0, 0, 0.3)
                    yOffset: 3
                }
            }
        }
    }

    InteractionInhibitor {}
}
