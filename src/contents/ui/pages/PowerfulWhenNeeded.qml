/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15

import org.kde.plasma.welcome 1.0
import org.kde.welcome 1.0


GenericPage {
    heading: i18nc("@info:window", "Powerful When Needed")
    description: xi18nc("@info:usagetip", "Plasma is an extremely feature-rich environment, designed to super-charge your productivity! Here is just a smattering of the things it can do for you:")

    ColumnLayout {
        id: layout

        anchors {
            top: parent.top
            topMargin: Kirigami.Units.largeSpacing
            left: parent.left
            right: parent.right
        }
        spacing: Kirigami.Units.largeSpacing * 6

        GridLayout {
            id: grid

            readonly property int cellWidth: Math.round((layout.width - columnSpacing * (columns - 1)) / columns)
            readonly property int cellHeight: Math.max(vaults.implicitHeight,
                                                       activities.implicitHeight,
                                                       kdeconnect.implicitHeight,
                                                       overview.implicitHeight,
                                                       krunner.implicitHeight,
                                                       ghns.implicitHeight)

            Layout.fillWidth: true

            columns: 3
            columnSpacing: Kirigami.Units.smallSpacing
            rowSpacing: Kirigami.Units.smallSpacing

            // First row
            PlasmaFeatureButton {
                id: vaults
                Layout.preferredWidth: grid.cellWidth
                Layout.preferredHeight: grid.cellHeight
                title: i18nc("@title:row Short form of the 'Vaults' Plasma feature", "Vaults")
                subtitle: i18nc("@info Caption for Plasma Vaults button", "Store sensitive files securely")
                buttonIcon: "plasmavault"
                onClicked: pageStack.layers.push(vaultsView);
            }
            PlasmaFeatureButton {
                id: activities
                Layout.preferredWidth: grid.cellWidth
                Layout.preferredHeight: grid.cellHeight
                title: i18nc("@title:row Name of the 'Activities' Plasma feature", "Activities")
                subtitle: i18nc("@info Caption for Activities button. Note that 'Separate' is being used as an imperative verb here, not a noun.", "Separate work, school, or home tasks")
                buttonIcon: "preferences-desktop-activities"
                onClicked: pageStack.layers.push(activitiesView);
            }
            PlasmaFeatureButton {
                id: kdeconnect
                Layout.preferredWidth: grid.cellWidth
                Layout.preferredHeight: grid.cellHeight
                title: i18nc("@title:row Name of the 'KDE Connect' feature", "KDE Connect")
                subtitle: i18nc("@info Caption for KDE Connect button", "Connect your phone and your computer")
                buttonIcon: "kdeconnect"
                onClicked: pageStack.layers.push(kdeconnectView);
            }

            // Second row
            PlasmaFeatureButton {
                id: krunner
                Layout.preferredWidth: grid.cellWidth
                Layout.preferredHeight: grid.cellHeight
                title: i18nc("@title:row", "KRunner")
                subtitle: i18nc("@info Caption for KRunner button", "Search for anything")
                buttonIcon: "krunner"
                onClicked: pageStack.layers.push(krunnerView);
            }
            PlasmaFeatureButton {
                id: overview
                Layout.preferredWidth: grid.cellWidth
                Layout.preferredHeight: grid.cellHeight
                title: i18nc("@title:row Name of the 'Overview' KWin effect", "Overview")
                subtitle: i18nc("@info Caption for Overview button", "Your system command center")
                buttonIcon: "kwin"
                onClicked: pageStack.layers.push(overviewView);
            }
            PlasmaFeatureButton {
                id: ghns
                Layout.preferredWidth: grid.cellWidth
                Layout.preferredHeight: grid.cellHeight
                title: i18nc("@title:row", "Get Hot New Stuff")
                subtitle: i18nc("@info Caption for Get Hot New Stuff button", "Extend the system with add-ons")
                buttonIcon: "get-hot-new-stuff"
                onClicked: pageStack.layers.push(ghnsView);
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
            globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None

            heading: i18nc("@info:window", "Plasma Vaults")
            description: xi18nc("@info:usagetip", "Plasma Vaults allows you to create encrypted folders, called <interface>Vaults.</interface> Inside each Vault, you can securely store your passwords, files, pictures, and documents, safe from prying eyes. Vaults can live inside folders that are synced to cloud storage services too, providing extra privacy for that content.<nl/><nl/>To get started, click the arrow on the <interface>System Tray</interface> to show hidden items, and then click the <interface>Vaults</interface> icon.")

            QQC2.Button {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.gridUnit * 3
                anchors.horizontalCenter: parent.horizontalCenter

                icon.name: "go-previous-view"
                text: i18nc("@action:button", "See More Features")
                onClicked: pageStack.layers.pop();
            }
        }
    }

    Component {
        id: activitiesView

        GenericPage {
            globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None

            heading: i18nc("@info:window", "Activities")
            description: xi18nc("@info:usagetip", "Activities can be used to separate high-level projects or workflows so you can focus on one at a time. You can have an activity for \"Home\", \"School\", \"Work\", and so on. Each Activity has access to all your files but has its own set of open apps and windows, recent documents, \"Favorite\" apps, and desktop widgets.<nl/><nl/>To get started, launch <interface>System Settings</interface> and search for \"Activities\". On that page, you can create more Activities. You can then switch between them using the <shortcut>Meta+Tab</shortcut> keyboard shortcut.")

            RowLayout {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.gridUnit * 3
                anchors.horizontalCenter: parent.horizontalCenter

                spacing: Kirigami.Units.largeSpacing

                QQC2.Button {
                    icon.name: "go-previous-view"
                    text: i18nc("@action:button", "See More Features")
                    onClicked: pageStack.layers.pop();
                }
                QQC2.Button {
                    icon.name: "preferences-desktop-activities"
                    text: i18nc("@action:button", "Open Activities Page in System Settings")
                    onClicked: Controller.launchApp("kcm_activities");
                }
            }
        }
    }

    Component {
        id: kdeconnectView

        GenericPage {
            globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None

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

            RowLayout {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.gridUnit * 3
                anchors.horizontalCenter: parent.horizontalCenter

                spacing: Kirigami.Units.largeSpacing

                QQC2.Button {
                    icon.name: "go-previous-view"
                    text: i18nc("@action:button", "See More Features")
                    onClicked: pageStack.layers.pop();
                }
                QQC2.Button {
                    icon.name: "kdeconnect"
                    text: i18nc("@action:button", "Open KDE Connect Page in System Settings")
                    onClicked: Controller.launchApp("kcm_kdeconnect");
                }
            }
        }
    }

    Component {
        id: krunnerView

        GenericPage {
            globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None

            heading: i18nc("@info:window", "KRunner")

            // Don't change the weird indentation; it's intentional to make this
            // long string nicer for translators
            description: xi18nc("@info:usagetip translators: if needed, change 'Shanghai' to a city that on the other side of the world from likely speakers of the language", "KRunner is Plasma's exceptionally powerful and versatile search system. It powers the search functionality in the Application Launcher menu and the Overview screen, and it can be accessed as a standalone search bar using the <shortcut>Alt+F2</shortcut> keyboard shortcut.<nl/><nl/>In addition to finding your files and folders, KRunner can launch apps, search the web, convert between currencies, calculate math problems, and a lot more. Try typing any of the following into one of those search fields:\
<nl/>\
<list><item>\"time Shanghai\"</item>\
<item>\"27/3\"</item>\
<item>\"200 EUR in USD\"</item>\
<item>\"25 miles in km\"</item>\
<item>…And much more!</item></list>\
<nl/>\
To learn more, open the KRunner search bar using the <shortcut>Alt+F2</shortcut> keyboard shortcut and click on the question mark icon.")

            QQC2.Button {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.gridUnit * 3
                anchors.horizontalCenter: parent.horizontalCenter

                icon.name: "go-previous-view"
                text: i18nc("@action:button", "See More Features")
                onClicked: pageStack.layers.pop();
            }
        }
    }

    Component {
        id: overviewView

        GenericPage {
            globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None

            heading: i18nc("@info:window The name of a KWin effect", "Overview")
            description: xi18nc("@info:usagetip", "Overview is a full-screen overlay that shows all of your open windows, letting you easily access any of them. It also shows your current Virtual Desktops, allowing you to add more, remove some, and switch between them. Finally, it offers a KRunner-powered search field that can also filter through open windows.<nl/><nl/>You can access Overview using the <shortcut>Meta+W</shortcut> keyboard shortcut.")

            QQC2.Button {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.gridUnit * 3
                anchors.horizontalCenter: parent.horizontalCenter

                icon.name: "go-previous-view"
                text: i18nc("@action:button", "See More Features")
                onClicked: pageStack.layers.pop();
            }
        }
    }

    Component {
        id: ghnsView

        GenericPage {
            globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None

            heading: i18nc("@info:window", "Get Hot New Stuff")
            description: xi18nc("@info:usagetip", "Throughout Plasma, System Settings, and KDE apps, you'll find buttons marked \"Get New [thing]…\". Clicking on them will show you 3rd-party content to extend the system, made by other people like you! In this way, it is often possible to add functionality you want without having to ask KDE developers to implement it themselves.<nl/><nl/>Note that content acquired this way has not been reviewed by your distributor for functionality or stability.")

            RowLayout {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.gridUnit * 3
                anchors.horizontalCenter: parent.horizontalCenter

                spacing: Kirigami.Units.largeSpacing

                QQC2.Button {
                    icon.name: "go-previous-view"
                    text: i18nc("@action:button", "See More Features")
                    onClicked: pageStack.layers.pop();
                }
                QQC2.Button {
                    icon.name: "get-hot-new-stuff"
                    text: i18nc("@action:button", "See All Available 3rd-Party Content")
                    onClicked: Controller.runCommand("knewstuff-dialog", "org.kde.knewstuff-dialog");
                }
            }
        }
    }
}
