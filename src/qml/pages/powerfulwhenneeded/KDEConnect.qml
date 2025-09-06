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
import org.kde.kirigamiaddons.components as KirigamiComponents
import org.kde.prison as Prison

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Welcome.Page {
    id: page

    heading: i18nc("@info:window", "KDE Connect")
    description: xi18nc("@info:usagetip", "KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience.")

    // FIXME: KDE Connect subdomain requires ".html" at the end of URLs else they 404
    readonly property string kdeConnectUrl: "https://kdeconnect.kde.org/download.html"

    readonly property var spiel: [
        {
            // Mobile notifications, calls (notif & pause media auto) and SMS messages
            icon: "preferences-desktop-notification",
            title: i18nc("@title", "Stay in the loop"),
            description: i18nc("@info:usagetip", "Receive notifications from your phone, not just from apps, but text messages and calls. You can reply to messages straight from Plasma, and inbound calls will pause media automatically.")
        },
        {
            // Transfer files
            icon: "system-file-manager",
            title: i18nc("@title", "Your files, anywhere"),
            description: i18nc("@info:usagetip", "Don't bother plugging in your phone, looking around for an old USB stick, or using cloud storage for simple file transfers — KDE Connect will deliver your file wherever it's needed.")
        },
        {
            // Shared clipboard
            icon: "klipper",
            title: i18nc("@title", "One clipboard to rule them all"),
            description: i18nc("@info:usagetip", "Copy something on your laptop, paste it on your desktop. KDE Connect keeps your clipboard in sync across all your devices.")
        },
        {
            // Media controls
            icon: "applications-multimedia",
            title: i18nc("@title", "Now Playing"),
            description: i18nc("@info:usagetip", "Pause, play, skip, seek — on any device. KDE Connect shares media controls between devices.")
        },
        {
            // Ping to find phone
            icon: "preferences-desktop-search",
            title: i18nc("@title", "It's here, somewhere"),
            description: i18nc("@info:usagetip", "Misplaced your phone? Ring it and find it.")
        },
        {
            // No ads, no tracking, all local and free
            icon: "donate",
            title: i18nc("@title", "Private and Free"),
            description: i18nc("@info:usagetip", "KDE Connect works entirely locally, on your own network — and it’s completely free to use.")
        }
    ]

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
                content: page.kdeConnectUrl
            }

            Kirigami.UrlButton {
                Layout.alignment: Qt.AlignHCenter

                text: i18nc("@action:button", "Download KDE Connect")
                url: page.kdeConnectUrl
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

            ColumnLayout {
                anchors.fill: parent

                spacing: 0

                ListView {
                    id: slideshowView

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    spacing: 0

                    currentIndex: 0

                    clip: true
                    orientation: ListView.Horizontal
                    snapMode: ListView.SnapToItem
                    highlightRangeMode: ListView.StrictlyEnforceRange

                    preferredHighlightBegin: 0
                    preferredHighlightEnd: width

                    highlightMoveDuration: Kirigami.Units.longDuration
                    highlightResizeDuration: Kirigami.Units.longDuration

                    model: page.spiel

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
                            anchors.leftMargin: backButton.width + Kirigami.Units.gridUnit
                            anchors.rightMargin: forwardButton.width + Kirigami.Units.gridUnit
                            anchors.topMargin: Kirigami.Units.gridUnit
                            anchors.bottomMargin: Kirigami.Units.gridUnit

                            spacing: Kirigami.Units.gridUnit

                            Item {
                                Layout.fillWidth: true
                            }

                            Item {
                                id: delegateIcon
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: implicitWidth

                                // Only show if using no more than a fifth of the available width
                                readonly property bool show: {
                                    if (delegate.width < 0) {
                                        // Initially, it'll be negative
                                        return true;
                                    }
                                    return Kirigami.Units.iconSizes.enormous <= (delegate.width / 5);
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
                                    wrapMode: Text.WordWrap
                                    elide: Text.ElideRight
                                    text: delegate.title
                                }

                                Kirigami.Heading {
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.fillWidth: true

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

                QQC2.PageIndicator {
                    Layout.alignment: Qt.AlignHCenter

                    count: slideshowView.count
                    currentIndex: slideshowView.currentIndex
                    onCurrentIndexChanged: slideshowView.currentIndex = currentIndex
                    interactive: true
                }
            }

            KirigamiComponents.FloatingButton {
                id: backButton
                anchors.left: parent.left

                height: parent.height
                leftMargin: LayoutMirroring.enabled ? 0 : Kirigami.Units.gridUnit
                rightMargin: LayoutMirroring.enabled ? Kirigami.Units.gridUnit : 0
                radius: Infinity

                icon.name: LayoutMirroring.enabled ? "arrow-right-symbolic" : "arrow-left-symbolic"
                text: i18nc("@action:button", "Previous")

                enabled: slideshowView.currentIndex > 0
                onPressed: slideshowView.decrementCurrentIndex()

                opacity: enabled ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.OutCubic
                    }
                }

                transform: Translate {
                    x: backButton.enabled ? 0 : Kirigami.Units.gridUnit * -2

                    Behavior on x {
                        NumberAnimation {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            KirigamiComponents.FloatingButton {
                id: forwardButton
                anchors.right: parent.right

                height: parent.height
                leftMargin: LayoutMirroring.enabled ? Kirigami.Units.gridUnit : 0
                rightMargin: LayoutMirroring.enabled ? 0 : Kirigami.Units.gridUnit
                radius: Infinity

                icon.name: LayoutMirroring.enabled ? "arrow-left-symbolic" : "arrow-right-symbolic"
                text: i18nc("@action:button", "Next")

                enabled: slideshowView.currentIndex < (slideshowView.count - 1)
                onPressed: slideshowView.incrementCurrentIndex()

                opacity: enabled ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.OutCubic
                    }
                }

                transform: Translate {
                    x: forwardButton.enabled ? 0 : Kirigami.Units.gridUnit * 2

                    Behavior on x {
                        NumberAnimation {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.OutCubic
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
