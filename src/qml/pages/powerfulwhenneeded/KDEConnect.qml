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

Welcome.Page {
    heading: i18nc("@info:window", "KDE Connect")

    // Don't change the weird indentation; it's intentional to make this
    // long string nicer for translators
    description: xi18nc("@info:usagetip", "KDE Connect lets you integrate your phone with your computer in various ways:\
<nl/>\
<list><item>See notifications from your phone on your computer</item>\
<item>Reply to text messages from your phone on your computer</item>\
<item>Sync your clipboard contents between your computer and your phone</item>\
<item>Make a noise on your phone when it’s been misplaced</item>\
<item>Copy pictures, videos, and other files from your phone to your computer, and vice versa</item>\
<item>…And much more!</item></list>")

    QQC2.Label {
        Layout.fillWidth: true

        visible: openKDEConnectAction.visible

        text: xi18nc("@info:usagetip", "To get started, click the <interface>%1</interface> button. You can pair your phone there.", openKDEConnectAction.text)
        wrapMode: Text.Wrap
    }

    Welcome.ApplicationInfo {
        id: kdeConnectApp
        desktopName: "org.kde.kdeconnect.app"
    }

    actions: [
        Kirigami.Action {
            id: openKDEConnectAction
            visible: kdeConnectApp.exists

            icon.name: kdeConnectApp.icon ?? "unknown"
            text: i18nc("@action:button", "Open %1", kdeConnectApp.name ?? "")

            onTriggered: Welcome.Utils.launchApp(kdeConnectApp.desktopName)
        }
    ]

    footer: Kirigami.InlineMessage {
        position: Kirigami.InlineMessage.Footer
        visible: !openKDEConnectAction.visible

        type: Kirigami.MessageType.Information

        text: i18nc("@info", "KDE Connect is not installed.")

        actions: [
            Kirigami.Action {
                icon.name: "edit-download-symbolic"
                text: i18nc("@action:button Install KDE Connect", "Install KDE Connect…")
                onTriggered: Qt.openUrlExternally("appstream://org.kde.kdeconnect.app")
            }
        ]
    }
}
