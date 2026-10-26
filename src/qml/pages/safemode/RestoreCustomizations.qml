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

    Connections {
        target: root.backupRestore
        enabled: root.visible

        function onAvailableRestoreSourcesChanged() {
            // Explicitly uncheck backup categories without source files.
            root.backupRestore.selectedRestoreCategories &= root.backupRestore.availableRestoreSources;
        }
    }

    function initPage() {
        root.backupRestore.selectedRestoreCategories &= root.backupRestore.availableRestoreSources;
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
                        enabled: root.backupRestore.successfulRestoreCategories === 0
                        text: i18nc("@action:button change backup folder for user customizations", "&Change…")
                        onClicked: { backupDirDialog.open(); }
                    }
                }
            }

            Kirigami.FormGroup {
                Layout.fillWidth: true

                Repeater {
                    model: [
                        {
                            checkboxTitle: i18nc("@title:row", "Restore KDE Plasma configuration"),
                            successTitle: i18nc("@title:row", "KDE Plasma configuration was restored"),
                            checkboxSubtitle: i18nc("@info possible contents of Plasma-related XDG config files, for reset, backup, and restore",
                                                    "System settings, desktop & applet settings."),
                            category: Private.SafeModeBackupRestore.Categories.PlasmaConfig,
                        },
                        {
                            checkboxTitle: i18nc("@title:row", "Restore app & miscellaneous configuration"),
                            successTitle: i18nc("@title:row", "App & miscellaneous configuration was restored"),
                            checkboxSubtitle: i18nc("@info possible contents of non-Plasma XDG config files, for reset, backup, and restore",
                                                    "Settings for all other software apart from KDE Plasma."), // TODO: Select which other settings to back up and reset.
                            category: Private.SafeModeBackupRestore.Categories.NonPlasmaConfig,
                        },
                        {
                            checkboxTitle: i18nc("@title:row", "Restore state"),
                            successTitle: i18nc("@title:row", "State was restored"),
                            checkboxSubtitle: i18nc("@info possible contents of XDG state folder, for reset, backup, and restore",
                                                    "Recent file history, restored window sizes, power draw history, …"),
                            category: Private.SafeModeBackupRestore.Categories.State,
                        },
                        {
                            checkboxTitle: i18nc("@title:row", "Restore desktop & application data"),
                            successTitle: i18nc("@title:row", "Desktop & application data was restored"),
                            checkboxSubtitle: i18nc("@info possible contents of XDG data folder, for reset, backup, and restore",
                                                    "Favorites, downloaded extensions, application sessions, custom menu entries, …"),
                            category: Private.SafeModeBackupRestore.Categories.Data,
                        }
                    ]
                    delegate: Kirigami.FormEntry {
                        id: delegate

                        required property string checkboxTitle
                        required property string successTitle
                        required property string checkboxSubtitle
                        required property int category

                        readonly property bool available: (root.backupRestore.availableRestoreSources & delegate.category) !== 0
                        readonly property bool successfulCompletion: (root.backupRestore.successfulRestoreCategories & delegate.category) !== 0

                        subtitle: (available || successfulCompletion) ? checkboxSubtitle : i18nc("@info can't back up files that don't exist", "Not present in your backup.")

                        contentItem: QQC2.CheckBox {
                            text: successfulCompletion ? delegate.successTitle : delegate.checkboxTitle
                            enabled: available && !successfulCompletion
                            checked: (enabled && (root.backupRestore.selectedRestoreCategories & delegate.category) !== 0) || successfulCompletion
                            onToggled: {
                                root.backupRestore.selectedRestoreCategories = checked
                                    ? (root.backupRestore.selectedRestoreCategories | delegate.category)
                                    : (root.backupRestore.selectedRestoreCategories & (root.backupRestore.selectedRestoreCategories ^ delegate.category));
                            }
                        }
                    }
                }
            }
        }

        QQC2.Button {
            Layout.alignment: Qt.AlignHCenter
            enabled: (root.backupRestore.availableRestoreSources & root.backupRestore.selectedRestoreCategories) !== 0
                     && root.backupRestore.preExistingRestoreTargetPaths.length === 0
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
            root.backupRestore.resetSuccessfulRestoreCategories();
        }
    }

    footer: ColumnLayout {
        Kirigami.InlineMessage {
            visible: root.backupRestore.preExistingRestoreTargetPaths.length > 0
            Layout.fillWidth: true
            text: i18ncp("@info",
                         "The following restore destination already exists: <ul>%2</ul> Move or delete your customization files to make room for the backed-up version.",
                         "The following restore destination already exist: <ul>%2</ul> Move or delete your customization files to make room for the backed-up version.",
                         root.backupRestore.preExistingRestoreTargetPaths.length,
                         root.backupRestore.preExistingRestoreTargetPaths.map((url) => "<li>" + new URL(url).pathname + "</li>").join()
            )
            position: Kirigami.InlineMessage.Position.Footer
            type: Kirigami.MessageType.Warning
        }

        Kirigami.InlineMessage {
            visible: root.backupRestore.successfulRestoreCategories !== 0 && !root.backupRestore.hasUserLogError
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
