/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome

import org.kde.plasma.components as PC3
import org.kde.ksvg as KSvg
//NOTE: necessary for KSvg to load the Plasma theme
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support

Item {
    id: root

    required property bool animate
    required property bool iconConnecting
    required property string icon

    // To get the current date and time
    P5Support.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }

    // Wallpaper background image
    Image {
        // Anchor the wallpaper to the bottom-right
        // Above 1280x800, it will grow to fit, otherwise show a cropped region
        width: Math.max(root.width, 1280)
        height: Math.max(root.height, 800)
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        fillMode: Image.PreserveAspectCrop
        source: "file:" + Controller.installPrefix() + "/share/wallpapers/Next/contents/images/1280x800.png"

        layer.enabled: true
        layer.effect: GaussianBlur {
            radius: 32
            samples: (radius * 2) + 1
            cached: true
        }
    }

    // Panel shadow
    KSvg.FrameSvgItem {
        anchors.fill: panelContainer
        anchors.topMargin: -margins.top
        anchors.leftMargin: -margins.left
        anchors.rightMargin: -margins.right
        anchors.bottomMargin: -margins.bottom

        imagePath: "solid/widgets/panel-background"
        prefix: "shadow"
    }

    // Panel container
    Item {
        id: panelContainer

        width: Math.max(root.width, 1280) - anchors.margins * 2 // This overflows, but we clip both it and the background
                                                                // 1280 matches the size of the wallpaper
        height: 44 // Default panel height

        anchors.margins: Kirigami.Units.largeSpacing // Floating margins
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        readonly property int contentPadding: Kirigami.Units.largeSpacing
        readonly property int contentHeight: panelContainer.height - panelContainer.contentPadding * 2

        // Panel background
        KSvg.FrameSvgItem {
            anchors.fill: parent

            imagePath: "widgets/panel-background"
        }

        // Applet container
        RowLayout {
            id: appletContainer

            readonly property int iconSize: Kirigami.Units.iconSizes.roundedIconSize(height - (panelContainer.contentPadding * 2))

            anchors {
                right: parent.right
                rightMargin: Kirigami.Units.largeSpacing
                top: parent.top
                bottom: parent.bottom
            }

            spacing: Kirigami.Units.smallSpacing

            // System Tray
            RowLayout {
                id: appletSystemTray

                readonly property int iconMargins: Kirigami.Units.smallSpacing

                spacing: 0

                Kirigami.Icon {
                    Layout.leftMargin: appletSystemTray.iconMargins
                    Layout.rightMargin: appletSystemTray.iconMargins

                    implicitWidth: appletContainer.iconSize
                    implicitHeight: appletContainer.iconSize

                    source: "klipper-symbolic"
                    color: PlasmaCore.Theme.textColor
                }

                Kirigami.Icon {
                    Layout.leftMargin: appletSystemTray.iconMargins
                    Layout.rightMargin: appletSystemTray.iconMargins

                    implicitWidth: appletContainer.iconSize
                    implicitHeight: appletContainer.iconSize

                    source: "audio-volume-high"
                    color: PlasmaCore.Theme.textColor
                }

                Kirigami.Icon {
                    Layout.leftMargin: appletSystemTray.iconMargins
                    Layout.rightMargin: appletSystemTray.iconMargins

                    implicitWidth: Kirigami.Units.iconSizes.smallMedium
                    implicitHeight: Kirigami.Units.iconSizes.smallMedium

                    source: root.icon
                    color: PlasmaCore.Theme.textColor

                    PC3.BusyIndicator {
                        id: connectingIndicator

                        anchors.centerIn: parent
                        height: Math.min(parent.width, parent.height)
                        width: height
                        running: root.iconConnecting
                        visible: running
                    }
                }

                Kirigami.Icon {
                    implicitWidth: Kirigami.Units.iconSizes.smallMedium
                    implicitHeight: Kirigami.Units.iconSizes.smallMedium

                    source: "arrow-up"
                    color: PlasmaCore.Theme.textColor
                }
            }

            // Digital Clock
            Item {
                Layout.preferredWidth: Math.max(timeLabel.paintedWidth,
                                                dateLabel.paintedWidth + Kirigami.Units.largeSpacing)
                implicitHeight: panelContainer.contentHeight

                PC3.Label {
                    id: timeLabel

                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: Qt.formatTime(timeSource.data["Local"]["DateTime"])

                    width: paintedWidth
                    height: 15.68
                    font.pixelSize: 16
                    color: PlasmaCore.Theme.textColor

                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                PC3.Label {
                    id: dateLabel

                    anchors.top: timeLabel.bottom
                    anchors.horizontalCenter: timeLabel.horizontalCenter

                    text: Qt.formatDate(timeSource.data["Local"]["DateTime"], Qt.DefaultLocaleShortDate)

                    width: paintedWidth
                    height: 12.544
                    font.pixelSize: 13
                    color: PlasmaCore.Theme.textColor

                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Peek at Desktop
            Item {
                width: 32
                height: appletContainer.iconSize

                Kirigami.Icon {
                    anchors.centerIn: parent
                    implicitWidth: appletContainer.iconSize
                    implicitHeight: appletContainer.iconSize

                    source: "user-desktop-symbolic"
                    color: PlasmaCore.Theme.textColor
                }
            }
        }
    }

    // Arrow container
    Kirigami.Icon {
        id: indicatorArrow

        width : Kirigami.Units.iconSizes.large
        height: Kirigami.Units.iconSizes.large

        source: "arrow-down"

        property real yOffset: Kirigami.Units.gridUnit

        anchors.right: panelContainer.right
        anchors.rightMargin: - (width / 2)                                                        // Center the arrow on target
                             + appletContainer.width + appletContainer.anchors.rightMargin        // Align with the left of the applet container
                             - (appletContainer.iconSize / 2 + appletSystemTray.iconMargins)      // Align with the first icon
                             - (appletContainer.iconSize + appletSystemTray.iconMargins * 2 ) * 2 // Align with the network icon
        anchors.bottom: panelContainer.top
        anchors.bottomMargin: yOffset

        layer.enabled: true
        layer.effect: Glow {
            radius: 6
            samples: (radius * 2) + 1
            spread: 0.5
            color: "white"
        }

        SequentialAnimation on yOffset {
            running: root.animate
            loops: Animation.Infinite
            alwaysRunToEnd: true

            NumberAnimation {
                from: Kirigami.Units.gridUnit
                to: 0
                duration: 1000
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                from: 0
                to: Kirigami.Units.gridUnit
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }

        opacity: root.animate ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
}
