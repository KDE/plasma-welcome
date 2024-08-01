/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils

import org.kde.plasma.welcome

GenericPage {
    id: root

    // TODO: KDE Connect might not be installed:
    // We should hide the action and have one to install

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

    actions: [
        Kirigami.Action {
            icon.name: "kdeconnect"
            text: i18nc("@action:button", "Open Settings…")
            onTriggered: KCMUtils.KCMLauncher.openSystemSettings("kcm_kdeconnect")
        }
    ]

    ColumnLayout {
        anchors.fill: parent

        spacing: root.padding

        Kirigami.AbstractCard {
            Layout.fillWidth: true
            Layout.fillHeight: true

            MockDesktop {
                id: mockDesktop
                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing

                backgroundAlignment: Qt.AlignHCenter | Qt.AlignBottom

                // Prevent interaction with MockDesktop and children
                InteractionInhibitor {}

                MockPanel {
                    id: mockPanel
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right

                    width: Math.max(mockDesktop.desktopWidth, mockDesktop.width)

                    MockKickoffApplet {
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

                    MockSystemTrayApplet {
                        id: mockSystemTrayApplet

                        MockSystemTrayIcon {
                            source: "klipper-symbolic"
                        }

                        MockSystemTrayIcon {
                            source: "audio-volume-high-symbolic"
                        }

                        MockSystemTrayIcon {
                            source: "network-wired-activated"
                        }
                    }

                    MockDigitalClockApplet {}

                    MockShowDesktopApplet {}
                }

                MockNotification {
                    id: mockNotification
                    anchors.right: mockPanel.right
                    anchors.rightMargin: 36
                    anchors.bottom: mockPanel.top
                    anchors.bottomMargin: 52

                    title: "notify-send"

                    Kirigami.Heading {
                        text: "test"
                        level: 4
                        width: parent.width
                    }
                }
            }
        }

        QQC2.Label {
            Layout.fillWidth: true

            text: xi18nc("@info:usagetip", "To get started, launch <interface>System Settings</interface> and search for “KDE Connect”. On that page, you can pair your phone.")
            wrapMode: Text.WordWrap
        }
    }
}
