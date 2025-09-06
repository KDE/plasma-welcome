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

            ListView {
                id: slideshowView
                anchors.fill: parent

                orientation: ListView.Horizontal
                snapMode: ListView.SnapOneItem
                pixelAligned: true
                reuseItems: true

                currentIndex: 0

                model: [
                    {
                        // Mobile notifications, calls (notif & pause media auto) and SMS messages
                        icon: "preferences-desktop-notification",
                        title: "AaBbCcDdEeFf",
                        description: "AaBbCcDdEeFf"
                    },
                    {
                        // Transfer files
                        icon: "emblem-shared", // TODO: Better, konqi?
                        title: "AaBbCcDdEeFf",
                        description: "AaBbCcDdEeFf"
                    },
                    {
                        // Shared clipboard
                        icon: "klipper",
                        title: "AaBbCcDdEeFf",
                        description: "AaBbCcDdEeFf"
                    },
                    {
                        // Media controls
                        icon: "applications-multimedia",
                        title: "Foobar!",
                        description: "AaBbCcDdEeFf"
                    },
                    {
                        // Ping to find phone
                        icon: "preferences-desktop-search", // maybe "hands-free"
                        title: "Testing, testing 123!",
                        description: "AaBbCcDdEeFf"
                    },
                    {
                        // No ads, no tracking, all local and free
                        icon: "donate", // maybe a konqi
                        title: "AaBbCcDdEeFf",
                        description: "AaBbCcDdEeFf"
                    }
                ]

                delegate: Item {
                    id: delegate

                    required property string icon
                    required property string title
                    required property string description

                    width: slideshowView.width
                    height: slideshowView.height

                    clip: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.gridUnit

                        spacing: Kirigami.Units.gridUnit

                        Item {
                            Layout.fillWidth: true
                        }

                        Item {
                            id: delegateIcon
                            Layout.alignment: Qt.AlignCenter
                            Layout.preferredWidth: implicitWidth

                            // Only show if using no more than a quarter of the available width
                            readonly property bool show: {
                                if (delegate.width < 0) {
                                    // Initially, it'll be negative
                                    return true;
                                }
                                return Kirigami.Units.iconSizes.enormous <= (delegate.width / 4);
                            }

                            implicitWidth: show ? Kirigami.Units.iconSizes.enormous : 0
                            implicitHeight: Kirigami.Units.iconSizes.enormous
                            opacity: show ? 1 : 0
                            visible: opacity > 0

                            Behavior on implicitWidth {
                                PropertyAnimation {
                                    easing.type: Easing.InOutQuad
                                    duration: Kirigami.Units.longDuration
                                }
                            }

                            Behavior on opacity {
                                PropertyAnimation {
                                    easing.type: Easing.InOutQuad
                                    duration: Kirigami.Units.longDuration
                                }
                            }

                            Kirigami.Icon {
                                anchors.verticalCenter: delegateIcon.verticalCenter
                                anchors.right: delegateIcon.right

                                implicitWidth: Kirigami.Units.iconSizes.enormous
                                implicitHeight: Kirigami.Units.iconSizes.enormous
                                source: delegate.icon
                            }
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillHeight: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 24

                            Kirigami.Heading {
                                id: title
                                Layout.alignment: Qt.AlignCenter
                                Layout.fillWidth: true

                                level: 1
                                maximumLineCount: 1
                                elide: Text.ElideRight
                                text: delegate.title
                            }

                            Kirigami.Heading {
                                Layout.alignment: Qt.AlignCenter
                                Layout.fillWidth: true
                                Layout.maximumHeight: delegateIcon.height - parent.spacing - title.height

                                level: 2
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                text: delegate.description
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }

        Kirigami.AbstractCard {
            contentItem: QQC2.Label {
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap

                text: kdeConnectApp.exists ? i18nc("@info:usagetip", "To get started with KDE Connect, open it on your device and install it on at least one other.")
                                           : i18nc("@info:usagetip", "To get started with KDE Connect, install it on your device and at least one other.")
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
