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
        height: Math.max(implicitHeight, parent.height)

        QQC2.Label {
            Layout.fillWidth: true

            text: xi18nc("@info:usagetip", "Your usual Plasma and app settings have been safely preserved for later, but are not being used right now. They will be used again when you return to your regular Plasma session.<nl/><nl/>Here are some actions you can take to try fixing your regular Plasma session:")
            wrapMode: Text.Wrap
        }

        FormCard.FormCard {
            id: formCard

            Layout.alignment: Qt.AlignTop
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
                    {
                        leadingIcon: "edit-reset",
                        title: i18nc("@title:row", "Reset Customizations and Restore Defaults"),
                        subtitle: i18nc("@info subtitle for Reset Customizations", "Your data will be safely backed up"),
                        page: "ResetCustomizations.qml"
                    },
                    {
                        leadingIcon: "document-import",
                        title: i18nc("@title:row", "Restore Customizations"),
                        subtitle: i18nc("@info subtitle for Restore Customizations", "Select a backup location to restore previous customizations"),
                        page: "RestoreCustomizations.qml"
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

        QQC2.Label {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            text: xi18nc("@info:usagetip", "Manual changes made to Plasma and apps while in Safe Mode will be lost when you return to your regular Plasma session.")
            wrapMode: Text.Wrap

            Layout.fillHeight: true
        }

        // Kirigami.AbstractCard {
        //     Layout.fillWidth: true
        //
        //     contentItem: QQC2.Label {
        //         horizontalAlignment: Text.AlignHCenter
        //         wrapMode: Text.Wrap
        //         text: xi18nc("@info:usagetip", "Find out how you can find more information and ask others for help.")
        //     }
        //
        //     footer: RowLayout {
        //         spacing: 0
        //
        //         Kirigami.UrlButton {
        //             Layout.alignment: Qt.AlignHCenter
        //             text: i18nc("@action:button", "Help & Support for KDE Software")
        //             url: "https://kde.org/support/"
        //         }
        //     }
        // }
    }
}
