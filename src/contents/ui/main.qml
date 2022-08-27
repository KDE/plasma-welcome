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

import org.kde.welcome 1.0

Kirigami.ApplicationWindow {
    id: root

    property var initialPages: [welcome, discover, systemsettings, kcm_kaccounts, kcm_feedback, contribute];

    minimumWidth: Kirigami.Units.gridUnit * 40
    minimumHeight: Kirigami.Units.gridUnit * 35
    width: Kirigami.Units.gridUnit * 40
    height: Kirigami.Units.gridUnit * 35

    // We're using a slightly complicated custom implementation of
    // Kirigami.AbstractApplicationHeader here because QQC2.ToolBar isn't draggable
    // to move the window (Bug 452180), and using the built-in pageStack's header
    // doesn't give us adequate control over the presentation; we very specifically
    // want raised buttons, arbitrary content in the center, page text inline, etc.
    header: Kirigami.AbstractApplicationHeader {
        id: header
        width: page.width
        height: headerLayout.implicitHeight + (headerLayout.anchors.margins * 2)
        contentItem: Item {
            width: header.width
            height: header.height
            RowLayout {
                id: headerLayout

                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing

                QQC2.Button {
                    Layout.alignment: Qt.AlignLeft
                    action: Kirigami.Action {
                        text: pageStack.currentIndex === 0 ? i18nc("@action:button", "Skip") : i18nc("@action:button", "Back")
                        icon.name: pageStack.currentIndex === 0 ? "dialog-cancel" : "arrow-left"
                        shortcut: "Left"
                        onTriggered: {
                            if (pageStack.layers.depth > 1) {
                                pageStack.layers.pop()
                            } else if (pageStack.currentIndex != 0) {
                                pageStack.currentIndex -= 1
                            } else {
                                Config.skip = true;
                                Config.save();
                                Controller.removeFromAutostart();
                                Qt.quit();
                            }
                        }
                    }
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: i18ncp("@info", "Page %1 of %2", "Page %1 of %2", pageStack.currentIndex + 1, initialPages.length + 1)
                }

                QQC2.Button {
                    visible: pageStack.layers.depth === 1
                    Layout.alignment: Qt.AlignRight
                    action: Kirigami.Action {
                        text: pageStack.currentIndex === pageStack.depth - 1 ? i18nc("@action:button", "Finish") : i18nc("@action:button", "Next")
                        icon.name: pageStack.currentIndex === pageStack.depth - 1 ? "dialog-ok-apply" : "arrow-right"
                        shortcut: "Right"
                        onTriggered: {
                            if (pageStack.currentIndex < pageStack.depth - 1) {
                                pageStack.currentIndex += 1
                            } else {
                                Config.done = true;
                                Config.save();
                                Controller.removeFromAutostart();
                                Qt.quit()
                            }
                        }
                    }
                }
            }
            Kirigami.Separator {
                anchors.bottom: parent.bottom
                width: parent.width
            }
        }
    }

    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.None
    pageStack.defaultColumnWidth: width

    // TODO: push new pages only as needed
    Component.onCompleted: {
        if (!Controller.networkAlreadyConnected()) {
            network.visible = true;
            initialPages = [welcome, network, discover, systemsettings, kcm_kaccounts, kcm_feedback, contribute];
        }

        pageStack.initialPage = initialPages;
        pageStack.currentIndex = 0;
    }

    Welcome {id: welcome}
    Network {id: network; visible: false}
    Discover {id: discover}
    SystemSettings {id:systemsettings}
    Contribute {id: contribute}
    KCM {
        id: kcm_feedback

        heading: i18nc("@title: window", "Sharing Usage Information with KDE")
        description: i18nc("@info:usagetip", "In System Settings, you can choose to share anonymous usage information with KDE. You can make that choice here, too.")

        Module {
            id: moduleFeedback
            path: "kcm_feedback"
        }
        kcm: moduleFeedback.kcm
        internalPage: moduleFeedback.kcm.mainUi
    }
    KCM {
        id: kcm_kaccounts

        heading: i18nc("@title: window", "Connecting your Online Accounts")
        description: i18nc("@info:usagetip", "In System Settings, you can connect to your online accounts and access their content in KDE apps. You can set it up right now, too.")
        showSeparator: true

        Module {
            id: moduleAccounts
            path: "kcm_kaccounts"
        }
        kcm: moduleAccounts.kcm
        internalPage: moduleAccounts.kcm.mainUi
    }
}
