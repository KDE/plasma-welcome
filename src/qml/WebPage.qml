/*
 *  SPDX-FileCopyrightText: 2026 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtWebEngine

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Kirigami.Page {
    id: page

    property alias url: webEngineView.url

    // This may be desirable if we know the page doesn't need it, as
    // it can appear during resize before WebEngineView catches up
    property bool disableHorizontalScrollBar: false

    function loadHtml(html: string, baseUrl: url): void {
        webEngineView.loadHtml(html, baseUrl);
    }

    padding: 0

    title: webEngineView.title

    actions: [
        Kirigami.Action {
            icon.name: "external-link-symbolic"
            text: i18nc("@action:button", "Open in Browser…")
            tooltip: webEngineView.url
            onTriggered: Qt.openUrlExternally(webEngineView.url)
        }
    ]

    Rectangle {
        id: webEngineViewContainer
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View

        anchors.fill: parent
        anchors.rightMargin: verticalScrollBar.visible ? verticalScrollBar.width : 0
        anchors.bottomMargin: horizontalScrollBar.visible ? horizontalScrollBar.height : 0

        color: Kirigami.Theme.backgroundColor
        clip: true

        // Wrapping with a Rectangle with a background and clipping helps
        // rendering issues during resize such as showing content behind
        // the window, and the web view intruding under the ScrollBar

        WebEngineView {
            id: webEngineView
            anchors.fill: parent

            backgroundColor: Kirigami.Theme.backgroundColor

            settings.showScrollBars: false

            profile: Private.WebProfile.instance()

            Component.onCompleted: {
                // Hide donorbox (we break it by rejecting WebEngineNavigationRequest.OtherNavigation below)
                let hideDonorBoxScript = WebEngine.script();
                hideDonorBoxScript.name = "hideDonorBox";
                hideDonorBoxScript.sourceCode = `
                    document.querySelectorAll("div.donnorbox-container, div.donnorbox-container-small").forEach(function(element) {
                        element.style.display = "none";
                    });
                `;
                hideDonorBoxScript.injectionPoint = WebEngineScript.DocumentReady;
                hideDonorBoxScript.worldId = WebEngineScript.MainWorld;

                webEngineView.userScripts.insert(hideDonorBoxScript);
            }

            onNavigationRequested: (request) => {
                switch (request.navigationType) {
                    case WebEngineNavigationRequest.TypedNavigation: // Setting initial URL
                    case WebEngineNavigationRequest.ReloadNavigation: // Should be allowed
                    case WebEngineNavigationRequest.RedirectNavigation: // Ditto
                        request.accept();
                        return;
                    case WebEngineNavigationRequest.FormSubmittedNavigation: // Shouldn't happen
                    case WebEngineNavigationRequest.BackForwardNavigation: // Ditto
                    case WebEngineNavigationRequest.OtherNavigation: // Embedded donorbox iframe
                    default:
                        request.reject();
                        return;
                    case WebEngineNavigationRequest.LinkClickedNavigation: // Don't allow and push external browser
                        request.reject();
                        navigateDialog.pendingUrl = request.url;
                        navigateDialog.open();
                        return;
                }
            }

            onNewWindowRequested: (request) => {
                navigateDialog.pendingUrl = request.requestedUrl;
                navigateDialog.open();
            }

            onContextMenuRequested: (request) => {
                request.accepted = true;
                if (!contextMenu.visible) {
                    contextMenu.handleRequest(request);
                }
            }

            onLinkHovered: (hoveredUrl) => {
                linkTooltip.hoveredUrl = hoveredUrl;
            }
        }

        Controls.Control {
            id: linkTooltip
            anchors.left: webEngineViewContainer.left
            anchors.bottom: webEngineViewContainer.bottom
            anchors.leftMargin: -background.border.width
            anchors.bottomMargin: -background.border.width

            property url hoveredUrl
            property string text

            onHoveredUrlChanged: {
                let hoveredUrlString = hoveredUrl.toString();
                if (hoveredUrlString.length !== 0) {
                    text = hoveredUrl;
                }
            }

            opacity: hoveredUrl.toString().length === 0 ? 0 : 1
            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }
            visible: opacity > 0

            width: Math.min(implicitWidth, webEngineViewContainer.width - Kirigami.Units.gridUnit)

            padding: Kirigami.Units.smallSpacing + background.border.width

            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                border.width: 1
                border.color: Kirigami.ColorUtils.linearInterpolation(
                    Kirigami.Theme.backgroundColor,
                    Kirigami.Theme.textColor,
                    Kirigami.Theme.frameContrast
                )
                topRightRadius: Kirigami.Units.cornerRadius
            }

            contentItem: Text {
                text: linkTooltip.text
                maximumLineCount: 1
                elide: Text.ElideMiddle
            }
        }
    }

    Controls.ScrollBar {
        id: verticalScrollBar
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: horizontalScrollBar.visible ? horizontalScrollBar.top : parent.bottom

        orientation: Qt.Vertical
        policy: Controls.ScrollBar.AsNeeded

        size: webEngineView.contentsSize.height > 0 ? (webEngineView.height / webEngineView.contentsSize.height) : 0
        position: !pressed && webEngineView.contentsSize.height > 0
                    ? (webEngineView.scrollPosition.y / webEngineView.contentsSize.height)
                    : position

        onPositionChanged: {
            if (pressed) {
                webEngineView.runJavaScript("window.scrollTo(" + webEngineView.scrollPosition.x + ", " + (position * webEngineView.contentsSize.height) + ");")
            }
        }
    }

    Controls.ScrollBar {
        id: horizontalScrollBar
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: verticalScrollBar.visible ? verticalScrollBar.left : parent.right

        orientation: Qt.Horizontal
        policy: page.disableHorizontalScrollBar ? Controls.ScrollBar.AlwaysOff : Controls.ScrollBar.AsNeeded

        size: webEngineView.contentsSize.width > 0 ? (webEngineView.width / webEngineView.contentsSize.width) : 0
        position: !pressed && webEngineView.contentsSize.width > 0
                    ? (webEngineView.scrollPosition.x / webEngineView.contentsSize.width)
                    : position

        onPositionChanged: {
            if (pressed) {
                webEngineView.runJavaScript("window.scrollTo(" + (position * webEngineView.contentsSize.width) + ", " + webEngineView.scrollPosition.y + ");")
            }
        }
    }

    Kirigami.PromptDialog {
        id: navigateDialog

        property url pendingUrl

        title: i18nc("@title:window", "Open Link in Browser?")
        subtitle: navigateDialog.pendingUrl

        standardButtons: Kirigami.Dialog.Open | Kirigami.Dialog.Cancel
        onAccepted: Qt.openUrlExternally(pendingUrl)

        property var openButton: null
        Component.onCompleted: { openButton = standardButton(Kirigami.Dialog.Open); }
        Binding {
            target: navigateDialog.openButton
            property: "icon.name"
            value: "external-link-symbolic"
        }
    }

    Controls.Menu {
        id: contextMenu

        readonly property var linkTypes: ({
            None: 0,
            Link: 1,
            Image: 2,
            Video: 3,
            Audio: 4,
        })

        property url linkUrl
        property int linkType

        function handleRequest(request) {

            function detectLink() {
                if (request.linkUrl.toString().length > 0) {
                    return { url: request.linkUrl, type: contextMenu.linkTypes.Link };
                }

                if (request.mediaUrl.toString().length > 0) {
                    switch (request.mediaType) {
                        case ContextMenuRequest.MediaTypeImage:
                            return { url: request.mediaUrl, type: contextMenu.linkTypes.Image };
                        case ContextMenuRequest.MediaTypeVideo:
                            return { url: request.mediaUrl, type: contextMenu.linkTypes.Video };
                        case ContextMenuRequest.MediaTypeAudio:
                            return { url: request.mediaUrl, type: contextMenu.linkTypes.Audio };
                    }
                }

                return { url: "", type: contextMenu.linkTypes.None };
            }

            const link = detectLink();
            const hasUrl = (link.type !== contextMenu.linkTypes.None);
            linkUrl = link.url;
            linkType = link.type;

            contextMenuOpenLink.visible = hasUrl;
            contextMenuCopyLink.visible = hasUrl;

            contextMenuUndo.visible = !hasUrl && (request.editFlags & ContextMenuRequest.CanUndo);
            contextMenuRedo.visible = !hasUrl && (request.editFlags & ContextMenuRequest.CanRedo);
            contextMenuCut.visible = !hasUrl && (request.editFlags & ContextMenuRequest.CanCut);
            contextMenuCopy.visible = !hasUrl && (request.editFlags & ContextMenuRequest.CanCopy);
            contextMenuPaste.visible = !hasUrl && (request.editFlags & ContextMenuRequest.CanPaste);
            contextMenuDelete.visible = !hasUrl && (request.editFlags & ContextMenuRequest.CanDelete);
            contextMenuSelectAll.visible = !hasUrl && (request.editFlags & ContextMenuRequest.CanSelectAll);

            contextMenuRefresh.visible = !hasUrl && !request.isContentEditable && (request.selectedText.length === 0);

            contextMenu.popup();
        }

        // Link actions

        Controls.MenuItem {
            id: contextMenuOpenLink
            action: Kirigami.Action {
                icon.name: "external-link-symbolic"
                text: {
                    switch (contextMenu.linkType) {
                        case contextMenu.linkTypes.None:
                        default:
                            return "";
                        case contextMenu.linkTypes.Link:
                            return i18n("Open Link in Browser…");
                        case contextMenu.linkTypes.Image:
                            return i18n("Open Image in Browser…");
                        case contextMenu.linkTypes.Video:
                            return i18n("Open Video in Browser…");
                        case contextMenu.linkTypes.Audio:
                            return i18n("Open Audio in Browser…");
                    }
                }
            }
            onTriggered: Qt.openUrlExternally(contextMenu.linkUrl)
        }

        Controls.MenuItem {
            id: contextMenuCopyLink
            action: Kirigami.Action {
                icon.name: "edit-copy-symbolic"
                text: {
                    switch (contextMenu.linkType) {
                        case contextMenu.linkTypes.None:
                        default:
                            return "";
                        case contextMenu.linkTypes.Link:
                            return i18n("Copy Link");
                        case contextMenu.linkTypes.Image:
                            return i18n("Copy Image Link");
                        case contextMenu.linkTypes.Video:
                            return i18n("Copy Video Link");
                        case contextMenu.linkTypes.Audio:
                            return i18n("Copy Audio Link");
                    }
                }
            }
            onTriggered: Welcome.Utils.copyToClipboard(contextMenu.linkUrl);
        }

        // Edit actions

        Controls.MenuItem {
            id: contextMenuUndo
            action: Kirigami.Action {
                icon.name: webEngineView.LayoutMirroring.enabled ? "edit-undo-rtl-symbolic" : "edit-undo-symbolic"
                text: i18n("Undo")
            }
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Undo)
        }

        Controls.MenuItem {
            id: contextMenuRedo
            action: Kirigami.Action {
                icon.name: webEngineView.LayoutMirroring.enabled ? "edit-redo-rtl-symbolic" : "edit-redo-symbolic"
                text: i18n("Redo")
            }
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Redo)
        }

        Controls.MenuSeparator {
            visible: (contextMenuUndo.visible || contextMenuRedo.visible)
                     && (contextMenuCut.visible || contextMenuCopy.visible ||
                         contextMenuPaste.visible || contextMenuDelete.visible ||
                         contextMenuSelectAll.visible)
        }

        Controls.MenuItem {
            id: contextMenuCut
            action: Kirigami.Action {
                icon.name: "edit-cut-symbolic"
                text: i18n("Cut")
            }
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Cut)
        }

        Controls.MenuItem {
            id: contextMenuCopy
            action: Kirigami.Action {
                icon.name: "edit-copy-symbolic"
                text: i18n("Copy")
            }
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Copy)
        }

        Controls.MenuItem {
            id: contextMenuPaste
            action: Kirigami.Action {
                icon.name: "edit-paste-symbolic"
                text: i18n("Paste")
            }
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Paste)
        }

        Controls.MenuItem {
            id: contextMenuDelete
            action: Kirigami.Action {
                icon.name: "edit-delete-symbolic"
                text: i18n("Delete")
            }
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Delete)
        }

        Controls.MenuItem {
            id: contextMenuSelectAll
            action: Kirigami.Action {
                icon.name: "edit-select-all-symbolic"
                text: i18n("Select All")
            }
            onTriggered: webEngineView.triggerWebAction(WebEngineView.SelectAll)
        }

        // Not editable, no selection actions

        Controls.MenuItem {
            id: contextMenuRefresh
            action: Kirigami.Action {
                icon.name: "view-refresh-symbolic"
                text: i18n("Refresh")
            }
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Reload)
        }
    }
}
