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

    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 32
    width: Kirigami.Units.gridUnit * 36
    height: Kirigami.Units.gridUnit * 32

    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.NoNavigationButtons
    pageStack.defaultColumnWidth: width

    footer: Footer {
        width: root.width
        contentSource: {
            switch (Controller.mode) {
                case Controller.Welcome:
                case Controller.Live:
                default:
                    return "FooterDefault.qml";
                case Controller.Update:
                case Controller.Beta:
                    return "FooterUpdate.qml";
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

                break;
        }
    }
}
