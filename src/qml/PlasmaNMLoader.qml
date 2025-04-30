/*
 *  SPDX-FileCopyrightText: 2025 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Loader {
    id: nmLoader
    source: Qt.resolvedUrl("PlasmaNM.qml")

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

    states: [
        State {
            name: "NoPlasmaNM" // Shows error message
            when: status == Loader.Error
        },
        State {
            name: "Connected" // Shows card and connected message
            when: statusConnected
        },
        State {
            name: "Disconnected" // Shows card
            when: !statusConnected
        }
    ]
}
