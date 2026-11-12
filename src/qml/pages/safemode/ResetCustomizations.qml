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

    title: i18nc("@title", "Reset Customizations and Restore Defaults")

    function initPage() {
        root.backupRestore.resetSuccessfulBackupCategories();
    }
    onVisibleChanged: visible && initPage()
    Component.onCompleted: initPage()

    ColumnLayout {
        width: root.availableWidth
        spacing: Kirigami.Units.largeSpacing * 2

        QQC2.Label {
            Layout.fillWidth: true
            text: i18nc("@info:usagetip", "To fix a broken KDE Plasma session that used to work, you can try to reset customizations of your user account to restore system defaults.")
            wrapMode: Text.Wrap
        }

        Kirigami.Form {
            Layout.alignment: Qt.AlignTop | Qt.AlignVCenter
            Layout.fillWidth: true

            Kirigami.FormGroup {
                Layout.fillWidth: true

                Kirigami.FormEntry {
                    subtitle: i18nc("@info:usagetip backup destination",
                                    "Your customizations will be moved to this folder.")
                    fullWidth: true

                    contentItem: QQC2.Label {
                        Layout.fillWidth: true
                        text: root.hasBackupDir
                              ? xi18nc("@label", "Backup destination: <filename>%1</filename>", new URL(root.backupRestore.backupDir).pathname)
                              : i18nc("@label", "No backup destination selected.")
                        wrapMode: Text.WordWrap
                    }
                    trailingItems: QQC2.Button {
                        icon.name: "document-open-folder-symbolic"
                        enabled: !root.backupRestore.isOperating
                                 && !root.backupRestore.backupCategories.hasSuccessfulCategories
                        text: i18nc("@action:button change backup folder for user customizations", "&Change…")
                        onClicked: { backupDirDialog.open(); }
                    }
                }
            }

            Kirigami.FormGroup {
                Layout.fillWidth: true

                Repeater {
                    model: root.backupRestore.backupCategories

                    delegate: Kirigami.FormEntry {
                        id: delegate

                        required property int categoryGroup
                        required property string title
                        required property string successTitle
                        required property string description
                        required property bool isAvailable
                        required property int selectionState
                        required property bool wasSuccessful

                        subtitle: (isAvailable || wasSuccessful) ? description : i18nc("@info can't back up files that don't exist", "Not present in your user account.")

                        contentItem: QQC2.CheckBox {
                            text: delegate.wasSuccessful ? delegate.successTitle : delegate.title
                            enabled: delegate.isAvailable && !delegate.wasSuccessful && !root.backupRestore.isOperating
                            tristate: true
                            checkState: delegate.wasSuccessful ? Qt.Checked : delegate.selectionState
                            nextCheckState: () => checkState == Qt.Checked ? Qt.Unchecked : Qt.Checked
                            onToggled: {
                                root.backupRestore.backupCategories.setGroupSelected(delegate.categoryGroup, checkState);
                            }
                        }
                    }
                }
            }
        }

        QQC2.Button {
            Layout.alignment: Qt.AlignHCenter
            enabled: root.hasBackupDir
                     && !root.backupRestore.isOperating
                     && root.backupRestore.backupCategories.hasSelectedCategories
                     && root.backupRestore.backupCategories.conflictingPaths.length === 0
            icon.name: "edit-reset"
            text: xi18nc("@action:button", "Back Up and &Reset Customizations")

            onClicked: root.backupRestore.moveCustomizationsToBackupDir()
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
            visible: root.backupRestore.backupCategories.conflictingPaths.length > 0
            Layout.fillWidth: true
            text: i18ncp("@info",
                         "The following backup destination already exists: <ul>%2</ul> Select a different backup destination or delete your previously backed-up files to continue.",
                         "The following backup destinations already exist: <ul>%2</ul> Select a different backup destination or delete your previously backed-up files to continue.",
                         root.backupRestore.backupCategories.conflictingPaths.length,
                         root.backupRestore.backupCategories.conflictingPaths.map((url) => "<li>" + new URL(url).pathname + "</li>").join()
            )
            position: Kirigami.InlineMessage.Position.Footer
            type: Kirigami.MessageType.Warning
            actions: Kirigami.Action {
                text: xi18nc("@action:button", "Check &Again")
                icon.name: "view-refresh-symbolic"
                enabled: !root.backupRestore.isOperating
                onTriggered: root.backupRestore.updateAvailableCategories()
            }
        }

        Kirigami.InlineMessage {
            visible: root.backupRestore.backupCategories.hasSuccessfulCategories && !root.backupRestore.hasUserLogError
            Layout.fillWidth: true
            text: i18nc("@info", "User customizations were successfully backed up.")
            actions: [
                Kirigami.Action {
                    icon.name: "document-open-folder-symbolic"
                    text: i18nc("@action:button", "Open Backup &Folder")
                    onTriggered: root.backupRestore.openBackupDirWithHighlightedUserLog()
                },
                Kirigami.Action {
                    icon.name: "document-open-symbolic"
                    text: i18nc("@action:button", "Open Backup &Log")
                    onTriggered: root.backupRestore.openUserLog()
                },
                Kirigami.Action {
                    icon.name: Qt.application.layoutDirection === Qt.RightToLeft ? "system-log-out-rtl-symbolic" : "system-log-out-symbolic"
                    text: i18nc("@action:button", "E&xit Safe Mode…")
                    onTriggered: Private.SafeMode.requestLogoutPrompt()
                }
            ]
            position: Kirigami.InlineMessage.Position.Footer
            type: Kirigami.MessageType.Positive
        }

        Kirigami.InlineMessage {
            visible: root.backupRestore.hasUserLogError
            Layout.fillWidth: true
            text: i18nc("@info", "There were errors while backing up user customizations.")
            actions: Kirigami.Action {
                icon.name: "document-open-folder-symbolic"
                text: i18nc("@action:button", "Open Backup &Log")
                onTriggered: root.backupRestore.openUserLog()
            }
            position: Kirigami.InlineMessage.Position.Footer
            type: Kirigami.MessageType.Error
        }
    }
}
