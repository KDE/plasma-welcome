/*
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras

import org.kde.plasma.welcome

Item {
    id: root

    // We're intentionally ignoring our 16:10 desktop wallpaper (MockDesktop) - whilst that fits the square
    // window, we want to be more representative of what a user will see - most use a 16:9 display.
    readonly property string wallpaper: "file:" + Controller.installPrefix() + "/share/wallpapers/Next/contents/images/1920x1080.png"

    // Underlay
    Rectangle {
        anchors.fill: parent

        opacity: 0.7
        color: Kirigami.Theme.backgroundColor
    }

    ColumnLayout {
        anchors.fill: parent

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

                        layer.enabled: true
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
                        text: "Desktop 1"
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

                focusPolicy: Qt.NoFocus
            }
        }

        // Top bar
        PlasmaExtras.SearchField {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            Layout.preferredWidth: Kirigami.Units.gridUnit * 20

            // HACK: Prevent tab focusing of children
            onFocusChanged: root.focus = true
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

                visible: false

                source: root.wallpaper
                mipmap: true
            }

            Kirigami.ShadowedTexture {
                anchors.fill: desktop

                source: desktop
                radius: Kirigami.Units.cornerRadius * 2

                layer.enabled: true
                layer.effect: MultiEffect {
                    autoPaddingEnabled: true
                    shadowEnabled: true
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 3
                    shadowBlur: 1.0
                    shadowColor: Qt.rgba(0, 0, 0, 0.3)
                }
            }
        }
    }

    // Eat mouse events (hover, click, scroll)
    MouseArea {
        anchors.fill: parent

        acceptedButtons: Qt.AllButtons
        hoverEnabled: true

        onWheel: wheel => wheel.accepted = true
    }
}
