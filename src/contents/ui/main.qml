/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.welcome 1.0

Kirigami.ApplicationWindow {
    id: root

    readonly property bool showingPlasmaUpdate: Controller.mode !== Controller.Welcome

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

    Kirigami.PromptDialog {
        id: distroPageErrorDialog

        property list<string> errors: []
        property alias showDetails: showDetailsAction.checked

        title: "Error"
        standardButtons: Kirigami.Dialog.NoButton
        customFooterActions: [
            Kirigami.Action {
                id: showDetailsAction
                text: i18nc("@action:button", "Show Details")
                checkable: true
            },
            Kirigami.Action {
                text: i18n("OK")
                icon.name: "dialog-ok"
                onTriggered: distroPageErrorDialog.accept()
            }
        ]

        ColumnLayout {
            spacing: Kirigami.Units.largeSpacing

            ColumnLayout {
                spacing: Kirigami.Units.smallSpacing

                QQC2.Label {
                    Layout.fillWidth: true
                    text: i18n("One or more pages provided by your distribution failed to load.")
                    wrapMode: Text.Wrap
                }

                Kirigami.UrlButton {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                    text: i18nc("@action:button", "Please report this to your distributor.")
                    url: Controller.distroBugReportUrl()
                    wrapMode: Text.Wrap
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                visible: distroPageErrorDialog.showDetails
            }

            Repeater {
                id: errorRepeater
                model: distroPageErrorDialog.errors
                delegate: Kirigami.SelectableLabel {
                    Layout.fillWidth: true
                    text: modelData
                    font.family: "monospace"
                    wrapMode: Text.Wrap
                    visible: distroPageErrorDialog.showDetails
                }
            }
        }

        function openIfError() {
            if (errors.length > 0) {
                open();
            }
        }
    }

    Component.onCompleted: {
        switch (Controller.mode) {
            case Controller.Update:
                pageStack.push(plasmaUpdate);
                break;

            case Controller.Welcome:
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
                let distroPages = Controller.distroPages();
                if (distroPages.length > 0) {
                    for (let i in distroPages) {
                        var distroPageComponent = Qt.createComponent(distroPages[i]);
                        if (distroPageComponent.status !== Component.Error) {
                            pageStack.push(distroPageComponent);
                        } else {
                            console.warn("Error loading distro page",
                                         "\n     " + distroPageComponent.errorString(),
                                         "    Please notify your distributor.");
                            distroPageErrorDialog.errors.push(distroPageComponent.errorString().replace(/(\n)/gm, ""));
                        }
                    }
                    distroPageErrorDialog.openIfError();
                }

                pageStack.push(contribute);
                pageStack.push(donate);
                pageStack.currentIndex = 0;
                break;
        }
    }

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
        showSeparator: true

        path: "kcm_kaccounts"
    }
    Contribute {id: contribute; visible: false}
    Donate {id: donate; visible: false}

    PlasmaUpdate {id: plasmaUpdate; visible: false}
}
