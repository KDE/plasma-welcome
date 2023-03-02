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
import org.kde.plasma.welcome 1.0

Kirigami.ApplicationWindow {
    id: root

    readonly property bool showingPlasmaUpdate: Controller.newPlasmaVersion.length > 0

    minimumWidth: Kirigami.Units.gridUnit * 36
    minimumHeight: Kirigami.Units.gridUnit * 32
    width: minimumWidth
    height: minimumHeight

    // We're using a slightly complicated custom implementation of
    // Kirigami.AbstractApplicationHeader here because QQC2.ToolBar isn't draggable
    // to move the window (Bug 452180), and using the built-in pageStack's header
    // doesn't give us adequate control over the presentation; we very specifically
    // want raised buttons, arbitrary content in the center, page text inline, etc.
    header: Item {
        width: root.width
        height: root.showingPlasmaUpdate ? separator.height: headerLayout.implicitHeight + (headerLayout.anchors.margins * 2)

        Kirigami.AbstractApplicationHeader {
            id: headerToolbar

            anchors.top: parent.top
            anchors.bottom: separator.top
            width: parent.width
            visible: !root.showingPlasmaUpdate

            contentItem: RowLayout {
                id: headerLayout

                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing

                spacing: Kirigami.Units.smallSpacing

                QQC2.Button {
                    id: prevButton
                    enabled: headerToolbar.visible
                    action: Kirigami.Action {
                        text: pageStack.currentIndex === 0 ? i18nc("@action:button", "&Skip") : i18nc("@action:button", "&Back")
                        icon.name: pageStack.currentIndex === 0 ? "dialog-cancel" : "arrow-left"
                        shortcut: "Left"
                        enabled: prevButton.enabled
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
                    text: i18ncp("@info", "Page %1 of %2", "Page %1 of %2", pageStack.currentIndex + 1, pageStack.depth)
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight // Should never elide, but set it anyway
                }

                QQC2.Button {
                    id: nextButton
                    enabled: headerToolbar.visible && pageStack.layers.depth === 1
                    action: Kirigami.Action {
                        text: pageStack.currentIndex === pageStack.depth - 1 ? i18nc("@action:button", "&Finish") : i18nc("@action:button", "&Next")
                        icon.name: pageStack.currentIndex === pageStack.depth - 1 ? "dialog-ok-apply" : "arrow-right"
                        shortcut: "Right"
                        enabled: nextButton.enabled
                        onTriggered: {
                            if (pageStack.currentIndex < pageStack.depth - 1) {
                                pageStack.currentIndex += 1
                            } else {
                                Qt.quit();
                            }
                        }
                    }
                }
            }
        }
        Kirigami.Separator {
            id: separator

            visible: !headerToolbar.visible
            anchors.bottom: parent.bottom
            width: parent.width
        }
    }

    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.None
    pageStack.defaultColumnWidth: width

    Component.onCompleted: {
        if (root.showingPlasmaUpdate) {
            pageStack.push(plasmaUpdate);
        } else {
            pageStack.push(welcome);

            if (!Controller.networkAlreadyConnected()) {
                pageStack.push(network);
            }

            pageStack.push(simpleByDefault);
            pageStack.push(powerfulWhenNeeded);
            pageStack.push(discover);

            if (Controller.userFeedbackAvailable()) {
                pageStack.push(kcm_feedback);
            }

            pageStack.push(kcm_kaccounts);

            // Append any distro-specific pages that were found
            let distroPages = Controller.distroPages()
            if (distroPages.length > 0) {
                for (let i in distroPages) {
                    var distroPageComponent = Qt.createComponent(distroPages[i]);
                    if (distroPageComponent.status !== Component.Error) {
                        pageStack.push(distroPageComponent);
                    } else {
                        console.warn("Error loading Page", distroPages[i], distroPageComponent.status)
                        Qt.exit(123)
                    }
                }
            }

            pageStack.push(contribute);
            pageStack.push(donate);
            pageStack.currentIndex = 0;
        }
    }

    PlasmaUpdate {id: plasmaUpdate; visible: false}

    Welcome {id: welcome; visible: false}
    Network {id: network; visible: false}
    SimpleByDefault {id: simpleByDefault; visible: false}
    PowerfulWhenNeeded {id: powerfulWhenNeeded; visible: false}
    Discover {id: discover; visible: false}
    KCM {
        id: kcm_feedback

        visible: false

        heading: i18nc("@title: window", "Share Anonymous Usage Information With KDE")
        description: i18nc("@info:usagetip", "Our developers will use this anonymous data to improve KDE software. You can choose how much to share in System Settings, and here too.")

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

        heading: i18nc("@title: window", "Connect Your Online Accounts")
        description: i18nc("@info:usagetip", "This will let you access their content in KDE apps. You can set it up in System Settings, and here too.")
        showSeparator: true

        Module {
            id: moduleAccounts
            path: "kcm_kaccounts"
        }
        kcm: moduleAccounts.kcm
        internalPage: moduleAccounts.kcm.mainUi
    }
    Contribute {id: contribute; visible: false}
    Donate {id: donate; visible: false}
}
