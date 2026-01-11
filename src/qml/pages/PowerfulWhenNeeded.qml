/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

import org.kde.plasma.welcome as Welcome

Welcome.Page {
    heading: i18nc("@info:window", "Powerful When Needed")
    // Don't change the weird indentation; it's intentional to make this
    // long string nicer for translators
    description: xi18nc("@info:usagetip", "Plasma is an extremely feature-rich environment, designed to super-charge your productivity!<nl/><nl/>\
Click below to see just a smattering of what we can do for you:")

    ColumnLayout {
        id: layout
        anchors.fill: parent

        spacing: Kirigami.Units.largeSpacing

        FormCard.FormCard {
            id: formCard

            // Ensure all delegates reserve a gap if there are any unread
            // and the gap disappears when there are no unread
            property bool hasUnread: false

            maximumWidth: Kirigami.Units.gridUnit * 25

            Repeater {
                model: [
                    {
                        leadingIcon: "preferences-desktop-keyboard-shortcut",
                        title: i18nc("@title:row", "Keyboard Shortcuts"),
                        subtitle: i18nc("@info Caption for Get Keyboard Shortcuts button", "Activate features from the keyboard"),
                        page: "MetaKey.qml"
                    },
                    {
                        leadingIcon: "kwin",
                        title: i18nc("@title:row Name of the 'Overview' KWin effect", "Overview"),
                        subtitle: i18nc("@info Caption for Overview button", "Your system command center"),
                        page: "Overview.qml"
                    },
                    {
                        leadingIcon: "krunner",
                        title: i18nc("@title:row", "KRunner"),
                        subtitle: i18nc("@info Caption for KRunner button", "Search for anything"),
                        page: "KRunner.qml"
                    },
                    {
                        leadingIcon: "kdeconnect",
                        title: i18nc("@title:row Name of the 'KDE Connect' feature", "KDE Connect"),
                        subtitle: i18nc("@info Caption for KDE Connect button", "Connect your phone and your computer"),
                        page: "KDEConnect.qml"
                    },
                    {
                        leadingIcon: "preferences-desktop-activities",
                        title: i18nc("@title:row Name of the 'Activities' Plasma feature", "Activities"),
                        subtitle: i18nc("@info Caption for Activities button. Note that 'Separate' is being used as an imperative verb here, not a noun.", "Separate work, school, or home tasks"),
                        page: "Activities.qml"
                    },
                    {
                        leadingIcon: "plasmavault",
                        title: i18nc("@title:row Short form of the 'Vaults' Plasma feature", "Vaults"),
                        subtitle: i18nc("@info Caption for Plasma Vaults button", "Store sensitive files securely"),
                        page: "Vaults.qml"
                    }
                ]
                delegate: FormCard.FormButtonDelegate {
                    id: delegate

                    required property string leadingIcon
                    required property string title
                    required property string subtitle
                    required property string page

                    property bool read: false

                    // We can set icon.name, but we want it bigger
                    leading: Kirigami.Icon {
                        implicitWidth: Kirigami.Units.iconSizes.medium
                        implicitHeight: Kirigami.Units.iconSizes.medium

                        source: delegate.leadingIcon
                    }

                    text: delegate.title
                    description: delegate.subtitle

                    Binding {
                        target: formCard
                        when: !delegate.read
                        property: "hasUnread"
                        value: true
                    }

                    trailing: Rectangle {
                        id: unreadIndicator

                        implicitWidth: Kirigami.Units.largeSpacing
                        implicitHeight: Kirigami.Units.largeSpacing

                        opacity: delegate.read ? 0 : 1
                        visible: formCard.hasUnread
                        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration; easing.type: Easing.InOutQuad }}

                        radius: Infinity
                        color: Kirigami.Theme.activeTextColor
                    }

                    onClicked: {
                        pageStack.layers.push(app._createPage(delegate.page))
                        delegate.read = true;
                    }
                }
            }
        }

        Kirigami.UrlButton {
            text: i18nc("@action:button", "Learn about more Plasma features")
            url: "https://userbase.kde.org/Plasma?source=plasma-welcome"
        }
    }
}
