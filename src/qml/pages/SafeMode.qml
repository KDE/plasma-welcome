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
            text: i18nc("@action:button", "Help & Support")
            icon.name: root.LayoutMirroring.enabled ? "open-link-symbolic-rtl" : "open-link-symbolic"
            tooltip: xi18nc("@info:usagetip", "https://kde.org/support/<nl/><nl/>Find out how you can find more information and ask others for help about KDE software.")
            onTriggered: Qt.openUrlExternally("https://kde.org/support/")
        },
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

        QQC2.Label {
            Layout.fillWidth: true

            text: xi18nc("@info:usagetip", "Your usual Plasma and app settings have been safely preserved for later, but are not being used right now. They will be used again when you return to your regular Plasma session.<nl/><nl/>Here are some actions you can take to try fixing your regular Plasma session:")
            wrapMode: Text.Wrap
        }

        FormCard.FormCard {
            id: formCard

            maximumWidth: Kirigami.Units.gridUnit * 25

            Repeater {
                id: formCardRepeater
                model: [
                    {
                        leadingIcon: "edit-clear-all",
                        title: i18nc("@title:row", "Clear Cache Files"),
                        subtitle: i18nc("@info subtitle for Open Config Folder", "Safe to try; cache files are automatically regenerated"),
                        page: "ClearCache.qml"
                    },
                ]
                delegate: FormCard.FormButtonDelegate {
                    id: delegate

                    required property string leadingIcon
                    required property string title
                    required property string subtitle
                    required property string page

                    // We can set icon.name, but we want it bigger
                    leading: Kirigami.Icon {
                        implicitWidth: Kirigami.Units.iconSizes.medium
                        implicitHeight: Kirigami.Units.iconSizes.medium

                        source: delegate.leadingIcon
                    }

                    text: delegate.title
                    description: delegate.subtitle

                    onClicked: {
                        pageStack.layers.push(app._createPage(delegate.page))
                    }
                }
            }
        }
    }

    footer: Kirigami.InlineMessage {
        visible: true
        position: Kirigami.InlineMessage.Position.Footer
        type: Kirigami.MessageType.Warning
        text: i18nc("@info:usagetip", "Manual changes made to Plasma and apps while in Safe Mode will be lost when you return to your regular Plasma session.")
        actions: [
            Kirigami.Action {
                icon.name: Qt.application.layoutDirection === Qt.RightToLeft ? "system-log-out-rtl-symbolic" : "system-log-out-symbolic"
                text: i18nc("@action:button", "E&xit Safe Mode…")
                onTriggered: pageStack.layers.push(app._createPage("ExitSafeMode.qml"))
            }
        ]
    }
}
