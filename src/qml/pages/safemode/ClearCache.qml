/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome.private as Private

Kirigami.ScrollablePage {
    id: root

    title: i18nc("@title", "Clear Cache Files")

    property Private.SafeModeCacheClearer cacheClearer: Private.SafeMode.cacheClearer

    onVisibleChanged: visible && root.cacheClearer.resetCompletion()
    Component.onCompleted: root.cacheClearer.resetCompletion()

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing * 2

        QQC2.Label {
            Layout.fillWidth: true
            text: xi18nc("@info:usagetip", "KDE Plasma, system services, and applications create cache files to help with performance. Sometimes these go stale, and can cause problems.<nl/><nl/>Often the problem lies elsewhere, but clearing the caches doesn't hurt to try, as they will be automatically regenerated when needed.<nl/><nl/>Your customizations will remain untouched.")
            wrapMode: Text.Wrap
        }

        QQC2.Button {
            id: clearCacheButton
            Layout.alignment: Qt.AlignHCenter
            text: i18nc("@action:button", "&Clear Cache Files")
            icon.name: "edit-clear-all"
            enabled: root.cacheClearer.cacheDirExists
            onClicked: root.cacheClearer.clearCache()
        }
    }

    footer: ColumnLayout {
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: !root.cacheClearer.cacheDirExists && root.cacheClearer.completion === Private.SafeModeCacheClearer.Completion.NotStarted
            text: {
                const url = new URL(root.cacheClearer.cacheDir);
                return url.pathname.length > 0
                    ? xi18nc("@info", "No cache directory was found at <filename>%1</filename>. Cache files do not need to be cleared.", url.pathname)
                    : i18nc("@info", "The session environment does not specify a cache directory to clear."); // should not happen in regular use
            }
            actions: Kirigami.Action {
                text: i18nc("@action:button", "&Back")
                icon.name: Qt.application.layoutDirection === Qt.LeftToRight ? "go-previous-symbolic" : "go-previous-rtl-symbolic"
                onTriggered: pageStack.goBack()
            }
            position: Kirigami.InlineMessage.Position.Footer
            type: Kirigami.MessageType.Information
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: !root.cacheClearer.cacheDirExists && root.cacheClearer.completion === Private.SafeModeCacheClearer.Completion.Success
            text: xi18nc("@info", "Cache files have been cleared:<nl/><filename>%1</filename> was deleted.", new URL(root.cacheClearer.cacheDir).pathname)
            actions: Kirigami.Action {
                icon.name: Qt.application.layoutDirection === Qt.RightToLeft ? "system-log-out-rtl-symbolic" : "system-log-out-symbolic"
                text: i18nc("@action:button", "E&xit Safe Mode…")
                onTriggered: Private.SafeMode.requestLogoutPrompt()
            }
            position: Kirigami.InlineMessage.Position.Footer
            type: Kirigami.MessageType.Positive
        }

        Kirigami.InlineMessage {
            id: errorMessage
            Layout.fillWidth: true
            visible: root.cacheClearer.completion == Private.SafeModeCacheClearer.Completion.Error
            text: {
                const url = new URL(root.cacheClearer.cacheDir);
                return xi18nc("@info", "Failed to clear the cache at <filename>%1</filename>:<nl/><message>%2</message>", url.pathname, root.cacheClearer.errorString);
            }
            actions: [
                Kirigami.Action {
                    visible: root.cacheClearer.cacheDirExists
                    text: i18nc("@action:button", "&Open Cache Folder")
                    icon.name: "document-open-folder-symbolic"
                    onTriggered: root.cacheClearer.openCacheDir()
                },
                Kirigami.Action {
                    text: i18nc("@action:button", "&Retry")
                    icon: clearCacheButton.icon
                    visible: clearCacheButton.enabled
                    onTriggered: clearCacheButton.click()
                }
            ]
            position: Kirigami.InlineMessage.Position.Footer
            type: Kirigami.MessageType.Error
        }
    }
}
