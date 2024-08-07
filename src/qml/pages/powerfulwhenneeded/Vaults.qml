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
import org.kde.plasma.extras as PlasmaExtras

import org.kde.plasma.welcome

GenericPage {
    id: root

    heading: i18nc("@info:window", "Plasma Vaults")
    description: xi18nc("@info:usagetip", "Plasma Vaults allows you to create encrypted folders, called <interface>Vaults.</interface> Inside each Vault, you can securely store your passwords, files, pictures, and documents, safe from prying eyes. Vaults can live inside folders that are synced to cloud storage services too, providing extra privacy for that content.")

    ColumnLayout {
        anchors.fill: parent

        spacing: root.padding

        MockCard {
            id: mock
            Layout.fillWidth: true
            Layout.fillHeight: true

            backgroundAlignment: Qt.AlignHCenter | Qt.AlignBottom

            // Prevent interaction with mock and children
            InteractionInhibitor {}

            MockPanel {
                id: mockPanel
                anchors.bottom: parent.bottom
                anchors.right: parent.right

                width: Math.max(mock.desktopWidth, parent.width)

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

                    active: true

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

            MockPlasmoid {
                id: mockVaults
                anchors.right: mockPanel.right
                anchors.rightMargin: floating ? Kirigami.Units.largeSpacing : 0
                anchors.bottom: mockPanel.top

                width: Math.min(implicitWidth, parent.width - Kirigami.Units.largeSpacing * (floating ? 2 : 1))
                height: Math.min(implicitHeight, parent.height - mockPanel.height - Kirigami.Units.largeSpacing)

                floating: mockPanel.floating
                title: i18nc("@title:window Title of the Plasma Vaults popup", "Vaults")
                extraHeaderIcons: ["list-add-symbolic"]
                overflowing: mockListView.contentHeight > mockListView.parent.height

                ListView {
                    id: mockListView
                    anchors.fill: parent

                    topMargin: Kirigami.Units.smallSpacing
                    leftMargin: Kirigami.Units.smallSpacing
                    rightMargin: Kirigami.Units.smallSpacing
                    bottomMargin: Kirigami.Units.smallSpacing

                    spacing: Kirigami.Units.smallSpacing

                    model: [ i18nc("@title The name of an example Plasma vault", "Important Documents"),
                                i18nc("@title The name of an example Plasma vault", "My Photos") ]

                    delegate: PlasmaExtras.ExpandableListItem {
                        icon: "folder-encrypted"
                        title: modelData

                        defaultActionButtonAction: QQC2.Action {
                            icon.name: "unlock-symbolic"
                            text: i18nd("plasmavault-kde", "Unlock and Open")
                        }

                        contextualActions: [ QQC2.Action {} ] // For expand arrow
                    }
                }
            }
        }

        QQC2.Label {
            Layout.fillWidth: true

            text: xi18nc("@info:usagetip", "To get started, click the arrow on the <interface>System Tray</interface> to show hidden items, and then click the <interface>Vaults</interface> icon.")
            wrapMode: Text.WordWrap
        }
    }
}
