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

    property bool showFooter: true

    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 32
    width: Kirigami.Units.gridUnit * 36
    height: Kirigami.Units.gridUnit * 32

    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.NoNavigationButtons
    pageStack.defaultColumnWidth: width

    footer: Item {
        width: root.width
        height: footerLayout.implicitHeight + (footerLayout.anchors.margins * 2)

        visible: root.showFooter

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
                    enabled: pageStack.layers.depth === 1
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

    function createPage(page) {
        let component = Qt.createComponent(page);
        if (component.status !== Component.Error) {
            return component.createObject(null);
        } else {
            console.warn("Couldn't load page '" + page + "'");
            console.warn(" " + component.errorString())
            component.destroy();
            // TODO: Instead create and return a placeholder page with error info
            return null;
        }
    }

    function pushPage(page) {
        if (page !== null) {
            if (pageStack.currentIndex === -1) {
                pageStack.push(page);
            } else {
                pageStack.insertPage(pageStack.depth, page);
            }
        }
    }

    Component.onCompleted: {
        // Push pages dynamically
        switch (Controller.mode) {
            case Controller.Update:
            case Controller.Beta:
                pushPage(createPage("PlasmaUpdate.qml"));

                root.showFooter = false;
                break;

            case Controller.Live:
                pushPage(createPage("Live.qml"));
                // Fallthrough

            case Controller.Welcome:
                pushPage(createPage("Welcome.qml"));

                if (!Controller.networkAlreadyConnected() || Controller.patchVersion === 80) {
                    pushPage(createPage("Network.qml"));
                }

                pushPage(createPage("SimpleByDefault.qml"));
                pushPage(createPage("PowerfulWhenNeeded.qml"));

                let discover = createPage("Discover.qml");
                if (discover.application.exists) {
                    pushPage(discover);
                } else {
                    discover.destroy();
                }

                // KCMs
                if (Controller.mode !== Controller.Live) {
                    if (Controller.userFeedbackAvailable()) {
                        pushPage(createPage("Feedback.qml"));
                    }
                }

                // Append any distro-specific pages that were found
                let distroPages = Controller.distroPages();
                for (let i in distroPages) {
                    pushPage(createPage(distroPages[i]));
                }

                pushPage(createPage("Contribute.qml"));
                pushPage(createPage("Donate.qml"));

                root.showFooter = true;
                break;
        }
    }
}
