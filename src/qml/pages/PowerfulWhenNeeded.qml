/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import org.kde.kcmutils as KCMUtils

import org.kde.plasma.welcome


GenericPage {
    heading: i18nc("@info:window", "Powerful When Needed")
    description: xi18nc("@info:usagetip", "Plasma is an extremely feature-rich environment, designed to super-charge your productivity! Here is just a smattering of the things it can do for you:")

    ColumnLayout {
        id: layout

        anchors {
            top: parent.top
            topMargin: grid.verticalLayout ? 0 : Kirigami.Units.largeSpacing
            left: parent.left
            right: parent.right
        }
        spacing: Kirigami.Units.largeSpacing * 4

        GridLayout {
            id: grid

            readonly property int columnsforHorizontalLayout: 3
            readonly property int columnsforVerticalLayout: 2
            readonly property int cellWidth: Math.round(layout.width / columns)
            readonly property int cellHeight: Math.max(vaults.implicitHeight,
                                                       activities.implicitHeight,
                                                       kdeconnect.implicitHeight,
                                                       overview.implicitHeight,
                                                       krunner.implicitHeight,
                                                       gns.implicitHeight)
            readonly property int spaceForTitles: Math.round(layout.width / columnsforHorizontalLayout) - vaults.fixedSizeStuff - (columnSpacing * (columnsforHorizontalLayout - 1))
            readonly property bool verticalLayout: (vaults.implicitTitleWidth > spaceForTitles)
                                               || (activities.implicitTitleWidth > spaceForTitles)
                                               || (kdeconnect.implicitTitleWidth > spaceForTitles)
                                               || (overview.implicitTitleWidth > spaceForTitles)
                                               || (krunner.implicitTitleWidth > spaceForTitles)
                                               || (gns.implicitTitleWidth > spaceForTitles)

            rows: verticalLayout ? 6 : 2
            columns: verticalLayout ? columnsforVerticalLayout : columnsforHorizontalLayout
            rowSpacing: Kirigami.Units.smallSpacing
            columnSpacing: Kirigami.Units.smallSpacing

            // First row
            PlasmaFeatureButton {
                id: vaults
                Layout.fillWidth: true
                Layout.maximumWidth: grid.cellWidth
                Layout.preferredHeight: grid.cellHeight
                title: i18nc("@title:row Short form of the 'Vaults' Plasma feature", "Vaults")
                subtitle: i18nc("@info Caption for Plasma Vaults button", "Store sensitive files securely")
                buttonIcon: "plasmavault"
                onClicked: pageStack.layers.push(vaultsView);
            }
            PlasmaFeatureButton {
                id: activities
                Layout.fillWidth: true
                Layout.maximumWidth: grid.cellWidth
                Layout.preferredHeight: grid.cellHeight
                title: i18nc("@title:row Name of the 'Activities' Plasma feature", "Activities")
                subtitle: i18nc("@info Caption for Activities button. Note that 'Separate' is being used as an imperative verb here, not a noun.", "Separate work, school, or home tasks")
                buttonIcon: "preferences-desktop-activities"
                onClicked: pageStack.layers.push(activitiesView);
            }
            PlasmaFeatureButton {
                id: kdeconnect
                Layout.fillWidth: true
                Layout.maximumWidth: grid.cellWidth
                Layout.preferredHeight: grid.cellHeight
                title: i18nc("@title:row Name of the 'KDE Connect' feature", "KDE Connect")
                subtitle: i18nc("@info Caption for KDE Connect button", "Connect your phone and your computer")
                buttonIcon: "kdeconnect"
                onClicked: pageStack.layers.push(kdeconnectView);
            }

            // Second row
            PlasmaFeatureButton {
                id: krunner
                Layout.fillWidth: true
                Layout.maximumWidth: grid.cellWidth
                Layout.preferredHeight: grid.cellHeight
                title: i18nc("@title:row", "KRunner")
                subtitle: i18nc("@info Caption for KRunner button", "Search for anything")
                buttonIcon: "krunner"
                onClicked: pageStack.layers.push(krunnerView);
            }
            PlasmaFeatureButton {
                id: overview
                Layout.fillWidth: true
                Layout.maximumWidth: grid.cellWidth
                Layout.preferredHeight: grid.cellHeight
                title: i18nc("@title:row Name of the 'Overview' KWin effect", "Overview")
                subtitle: i18nc("@info Caption for Overview button", "Your system command center")
                buttonIcon: "kwin"
                onClicked: pageStack.layers.push(overviewView);
            }
            PlasmaFeatureButton {
                id: gns
                Layout.fillWidth: true
                Layout.maximumWidth: grid.cellWidth
                Layout.preferredHeight: grid.cellHeight
                title: i18nc("@title:row", "Get New Stuff")
                subtitle: i18nc("@info Caption for Get New Stuff button", "Extend the system with add-ons")
                buttonIcon: "get-hot-new-stuff"
                onClicked: pageStack.layers.push(gnsView);
            }
        }

        Kirigami.UrlButton {
            text: i18nc("@action:button", "Learn about more Plasma features")
            url: "https://userbase.kde.org/Plasma?source=plasma-welcome"
        }
    }

    Component {
        id: vaultsView

        GenericPage {
            heading: i18nc("@info:window", "Plasma Vaults")
            description: xi18nc("@info:usagetip", "Plasma Vaults allows you to create encrypted folders, called <interface>Vaults.</interface> Inside each Vault, you can securely store your passwords, files, pictures, and documents, safe from prying eyes. Vaults can live inside folders that are synced to cloud storage services too, providing extra privacy for that content.<nl/><nl/>To get started, click the arrow on the <interface>System Tray</interface> to show hidden items, and then click the <interface>Vaults</interface> icon.")
        }
    }

    Component {
        id: activitiesView

        GenericPage {
            heading: i18nc("@info:window", "Activities")
            description: xi18nc("@info:usagetip", "Activities can be used to separate high-level projects or workflows so you can focus on one at a time. You can have an activity for \"Home\", \"School\", \"Work\", and so on. Each Activity has access to all your files but has its own set of open apps and windows, recent documents, \"Favorite\" apps, and desktop widgets.<nl/><nl/>To get started, launch <interface>System Settings</interface> and search for \"Activities\". On that page, you can create more Activities. You can then switch between them using the <shortcut>Meta+Tab</shortcut> keyboard shortcut.")

            actions: [
                Kirigami.Action {
                    icon.name: "preferences-desktop-activities"
                    text: i18nc("@action:button", "Open Settings…")
                    onTriggered: KCMUtils.KCMLauncher.openSystemSettings("kcm_activities")
                }
            ]
        }
    }

    Component {
        id: kdeconnectView

        GenericPage {
            heading: i18nc("@info:window", "KDE Connect")

            // Don't change the weird indentation; it's intentional to make this
            // long string nicer for translators
            description: xi18nc("@info:usagetip", "KDE Connect lets you integrate your phone with your computer in various ways:\
<nl/>\
<list><item>See notifications from your phone on your computer</item>\
<item>Reply to text messages from your phone on your computer</item>\
<item>Sync your clipboard contents between your computer and your phone</item>\
<item>Make a noise on your phone when it's been misplaced</item>\
<item>Copy pictures, videos, and other files from your phone to your computer, and vice versa</item>\
<item>…And much more!</item></list>\
<nl/>To get started, launch <interface>System Settings</interface> and search for \"KDE Connect\". On that page, you can pair your phone.")

            // TODO: KDE Connect might not be installed:
            // We should show an InlineMessage and hide the action.

            actions: [
                Kirigami.Action {
                    icon.name: "kdeconnect"
                    text: i18nc("@action:button", "Open Settings…")
                    onTriggered: KCMUtils.KCMLauncher.openSystemSettings("kcm_kdeconnect")
                }
            ]
        }
    }

    Component {
        id: krunnerView

        GenericPage {
            heading: i18nc("@info:window", "KRunner")

            // Don't change the weird indentation; it's intentional to make this
            // long string nicer for translators
            description: xi18nc("@info:usagetip translators: In the example queries, make sure to use the keywords as they are localized in the actual runner plugins. If needed, change 'Shanghai' to a city that on the other side of the world from likely speakers of the language", "KRunner is Plasma's exceptionally powerful and versatile search system. It powers the search functionality in the Application Launcher menu and the Overview screen, and it can be accessed as a standalone search bar using the <shortcut>Alt+Space</shortcut> keyboard shortcut.<nl/><nl/>In addition to finding your files and folders, KRunner can launch apps, search the web, convert between currencies, calculate math problems, and a lot more. Try typing any of the following into one of those search fields:\
<nl/>\
<list><item>\"time Shanghai\"</item>\
<item>\"27/3\"</item>\
<item>\"200 EUR in USD\"</item>\
<item>\"25 miles in km\"</item>\
<item>…And much more!</item></list>\
<nl/>\
To learn more, open the KRunner search bar using the <shortcut>Alt+Space</shortcut> keyboard shortcut and click on the question mark icon.")
        }
    }

    Component {
        id: overviewView

        GenericPage {
            heading: i18nc("@info:window The name of a KWin effect", "Overview")
            description: xi18nc("@info:usagetip", "Overview is a full-screen overlay that shows all of your open windows, letting you easily access any of them. It also shows your current Virtual Desktops, allowing you to add more, remove some, and switch between them. Finally, it offers a KRunner-powered search field that can also filter through open windows.<nl/><nl/>You can access Overview using the <shortcut>Meta+W</shortcut> keyboard shortcut.")
        }
    }

    Component {
        id: gnsView

        GenericPage {
            heading: i18nc("@info:window", "Get New Stuff")
            description: xi18nc("@info:usagetip", "Throughout Plasma, System Settings, and KDE apps, you'll find buttons marked \"Get New <emphasis>thing</emphasis>…\". Clicking on them will show you 3rd-party content to extend the system, made by other people like you! In this way, it is often possible to add functionality you want without having to ask KDE developers to implement it themselves.<nl/><nl/>Note that content acquired this way has not been reviewed by your distributor for functionality or stability.")

            actions: [
                Kirigami.Action {
                    icon.name: "get-hot-new-stuff"
                    text: i18nc("@action:button", "See 3rd-Party Content…")
                    onTriggered: Controller.launchApp("org.kde.knewstuff-dialog6")
                }
            ]
        }
    }
}
