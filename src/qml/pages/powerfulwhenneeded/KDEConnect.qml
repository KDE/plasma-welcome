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
import org.kde.plasma.welcome.private as Private

Kirigami.Page {
    title: i18nc("@info:window", "KDE Connect")

    Welcome.ApplicationInfo {
        id: kdeConnectApp
        desktopName: "org.kde.kdeconnect.app"
    }

    ColumnLayout {
        anchors.fill: parent

        spacing: Kirigami.Units.gridUnit

        Item {
            id: textContainer
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true

            QQC2.Label {
                anchors.fill: parent

                text: xi18nc("@info:usagetip", "KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience.<nl/>KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience. KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience. KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience. KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience. KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience. KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience. KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience. KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience. KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience. KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience. KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience. KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience. KDE Connect allows you to integrate your phone and other devices with your computer, for a unified experience.")
                wrapMode: Text.Wrap

                onLineLaidOut: (line) => {
                    const margin = Kirigami.Units.smallSpacing;
                    if (line.y + line.height + margin > mockAppContainer.y) {
                        line.width = Math.min(line.width, mockAppContainer.x - line.x - margin);
                    }
                }
            }

            Item {
                id: mockAppContainer
                //color: "black"

                x: (textContainer.width / 2) + Kirigami.Units.gridUnit
                width: (textContainer.width / 2) - Kirigami.Units.gridUnit

                y: (textContainer.height / 4) + Kirigami.Units.gridUnit
                height: (textContainer.height * (3/4)) - Kirigami.Units.gridUnit

                Private.MockKDEConnectApp {
                    anchors.fill: parent
                }
            }
        }

        Kirigami.AbstractCard {
            Layout.alignment: Qt.AlignBottom

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
