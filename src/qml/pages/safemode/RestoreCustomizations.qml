/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtCore // StandardPaths
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs as Dialogs

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Kirigami.ScrollablePage {
    id: root

    readonly property Private.SafeModeBackupRestore backupRestore: Private.SafeMode.backupRestore

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
                        text: xi18nc("@label", "Backup location: <filename>%1</filename>", new URL(root.backupRestore.backupDir).pathname)
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

            Kirigami.FormGroup {
                Layout.fillWidth: true

                Repeater {
                    model: root.backupRestore.restoreCategories

                    delegate: Kirigami.FormEntry {
                        id: delegate

                        required property int category
                        required property string categoryTitle
                        required property string categorySuccessTitle
                        required property string categoryDescription
                        required property bool isAvailable
                        required property bool isSelected
                        required property bool wasSuccessful

                        subtitle: (isAvailable || wasSuccessful) ? categoryDescription : i18nc("@info can't back up files that don't exist", "Not present in your backup.")

                        contentItem: QQC2.CheckBox {
                            text: delegate.wasSuccessful ? delegate.categorySuccessTitle : delegate.categoryTitle
                            enabled: delegate.isAvailable && !delegate.wasSuccessful
                            checked: delegate.wasSuccessful || (delegate.isAvailable && delegate.isSelected)
                            onToggled: {
                                root.backupRestore.restoreCategories.setSelected(delegate.category, checked);
                            }
                        }
                    }
                }
            }
        }

        QQC2.Button {
            Layout.alignment: Qt.AlignHCenter
            enabled: root.backupRestore.restoreCategories.hasSelectedCategories
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
                         "The following restore destination already exist: <ul>%2</ul> Move or delete your customization files to make room for the backed-up version.",
                         root.backupRestore.restoreCategories.conflictingPaths.length,
                         root.backupRestore.restoreCategories.conflictingPaths.map((url) => "<li>" + new URL(url).pathname + "</li>").join()
            )
            position: Kirigami.InlineMessage.Position.Footer
            type: Kirigami.MessageType.Warning
        }

        Kirigami.InlineMessage {
            visible: root.backupRestore.restoreCategories.hasSuccessfulCategories && !root.backupRestore.hasUserLogError
            Layout.fillWidth: true
            text: i18nc("@info", "User customizations were successfully restored.")
            actions: [
                Kirigami.Action {
                    icon.name: "document-open-symbolic"
                    text: i18nc("@action:button", "Open Restoration &Log")
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
            text: i18nc("@info", "There were errors while restoring user customizations.")
            actions: [
                Kirigami.Action {
                    icon.name: "document-open-folder-symbolic"
                    text: i18nc("@action:button", "Open Restoration &Log")
                    onTriggered: root.backupRestore.openUserLog()
                }
            ]
            position: Kirigami.InlineMessage.Position.Footer
            type: Kirigami.MessageType.Error
        }
    }
}
