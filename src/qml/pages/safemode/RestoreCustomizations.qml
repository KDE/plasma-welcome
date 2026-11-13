/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs as Dialogs

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome.private as Private

Kirigami.ScrollablePage {
    id: root

    readonly property Private.SafeModeBackupRestore backupRestore: Private.SafeMode.backupRestore
    readonly property bool hasBackupDir: root.backupRestore.backupDir.toString() !== ""

    title: i18nc("@title", "Restore Customizations")

    function initPage() {
        root.backupRestore.resetSuccessfulRestoreCategories();
    }
    onVisibleChanged: visible && initPage()
    Component.onCompleted: initPage()

    ColumnLayout {
        width: root.availableWidth
        spacing: Kirigami.Units.largeSpacing * 2

        QQC2.Label {
            Layout.fillWidth: true
            text: i18nc("@info:usagetip", "Restore files that you previously backed up through the \"Reset Customizations and Restore Defaults\" page.")
            wrapMode: Text.Wrap
        }

        Kirigami.Form {
            Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
            Layout.fillWidth: true

            Kirigami.FormGroup {
                Layout.fillWidth: true

                Kirigami.FormEntry {
                    subtitle: i18nc("@info:usagetip backup location",
                                    "Your customizations will be moved back from this folder.")
                    fullWidth: true

                    contentItem: QQC2.Label {
                        Layout.fillWidth: true
                        text: root.hasBackupDir
                              ? xi18nc("@label", "Backup location: <filename>%1</filename>", new URL(root.backupRestore.backupDir).pathname)
                              : i18nc("@label", "No backup location selected.")
                        wrapMode: Text.WordWrap
                    }
                    trailingItems: QQC2.Button {
                        icon.name: "document-open-folder-symbolic"
                        enabled: !root.backupRestore.restoreCategories.hasSuccessfulCategories
                        text: i18nc("@action:button change backup folder for user customizations", "&Change…")
                        onClicked: { backupDirDialog.open(); }
                    }
                }
            }
        }

        QQC2.Button {
            Layout.alignment: Qt.AlignHCenter
            enabled: root.hasBackupDir
                     && root.backupRestore.restoreCategories.hasAvailableCategories
                     && root.backupRestore.restoreCategories.conflictingPaths.length === 0
            icon.name: "edit-reset"
            text: xi18nc("@action:button", "&Restore Customizations")

            onClicked: root.backupRestore.restoreCustomizationsFromBackupDir()
        }
    }

    Dialogs.FolderDialog {
        id: backupDirDialog
        currentFolder: root.backupRestore.backupDir
        onAccepted: {
            root.backupRestore.backupDir = selectedFolder;
        }
    }

    footer: ColumnLayout {
        Kirigami.InlineMessage {
            visible: root.backupRestore.restoreCategories.conflictingPaths.length > 0
            Layout.fillWidth: true
            text: i18ncp("@info",
                         "The following restore destination already exists: <ul>%2</ul> Move or delete your customization files to make room for the backed-up version.",
                         "The following restore destinations already exist: <ul>%2</ul> Move or delete your customization files to make room for the backed-up version.",
                         root.backupRestore.restoreCategories.conflictingPaths.length,
                         root.backupRestore.restoreCategories.conflictingPaths.map((url) => "<li>" + new URL(url).pathname + "</li>").join()
            )
            position: Kirigami.InlineMessage.Position.Footer
            type: Kirigami.MessageType.Warning
            actions: Kirigami.Action {
                text: xi18nc("@action:button", "Check &Again")
                icon.name: "view-refresh-symbolic"
                onTriggered: root.backupRestore.updateAvailableCategories()
            }
        }

        Kirigami.InlineMessage {
            visible: root.backupRestore.restoreCategories.hasSuccessfulCategories
            Layout.fillWidth: true
            text: i18nc("@info", "User customizations were successfully restored.")
            actions: [
                Kirigami.Action {
                    icon.name: Qt.application.layoutDirection === Qt.RightToLeft ? "system-log-out-rtl-symbolic" : "system-log-out-symbolic"
                    text: i18nc("@action:button", "E&xit Safe Mode…")
                    onTriggered: Private.SafeMode.requestLogoutPrompt()
                }
            ]
            position: Kirigami.InlineMessage.Position.Footer
            type: Kirigami.MessageType.Positive
        }
    }
}
