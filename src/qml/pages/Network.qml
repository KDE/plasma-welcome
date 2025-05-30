/*
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtNetwork
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Welcome.Page {
    id: root

    heading: i18nc("@info:window", "Access the Internet")
    description: xi18nc("@info:usagetip", "You can connect to the internet and manage your network connections with the <interface>Networks applet</interface>. To access it, click on the <interface>Networks</interface> icon in your <interface>System Tray</interface>, which lives in the bottom-right corner of the screen.")

    show: NetworkInformation.reachability !== NetworkInformation.Reachability.Online || Private.Release.isDevelopment

    PlasmaNMLoader {
        id: nmLoader
    }

    Kirigami.PlaceholderMessage {
        id: errorMessage

        anchors.centerIn: parent
        width: parent.width - Kirigami.Units.gridUnit * 2

        // Shown when PlasmaNM is not available
        visible: nmLoader.state == "NoPlasmaNM"

        icon.name: "data-warning-symbolic"
        text: i18nc("@info:placeholder", "Networking support for Plasma is not currently installed")
        explanation: xi18nc("@info:usagetip %1 is the name of the user's distro", "To manage network connections, Plasma requires <icode>plasma-nm</icode> to be installed. Please report this omission to %1.", Welcome.Distro.name)
        helpfulAction: Kirigami.Action {
            enabled: nmLoader.state === "NoPlasmaNM"
            icon.name: "tools-report-bug-symbolic"
            text: i18nc("@action:button", "Report Bug…")
            onTriggered: Qt.openUrlExternally(Welcome.Distro.bugReportUrl)
        }
    }

    Private.MockCard {
        id: mock
        anchors.fill: parent

        backgroundAlignment: Qt.AlignRight | Qt.AlignBottom
        visible: nmLoader.state !== "NoPlasmaNM"

        opacity: nmLoader.state === "Connected" ? 0.6 : 1
        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        Private.MockPanel {
            id: mockPanel
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            width: Math.max(mock.desktopWidth, parent.width)

            Private.MockKickoffApplet {
                opacity: (mockPanel.x >= 0) ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Private.MockSystemTrayApplet {
                id: mockSystemTray


                Private.MockSystemTrayIcon {
                    source: "audio-volume-high-symbolic"
                }

                Private.MockSystemTrayIcon {
                    source: "brightness-high-symbolic"
                }

                Private.MockSystemTrayIcon {
                    id: mockNmTrayIcon

                    source: nmLoader.icon

                    PC3.BusyIndicator {
                        anchors.centerIn: parent

                        // Yes, it's not square
                        width: 30
                        height: 28

                        running: nmLoader.iconConnecting
                    }

                    Item {
                        id: indicatorArrowContainer

                        readonly property bool animate: visible && nmLoader.state !== "Connected" && pageStack.currentItem === root

                        implicitWidth: indicatorArrow.implicitWidth + glowPadding * 2
                        implicitHeight: indicatorArrow.implicitHeight + glowPadding * 2

                        // Prevents clipping of the glow effect
                        property real glowPadding: 16

                        property real yOffset: Kirigami.Units.gridUnit

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.top
                        anchors.bottomMargin: yOffset - glowPadding
                                                + ((mockSystemTray.height - mockNmTrayIcon.height) / 2)

                        SequentialAnimation on yOffset {
                            running: indicatorArrowContainer.animate
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

                        layer.enabled: true
                        opacity: animate ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Kirigami.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Kirigami.Icon {
                            id: indicatorArrowGlow
                            anchors.fill: indicatorArrow

                            layer.enabled: GraphicsInfo.api !== GraphicsInfo.Software
                            layer.effect: MultiEffect {
                                autoPaddingEnabled: false
                                paddingRect: Qt.rect(indicatorArrowContainer.glowPadding,
                                                     indicatorArrowContainer.glowPadding,
                                                     indicatorArrowContainer.glowPadding,
                                                     indicatorArrowContainer.glowPadding)
                                blurEnabled: true
                                blur: 1
                                blurMax: 2
                            }

                            source: "arrow-down"
                            color: Kirigami.Theme.backgroundColor
                        }

                        Kirigami.Icon {
                            id: indicatorArrow
                            anchors.centerIn: indicatorArrowContainer

                            implicitWidth: Kirigami.Units.iconSizes.large * 1.5
                            implicitHeight: Kirigami.Units.iconSizes.large * 1.5

                            source: "arrow-down"
                        }
                    }
                }
            }

            Private.MockDigitalClockApplet {}

            Private.MockShowDesktopApplet {}
        }
    }

    Kirigami.PlaceholderMessage {
        id: connectedMessage
        anchors.centerIn: parent

        width: parent.width - Kirigami.Units.gridUnit * 2

        // Shown when connected
        visible: nmLoader.state === "Connected"

        icon.name: "data-success-symbolic"
        text: i18nc("@info:placeholder Shown when connected to the internet", "You’re connected")
        explanation: i18nc("@info:usagetip Shown when connected to the internet", "All good to go!")
        type: Kirigami.PlaceholderMessage.Type.Actionable
    }

    footer: Kirigami.InlineMessage {
        position: Kirigami.InlineMessage.Footer
        visible: Private.Release.isDevelopment
        text: i18nc("@info", "This page is being shown regardless of network connectivity because you are using a development version. To manually preview the different states of the page, you can use the button.")
        showCloseButton: true

        actions: [
            Kirigami.Action {
                text: i18nc("@action:button", "Change state")
                onTriggered: {
                    let stateIndex = nmLoader.states.findIndex(state => state.name === nmLoader.state)
                    nmLoader.state = nmLoader.states[(stateIndex + 1) % nmLoader.states.length].name
                }
            }
        ]
    }
}
