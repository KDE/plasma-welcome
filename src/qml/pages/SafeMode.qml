/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Kirigami.ScrollablePage {
    id: root

    title: i18nc("@title", "This is a Safe Mode Session")

    actions: [
        Kirigami.Action {
            text: i18nc("@action:inmenu", "About Welcome Center")
            icon.name: "start-here-kde-plasma"
            onTriggered: pageStack.layers.push(aboutAppPage)
            displayHint: Kirigami.DisplayHint.AlwaysHide
        },
        Kirigami.Action {
            text: i18nc("@action:inmenu", "About KDE")
            icon.name: "kde"
            onTriggered: pageStack.layers.push(aboutKDEPage)
            displayHint: Kirigami.DisplayHint.AlwaysHide
        }
    ]

    Component {
        id: aboutKDEPage

        FormCard.AboutKDEPage {}
    }

    Component {
        id: aboutAppPage

        FormCard.AboutPage {}
    }

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing * 2
        width: parent.width
        height: Math.max(implicitHeight, parent.height)

        RowLayout {
            spacing: Kirigami.Units.largeSpacing
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 1
            }
            Kirigami.Icon {
                id: safeModeIcon
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: Kirigami.Units.iconSizes.enormous
                implicitHeight: implicitWidth
                source: "dialog-warning"
            }
            QQC2.Label {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.maximumWidth: safeModeIcon.width * 27 / 10
                text: xi18nc("@info:usagetip", "Safe Mode is meant to help you troubleshoot problems, so you can log into a regular KDE Plasma session again.")
                wrapMode: Text.Wrap
            }
            Item {
                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 3
            }
        }

        QQC2.Label {
            Layout.fillWidth: true

            text: xi18nc("@info:usagetip", "You can use Safe Mode to back up your data, or to reset user customizations for your next login. When you are done, log out and switch back to your regular session.<nl/><nl/>In Safe Mode, your usual desktop and application settings are ignored. All of your settings were preserved; they will be used again when you return to your regular session.<nl/><nl/>Desktop and application settings in Safe Mode are temporary. They will be lost on logout.")
            wrapMode: Text.Wrap

            Layout.fillHeight: true
        }

        Kirigami.AbstractCard {
            Layout.fillWidth: true

            contentItem: QQC2.Label {
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                text: xi18nc("@info:usagetip", "Find out how you can find more information and ask others for help.")
            }

            footer: RowLayout {
                spacing: 0

                Kirigami.UrlButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: i18nc("@action:button", "Help & Support for KDE Software")
                    url: "https://kde.org/support/"
                }
            }
        }
    }
}
