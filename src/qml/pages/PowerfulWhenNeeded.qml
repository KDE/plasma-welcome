/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome

Welcome.Page {
    heading: i18nc("@info:window", "Powerful When Needed")
    // Don't change the weird indentation; it's intentional to make this
    // long string nicer for translators
    description: xi18nc("@info:usagetip", "Plasma is an extremely feature-rich environment, designed to super-charge your productivity!<nl/><nl/>\
Click the cards below to see just a smattering of what it can do for you:")

    ColumnLayout {
        id: layout
        anchors.fill: parent

        spacing: Kirigami.Units.largeSpacing

        GridLayout {
            id: grid

            readonly property int columnsforHorizontalLayout: 3
            readonly property int columnsforVerticalLayout: 2
            readonly property int cellWidth: Math.round(layout.width / columns)
            readonly property int cellHeight: Math.max(...children.map(item => item.implicitHeight))
            readonly property int spaceForTitles: Math.round(layout.width / columnsforHorizontalLayout)
                                                   - children[0].fixedSizeStuff
                                                   - (columnSpacing * (columnsforHorizontalLayout - 1))
            readonly property bool verticalLayout: children.some(item => item.implicitTitleWidth > spaceForTitles)

            rows: verticalLayout ? 6 : 2
            columns: verticalLayout ? columnsforVerticalLayout : columnsforHorizontalLayout
            rowSpacing: Kirigami.Units.smallSpacing
            columnSpacing: Kirigami.Units.smallSpacing

            Repeater {
                model: [
                    {
                        page: "MetaKey.qml",
                        title: i18nc("@title:row", "Keyboard Shortcuts"),
                        subtitle: i18nc("@info Caption for Get Keyboard Shortcuts button", "Activate features from the keyboard"),
                        buttonIcon: "preferences-desktop-keyboard-shortcut"
                    },
                    {
                        page: "Overview.qml",
                        title: i18nc("@title:row Name of the 'Overview' KWin effect", "Overview"),
                        subtitle: i18nc("@info Caption for Overview button", "Your system command center"),
                        buttonIcon: "kwin"
                    },
                    {
                        page: "KRunner.qml",
                        title: i18nc("@title:row", "KRunner"),
                        subtitle: i18nc("@info Caption for KRunner button", "Search for anything"),
                        buttonIcon: "krunner"
                    },
                    {
                        page: "KDEConnect.qml",
                        title: i18nc("@title:row Name of the 'KDE Connect' feature", "KDE Connect"),
                        subtitle: i18nc("@info Caption for KDE Connect button", "Connect your phone and your computer"),
                        buttonIcon: "kdeconnect"
                    },
                    {
                        page: "Activities.qml",
                        title: i18nc("@title:row Name of the 'Activities' Plasma feature", "Activities"),
                        subtitle: i18nc("@info Caption for Activities button. Note that 'Separate' is being used as an imperative verb here, not a noun.", "Separate work, school, or home tasks"),
                        buttonIcon: "preferences-desktop-activities"
                    },
                    {
                        page: "Vaults.qml",
                        title: i18nc("@title:row Short form of the 'Vaults' Plasma feature", "Vaults"),
                        subtitle: i18nc("@info Caption for Plasma Vaults button", "Store sensitive files securely"),
                        buttonIcon: "plasmavault"
                    }
                ]
                delegate: PlasmaFeatureCard {
                    Layout.fillWidth: true
                    Layout.maximumWidth: grid.cellWidth
                    Layout.preferredHeight: grid.cellHeight
                }
            }
        }

        Kirigami.UrlButton {
            text: i18nc("@action:button", "Learn about more Plasma features")
            url: "https://userbase.kde.org/Plasma?source=plasma-welcome"
        }
    }
}
