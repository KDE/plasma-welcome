/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome

Kirigami.ApplicationWindow {
    id: root

    readonly property bool showingPlasmaUpdate: Controller.mode === Controller.Update

    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 32
    width: Kirigami.Units.gridUnit * 36
    height: Kirigami.Units.gridUnit * 32

    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.NoNavigationButtons
    pageStack.defaultColumnWidth: width

    footer: Item {
        width: root.width
        height: footerLayout.implicitHeight + (footerLayout.anchors.margins * 2)

        visible: !root.showingPlasmaUpdate

        Kirigami.Separator {
            id: footerSeparator

            anchors.bottom: parent.top
            width: parent.width
        }

        // Not using QQC2.Toolbar so that the window is draggable
        // from the footer, both appear identical
        Kirigami.AbstractApplicationHeader {
            id: footerToolbar

            height: parent.height
            width: parent.width

            separatorVisible: false

            contentItem: RowLayout {
                id: footerLayout

                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing

                spacing: Kirigami.Units.smallSpacing

                QQC2.Button {
                    Layout.alignment: Qt.AlignLeft
                    id: prevButton
                    enabled: footerToolbar.visible
                    action: Kirigami.Action {
                        text: pageStack.currentIndex === 0 && pageStack.layers.depth === 1 ? i18nc("@action:button", "&Skip") : i18nc("@action:button", "&Back")
                        icon.name: pageStack.currentIndex === 0 && pageStack.layers.depth === 1 ? "dialog-cancel" : "arrow-left"
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

                QQC2.PageIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    count: pageStack.depth
                    currentIndex: pageStack.currentIndex
                    interactive: true
                    onCurrentIndexChanged: { pageStack.currentIndex = currentIndex; }
                }

                QQC2.Button {
                    Layout.alignment: Qt.AlignRight
                    id: nextButton
                    enabled: footerToolbar.visible && pageStack.layers.depth === 1
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
    }

    Component.onCompleted: {
        switch (Controller.mode) {
            case Controller.Update:
                pageStack.push(plasmaUpdate);
                break;

            case Controller.Live:
                pageStack.push(live);
                // Fallthrough

            case Controller.Welcome:
                pageStack.push(welcome);

                if (!Controller.networkAlreadyConnected()) {
                    pageStack.push(network);
                }

                pageStack.push(simpleByDefault);
                pageStack.push(powerfulWhenNeeded);

                if (discover.application.exists) {
                    pageStack.push(discover);
                }

                if (Controller.mode !== Controller.Live) {
                    if (Controller.userFeedbackAvailable()) {
                        pageStack.push(kcm_feedback);
                    }

                    if (Controller.accountsAvailable()) {
                        pageStack.push(kcm_kaccounts);
                    }
                }

                // Append any distro-specific pages that were found
                let distroPages = Controller.distroPages();
                if (distroPages.length > 0) {
                    for (let i in distroPages) {
                        var distroPageComponent = Qt.createComponent(distroPages[i]);
                        if (distroPageComponent.status !== Component.Error) {
                            pageStack.push(distroPageComponent);
                        } else {
                            console.warn("Error loading Page", distroPages[i], distroPageComponent.status);
                            Qt.exit(123);
                        }
                    }
                }

                pageStack.push(contribute);
                pageStack.push(donate);
                pageStack.currentIndex = 0;
                break;
        }
    }

    Live {id: live; visible: false}
    Welcome {id: welcome; visible: false}
    Network {id: network; visible: false}
    SimpleByDefault {id: simpleByDefault; visible: false}
    PowerfulWhenNeeded {id: powerfulWhenNeeded; visible: false}
    Discover {id: discover; visible: false}
    KCM {
        id: kcm_feedback
        visible: false

        heading: i18nc("@title: window", "Share Anonymous Usage Information")
        description: i18nc("@info:usagetip", "Our developers will use this anonymous data to improve KDE software. You can choose how much to share in System Settings, and here too.")

        path: "kcm_feedback"
    }
    KCM {
        id: kcm_kaccounts
        visible: false

        heading: i18nc("@title: window", "Connect Online Accounts")
        description: i18nc("@info:usagetip", "This will let you access their content in KDE apps. You can set it up in System Settings, and here too.")

        path: "kcm_kaccounts"
    }
    Contribute {id: contribute; visible: false}
    Donate {id: donate; visible: false}

    PlasmaUpdate {id: plasmaUpdate; visible: false}
}
