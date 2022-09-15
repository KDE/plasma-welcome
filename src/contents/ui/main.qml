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

    property var initialPages
    readonly property bool headerToolbarVisible: initialPages.length > 1

    minimumWidth: Kirigami.Units.gridUnit * 40
    minimumHeight: Kirigami.Units.gridUnit * 35
    width: Kirigami.Units.gridUnit * 40
    height: Kirigami.Units.gridUnit * 35

    // We're using a slightly complicated custom implementation of
    // Kirigami.AbstractApplicationHeader here because QQC2.ToolBar isn't draggable
    // to move the window (Bug 452180), and using the built-in pageStack's header
    // doesn't give us adequate control over the presentation; we very specifically
    // want raised buttons, arbitrary content in the center, page text inline, etc.
    header: ColumnLayout {
        width: root.width
        spacing: 0
        height: root.headerToolbarVisible ? headerLayout.implicitHeight + (headerLayout.anchors.margins * 2) : 0
        Kirigami.AbstractApplicationHeader {
            id: headerToolbar
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.headerToolbarVisible
            contentItem: Item {
                width: headerToolbar.width
                height: headerToolbar.height
                RowLayout {
                    id: headerLayout

                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing

                    QQC2.Button {
                        action: Kirigami.Action {
                            text: pageStack.currentIndex === 0 ? i18nc("@action:button", "&Skip") : i18nc("@action:button", "&Back")
                            icon.name: pageStack.currentIndex === 0 ? "dialog-cancel" : "arrow-left"
                            shortcut: "Left"
                            onTriggered: {
                                if (pageStack.layers.depth > 1) {
                                    pageStack.layers.pop()
                                } else if (pageStack.currentIndex != 0) {
                                    pageStack.currentIndex -= 1
                                } else {
                                    Qt.quit();
                                }
                            }
                        }
                    }

                    QQC2.Label {
                        Layout.fillWidth: true
                        text: i18ncp("@info", "Page %1 of %2", "Page %1 of %2", pageStack.currentIndex + 1, initialPages.length + 1)
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight // Should never elide, but set it anyway
                    }

                    QQC2.Button {
                        enabled: pageStack.layers.depth === 1
                        action: Kirigami.Action {
                            text: pageStack.currentIndex === pageStack.depth - 1 ? i18nc("@action:button", "&Finish") : i18nc("@action:button", "&Next")
                            icon.name: pageStack.currentIndex === pageStack.depth - 1 ? "dialog-ok-apply" : "arrow-right"
                            shortcut: "Right"
                            onTriggered: {
                                if (pageStack.currentIndex < pageStack.depth - 1) {
                                    pageStack.currentIndex += 1
                                } else {
                                    Qt.quit()
                                }
                            }
                        }
                    }
                }
            }
        }
        Kirigami.Separator {
            visible: !root.headerToolbarVisible
            Layout.fillWidth: true
        }
    }

    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.None
    pageStack.defaultColumnWidth: width

    // FIXME: push new pages only as needed
    // See https://bugs.kde.org/show_bug.cgi?id=459177
    Component.onCompleted: {
        if (Controller.newPlasmaVersion.length > 0) {
            initialPages = [plasmaUpdate];
        } else {
            welcome.visible = true;
            discover.visible = true;
            systemsettings.visible = true;
            contribute.visible = true;
            donate.visible = true;
            kcm_feedback.visible = true;
            kcm_kaccounts.visible = true;

            if (!Controller.networkAlreadyConnected()) {
                network.visible = true;
                initialPages = [welcome, network, discover, systemsettings, kcm_kaccounts, kcm_feedback, contribute, donate];
            } else {
                initialPages = [welcome, discover, systemsettings, kcm_kaccounts, kcm_feedback, contribute, donate];
            }
        }

        pageStack.initialPage = initialPages;
        pageStack.currentIndex = 0;
    }

    PlasmaUpdate {id: plasmaUpdate; visible: false}

    Welcome {id: welcome; visible: false}
    Network {id: network; visible: false}
    Discover {id: discover; visible: false}
    SystemSettings {id: systemsettings; visible: false}
    Contribute {id: contribute; visible: false}
    Donate {id: donate; visible: false}

    KCM {
        id: kcm_feedback

        visible: false

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

        visible: false

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
