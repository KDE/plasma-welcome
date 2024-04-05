/*
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome

GenericPage {
    id: root

    heading: i18nc("@info:window", "Access the Internet")
    description: xi18nc("@info:usagetip", "You can connect to the internet and manage your network connections with the <interface>Networks applet</interface>. To access it, click on the <interface>Networks</interface> icon in your <interface>System Tray</interface>, which lives in the bottom-right corner of the screen.")

    Loader {
        id: nmLoader
        source: "PlasmaNM.qml"

        // Defaults for when PlasmaNM is not available
        property bool statusConnected: false
        property bool iconConnecting: false
        property string icon: "network-wireless-available"

        onStatusChanged: {
            if (status === Loader.Ready) {
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

    states: [
        State {
            name: "NoPlasmaNM" // Shows error message
            when: nmLoader.status == Loader.Error
        },
        State {
            name: "Connected" // Shows card and connected message
            when: nmLoader.statusConnected
        },
        State {
            name: "Disconnected" // Shows card
            when: !nmLoader.statusConnected
        }
    ]

    Kirigami.PlaceholderMessage {
        id: errorMessage

        anchors.centerIn: parent
        width: parent.width - Kirigami.Units.gridUnit * 2

        // Shown when PlasmaNM is not available
        visible: root.state == "NoPlasmaNM"

        icon.name: "data-warning-symbolic"
        text: i18nc("@info:placeholder", "Networking support for Plasma is not currently installed")
        explanation: xi18nc("@info:usagetip %1 is the name of the user's distro", "To manage network connections, Plasma requires <icode>plasma-nm</icode> to be installed. Please report this omission to %1.", Controller.distroName())
        helpfulAction: Kirigami.Action {
            enabled: root.state == "NoPlasmaNM"
            icon.name: "tools-report-bug-symbolic"
            text: i18nc("@action:button", "Report Bug…")
            onTriggered: Qt.openUrlExternally(Controller.distroBugReportUrl())
        }
    }

    Kirigami.AbstractCard {
        anchors.fill: parent

        // Shown when the user is connected or disconnected
        visible: (root.state == "Connected" || root.state == "Disconnected") ? 1 : 0

        MockPanel {
            id: mockPanel

            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing

            clip: true

            onlyShowTrayArea: true
            networkArrowAnimates: visible && root.state !== "Connected" && pageStack.currentItem == root
            networkIconConnecting: nmLoader.iconConnecting
            networkIcon: nmLoader.icon

            opacity: root.state == "Connected" ? 0.6 : 1
            layer.enabled: true

            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Kirigami.PlaceholderMessage {
            id: connectedMessage

            anchors.centerIn: mockPanel
            width: mockPanel.width - Kirigami.Units.gridUnit * 2

            // Shown when connected
            visible: root.state == "Connected"

            icon.name: "data-success-symbolic"
            text: i18nc("@info:placeholder Shown when connected to the internet", "You're connected")
            explanation: i18nc("@info:usagetip Shown when connected to the internet", "All good to go!")
            type: Kirigami.PlaceholderMessage.Type.Actionable
        }
    }

    footer: Kirigami.InlineMessage {
        position: Kirigami.InlineMessage.Footer
        visible: Controller.patchVersion === 80
        text: i18nc("@info", "This page is being shown regardless of network connectivity because you are using a development version. To manually preview the different states of the page, you can use the button.")
        showCloseButton: true

        actions: [
            Kirigami.Action {
                text: i18nc("@action:button", "Change state")
                onTriggered: {
                    let stateIndex = root.states.findIndex(state => state.name == root.state)
                    root.state = root.states[(stateIndex + 1) % root.states.length].name
                }
            }
        ]
    }
}
