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
import org.kde.prison as Prison

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

/*
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
*/

Welcome.Page {
    heading: i18nc("@info:window", "KDE Connect")

    description: xi18nc("@info:usagetip", "KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience.")

    Welcome.ApplicationInfo {
        id: kdeConnectApp
        desktopName: "org.kde.kdeconnect.app"
    }

    Kirigami.Dialog {
        id: otherDevicesQrDialog

        title: i18nc("@title:window", "KDE Connect for Other Devices")
        showCloseButton: true
        standardButtons: Kirigami.Dialog.NoButton

        padding: Kirigami.Units.largeSpacing

        ColumnLayout {
            spacing: Kirigami.Units.largeSpacing

            Prison.Barcode {
                Layout.fillWidth: true
                Layout.fillHeight: true

                barcodeType: Prison.Barcode.QRCode
                // FIXME: KDE Connect subdomain requires ".html" at the end of URLs else they 404
                content: "https://kdeconnect.kde.org/download.html"
            }

            Kirigami.UrlButton {
                Layout.alignment: Qt.AlignHCenter

                text: i18nc("@action:button", "Download KDE Connect")
                url: "https://kdeconnect.kde.org/download.html"
            }
        }

    }

    ColumnLayout {
        anchors.fill: parent

        spacing: Kirigami.Units.gridUnit

        Private.MockCard {
            Layout.fillWidth: true
            Layout.fillHeight: true

            applyPlasmaColors: false
            backgroundAlignment: Qt.AlignCenter
            blurRadius: 64

            Rectangle {
                anchors.fill: parent

                opacity: 0.7
                color: Kirigami.Theme.backgroundColor
            }
        }

        Kirigami.AbstractCard {
            contentItem: QQC2.Label {
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap

                text: kdeConnectApp.exists ? i18nc("@info:usagetip", "To get started with KDE Connect, open it on your device and install it on one other.")
                                           : i18nc("@info:usagetip", "To get started with KDE Connect, install it on your device and one other.")
            }

            footer: Kirigami.ActionToolBar {
                alignment: Qt.AlignHCenter

                actions: [
                    Kirigami.Action {
                        icon.name: kdeConnectApp.exists ? kdeConnectApp.icon : "install-symbolic"
                        text: kdeConnectApp.exists ? i18nc("@action:button", "Open KDE Connect…") : i18nc("@action:button", "Install KDE Connect…")
                        onTriggered: kdeConnectApp.exists ? Welcome.Utils.launchApp(kdeConnectApp.desktopName) : Qt.openUrlExternally("appstream://org.kde.kdeconnect.app")
                    },

                    Kirigami.Action {
                        icon.name: "view-barcode-qr-symbolic"
                        text: i18nc("@action:button View QR codes to install KDE Connect on other devices", "KDE Connect for Other Devices…")
                        onTriggered: otherDevicesQrDialog.open()
                    }
                ]
            }
        }
    }
}
