/*
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
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

GenericPage {
    id: root

    heading: i18nc("@info:window", "Access the Internet")
    description: xi18nc("@info:usagetip", "You can connect to the internet and manage your network connections with the <interface>Networks applet</interface>. To access it, click on the <interface>Networks</interface> icon in your <interface>System Tray</interface>, which lives in the bottom-right corner of the screen.")

    // To get the current date and time
    P5Support.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }

    Loader {
        id: nmLoader
        source: "PlasmaNM.qml"

        // Defaults for when PlasmaNM is not available
        property bool available: false
        property bool statusConnected: false
        property bool iconConnecting: false
        property string icon: "network-wireless-available"

        onStatusChanged: {
            if (status === Loader.Ready) {
                available = true;
                statusConnected = Qt.binding(() => nmLoader.item.networkStatus.connectivity === 4); // 4, Full connectivity
                iconConnecting = Qt.binding(() => nmLoader.item.connectionIcon.connecting);
                icon = Qt.binding(() => nmLoader.item.connectionIcon.connectionIcon);
            } else if (status === Loader.Error) {
                console.warn("PlasmaNM integration failed to load (is plasma-nm available?)");
            }
        }

        // Continue to the next page automatically when connected
        onStatusConnectedChanged: {
            if (statusConnected && pageStack.currentItem == root) {
                pageStack.currentIndex += 1;
            }
        }
    }

    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent

        width: parent.width - Kirigami.Units.gridUnit * 2

        // Shown when plasma-nm is not available or the user has connected
        opacity: !nmLoader.available || nmLoader.statusConnected ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        icon.name: nmLoader.available ? "data-success-symbolic" : "data-warning-symbolic"

        text: nmLoader.available ? i18nc("@info:placeholder Shown when connected to the internet", "You're connected")
                                 : i18nc("@info:placeholder", "Networking support for Plasma is not currently installed")
        explanation: nmLoader.available ? i18nc("@info:usagetip Shown when connected to the internet", "All good to go!")
                                        : xi18nc("@info:usagetip %1 is the name of the user's distro", "To manage network connections, Plasma requires <icode>plasma-nm</icode> to be installed. Please report this omission to %1.", Controller.distroName())

        helpfulAction: Kirigami.Action {
            enabled: !nmLoader.available
            icon.name: "tools-report-bug-symbolic"
            text: i18nc("@action:button", "Report Bug…")
            onTriggered: Qt.openUrlExternally(Controller.distroBugReportUrl())
        }
    }

    Kirigami.AbstractCard {
        anchors.centerIn: parent

        width: Kirigami.Units.gridUnit * 20
        height: Kirigami.Units.gridUnit * 10

        // Only show when relevant, otherwise, the PlaceholderMessage is shown
        opacity: nmLoader.available && !nmLoader.statusConnected ? 1 : 0
        visible: opacity > 0
        layer.enabled: true

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        // Container for everything else so we don't have the apply margins
        // multiple times
        Item {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing

            clip: true

            // Wallpaper background image
            Image {
                anchors.fill: parent

                fillMode: Image.PreserveAspectCrop
                source: "file:" + Controller.installPrefix() + "/share/wallpapers/Next/contents/images/1024x768.png"
                sourceClipRect: Qt.rect(1024-parent.width, // Bottom-right of image
                                        768-parent.height,
                                        parent.width,
                                        parent.height)

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

                width: 1024 // This overflows, but we clip and it means no rounding to the left
                            // 1024 specifically improves appearance with Oxygen style and
                            // matches the background width
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

                    Item {
                        Layout.fillWidth: true
                    }

                    // System Tray
                    RowLayout {
                        id: appletSystemTray

                        readonly property int iconMargins: Kirigami.Units.smallSpacing

                        spacing: 0

                        KSvg.SvgItem {
                            Layout.leftMargin: appletSystemTray.iconMargins
                            Layout.rightMargin: appletSystemTray.iconMargins

                            implicitWidth: appletContainer.iconSize
                            implicitHeight: appletContainer.iconSize
                            imagePath: "icons/klipper"
                            elementId: "klipper"
                        }

                        KSvg.SvgItem {
                            Layout.leftMargin: appletSystemTray.iconMargins
                            Layout.rightMargin: appletSystemTray.iconMargins

                            implicitWidth: appletContainer.iconSize
                            implicitHeight: appletContainer.iconSize
                            imagePath: "icons/audio"
                            elementId: "audio-volume-high"
                        }

                        KSvg.SvgItem {
                            id: networkingIcon

                            Layout.leftMargin: appletSystemTray.iconMargins
                            Layout.rightMargin: appletSystemTray.iconMargins

                            implicitWidth: appletContainer.iconSize
                            implicitHeight: appletContainer.iconSize
                            imagePath: "icons/network"
                            elementId: nmLoader.icon

                            PC3.BusyIndicator {
                                id: connectingIndicator

                                anchors.centerIn: parent
                                height: Math.min(parent.width, parent.height)
                                width: height
                                running: nmLoader.iconConnecting
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
                        implicitWidth: panelContainer.contentHeight
                        implicitHeight: panelContainer.contentHeight

                        KSvg.SvgItem {
                            anchors.centerIn: parent

                            implicitWidth: appletContainer.iconSize
                            implicitHeight: appletContainer.iconSize
                            imagePath: "icons/user"
                            elementId: "user-desktop"
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

                readonly property int startY: endY - Kirigami.Units.gridUnit
                readonly property int endY: parent.height - panelContainer.height - height - panelContainer.anchors.margins

                anchors.right: panelContainer.right
                anchors.rightMargin: - (width / 2)                                                        // Center the arrow on target
                                     + appletContainer.width + appletContainer.anchors.rightMargin        // Align with the left of the appletContainer
                                     - (appletContainer.iconSize / 2 + appletSystemTray.iconMargins * 2)  // Align with the first icon
                                     - (appletContainer.iconSize + appletSystemTray.iconMargins * 2 ) * 2 // Align with the network icon

                layer.enabled: true
                layer.effect: Glow {
                    radius: 6
                    samples: (radius * 2) + 1
                    spread: 0.5
                    color: "white"
                }

                SequentialAnimation on y {
                    running: pageStack.currentItem == root && nmLoader.available && !nmLoader.statusConnected
                    loops: Animation.Infinite
                    alwaysRunToEnd: true

                    NumberAnimation {
                        from: indicatorArrow.startY
                        to: indicatorArrow.endY
                        duration: 1000
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        from: indicatorArrow.endY
                        to: indicatorArrow.startY
                        duration: 1000
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    footer: Kirigami.InlineMessage {
        position: Kirigami.InlineMessage.Footer
        visible: Controller.patchVersion === 80
        text: i18nc("@info", "This page is being shown regardless of network connectivity because you are using a development version.")
    }
}
