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
            name: "NoPlasmaNM" // Shows placeholder
            when: nmLoader.status == Loader.Error

            PropertyChanges {
                target: placeholder

                icon.name: "data-warning-symbolic"
                text: i18nc("@info:placeholder", "Networking support for Plasma is not currently installed")
                explanation: xi18nc("@info:usagetip %1 is the name of the user's distro", "To manage network connections, Plasma requires <icode>plasma-nm</icode> to be installed. Please report this omission to %1.", Controller.distroName())
            }
        },
        State {
            name: "Connected" // Shows placeholder
            when: nmLoader.statusConnected

            PropertyChanges {
                target: placeholder

                icon.name: "data-success-symbolic"
                text: i18nc("@info:placeholder Shown when connected to the internet", "You're connected")
                explanation: i18nc("@info:usagetip Shown when connected to the internet", "All good to go!")
            }
        },
        State {
            name: "Disconnected" // Shows card
            when: !nmLoader.statusConnected
        }
    ]

    Kirigami.PlaceholderMessage {
        id: placeholder

        anchors.centerIn: parent

        width: parent.width - Kirigami.Units.gridUnit * 2

        // Shown when plasma-nm is not available or the user has connected
        opacity: (root.state == "NoPlasmaNM" || root.state == "Connected") ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        helpfulAction: Kirigami.Action {
            enabled: root.state == "NoPlasmaNM"
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
        opacity: root.state == "Disconnected" ? 1 : 0
        visible: opacity > 0
        layer.enabled: true

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        MockPanel {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing

            clip: true

            animate: visible && pageStack.currentItem == root
            iconConnecting: nmLoader.iconConnecting
            icon: nmLoader.icon
        }
    }

    footer: Kirigami.InlineMessage {
        position: Kirigami.InlineMessage.Footer
        visible: Controller.patchVersion === 80
        text: i18nc("@info", "This page is being shown regardless of network connectivity because you are using a development version.")
    }
}
