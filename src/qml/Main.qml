/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtNetwork

import org.kde.config as KConfig
import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Kirigami.ApplicationWindow {
    id: app

    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 30
    width: Kirigami.Units.gridUnit * 36
    height: Kirigami.Units.gridUnit * 32

    KConfig.WindowStateSaver {
        configGroupName: "MainWindow"
    }

    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.NoNavigationButtons
    pageStack.defaultColumnWidth: width

    // Navigation

    readonly property bool inLayer: pageStack.layers.depth > 1
    readonly property bool atStart: pageStack.currentIndex === 0
    readonly property bool atEnd: pageStack.currentIndex === pageStack.depth - 1

    readonly property Kirigami.Action backAction: Kirigami.Action {
        readonly property bool isSkip: app.atStart && !app.inLayer

        text: isSkip ? i18nc("@action:button", "&Skip") : i18nc("@action:button", "&Back")
        icon.name: {
            if (isSkip) {
                return "dialog-cancel-symbolic";
            } else {
                return Qt.application.layoutDirection === Qt.LeftToRight ? "go-previous-symbolic" : "go-previous-rtl-symbolic";
            }
        }
        shortcut: Qt.application.layoutDirection === Qt.LeftToRight ? "Left" : "Right"
        onTriggered: app.navigateBack(true)
    }

    readonly property Kirigami.Action forwardAction: Kirigami.Action {
        readonly property bool isFinish: app.atEnd && !app.inLayer

        text: isFinish ? i18nc("@action:button", "&Finish") : i18nc("@action:button", "&Next")
        icon.name: {
            if (isFinish) {
                return "dialog-ok-apply-symbolic";
            } else {
                return Qt.application.layoutDirection === Qt.LeftToRight ? "go-next-symbolic" : "go-next-rtl-symbolic";
            }
        }
        shortcut: Qt.application.layoutDirection === Qt.LeftToRight ? "Right" : "Left"
        onTriggered: app.navigateForward(true)
    }

    function navigateBack(canQuit = false) {
        if (app.inLayer) {
            if (pageStack.layers.currentItem.overrideBack ?? false) {
                pageStack.layers.currentItem.back();
            } else {
                pageStack.layers.pop();
            }
        } else if (pageStack.currentItem.overrideBack ?? false) {
            pageStack.currentItem.back();
        } else if (app.atStart && canQuit) {
            Qt.quit();
        } else if (!app.atStart) {
            pageStack.currentIndex -= 1;
        }
    }

    function navigateForward(canQuit = false) {
        if (app.inLayer) {
            if (pageStack.layers.currentItem.overrideForward ?? false) {
                pageStack.layers.currentItem.forward();
            } else {
                pageStack.layers.pop();
            }
        } else if (pageStack.currentItem.overrideForward ?? false) {
            pageStack.currentItem.forward();
        } else if (app.atEnd && canQuit) {
            Qt.quit();
        } else if (!app.atEnd) {
            pageStack.currentIndex += 1;
        }
    }

    footer: Footer {
        width: app.width
        contentSource: {
            switch (Private.App.mode) {
                case Private.App.Welcome:
                case Private.App.Live:
                default:
                    return "FooterDefault.qml";
                case Private.App.Update:
                case Private.App.Beta:
                    return "FooterUpdate.qml";
            }
        }

        // app's MouseArea doesn't cover the footer
        MouseArea {
            anchors.fill: parent

            acceptedButtons: mouseNavHandler.acceptedButtons
            onPressed: (mouse) => mouseNavHandler.handlePressed(mouse.button)
        }
    }

    // Handle mouse back/forward buttons
    MouseArea {
        id: mouseNavHandler
        anchors.fill: parent

        cursorShape: undefined // Fix LinkButton's cursor shape being overriden
        acceptedButtons: Qt.BackButton | Qt.ForwardButton
        onPressed: (mouse) => handlePressed(mouse.button)

        function handlePressed(button) {
            if (button === Qt.BackButton) {
                app.navigateBack();
            } else if (button === Qt.ForwardButton) {
                app.navigateForward();
            }
        }
    }

    // Page management

    function _createPage(page, isDistroPage = false) {
        let component = Qt.createComponent(page);
        if (component.status !== Component.Error) {
            return component.createObject(null);
        } else {
            let error = component.errorString();
            console.warn("Couldn't load page '" + page + "'");
            console.warn("  " + error);
            component.destroy();

            return _createErrorPage(error, isDistroPage);
        }
    }

    function _createErrorPage(error, isDistroPage = false, isUnknownPage = false) {
        let errorComponent = Qt.createComponent("PageError.qml");
        if (errorComponent.Status !== Component.Error) {
            return errorComponent.createObject(null, {
                error: error,
                isDistroPage: isDistroPage,
                isUnknownPage: isUnknownPage
            });
        } else {
            errorComponent.destroy();
            return null;
        }
    }

    function _pushPage(component) {
        if (component !== null) {
            if (pageStack.currentIndex === -1) {
                pageStack.push(component);
            } else {
                // Insert to avoid changing the current page
                pageStack.insertPage(pageStack.depth, component);
            }
        }
    }

    Component.onCompleted: {
        // Push pages dynamically
        switch (Private.App.mode) {
            case Private.App.Update:
                _pushPage(_createPage("PlasmaUpdate.qml"));

                break;

            case Private.App.Live:
                _pushPage(_createPage("Live.qml"));
                // Fallthrough

            case Private.App.Welcome:
                _pushPage(_createPage("Welcome.qml"));

                if (NetworkInformation.reachability !== NetworkInformation.Reachability.Online || Private.Release.isDevelopment) {
                    _pushPage(_createPage("Network.qml"));
                }

                _pushPage(_createPage("SimpleByDefault.qml"));
                _pushPage(_createPage("PowerfulWhenNeeded.qml"));

                let discover = _createPage("Discover.qml");
                if (discover.application?.exists ?? false) {
                    _pushPage(discover);
                } else {
                    discover.destroy();
                }

                // KCMs
                if (Private.App.mode !== Private.App.Live) {
                    if (Private.App.userFeedbackAvailable) {
                        _pushPage(_createPage("Feedback.qml"));
                    }
                }

                // Append any distro-specific pages that were found
                for (let i in Private.App.distroPages) {
                    _pushPage(_createPage(Private.App.distroPages[i], true));
                }

                _pushPage(_createPage("Enjoy.qml"));

                break;

            case Private.App.Pages:
                Private.App.pages.forEach(page => {
                    var error = "";
                    var warnStrings = "";

                    let tryPage = function(page) {
                        let component = Qt.createComponent(page);
                        if (component.status !== Component.Error) {
                            _pushPage(component.createObject(null));
                            return true;
                        } else {
                            error += component.errorString();
                            warnStrings += ((warnStrings.length > 0) ? "\n" : "")
                                            + "Couldn't load page '" + page + "'" + "\n" + "  " + component.errorString();
                            component.destroy();
                            return false;
                        }
                    }

                    // Try as both a regular page and distro page
                    if (!tryPage(page) && !tryPage("file://" + Private.App.distroPagesDir + page)) {
                        console.warn(warnStrings);
                        _pushPage(_createErrorPage(error, false, true));
                    }
                });

                break;
        }
    }
}
