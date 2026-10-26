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

    title: i18nc("@title", "Reset Customizations and Restore Defaults")

    Connections {
        target: root.backupRestore
        enabled: root.visible

        function onAvailableBackupSourcesChanged() {
            // Explicitly uncheck backup categories without source files.
            root.backupRestore.selectedBackupCategories &= root.backupRestore.availableBackupSources;
        }
    }

    function initPage() {
        root.backupRestore.selectedBackupCategories &= root.backupRestore.availableBackupSources;
        root.backupRestore.resetSuccessfulBackupCategories();
    }
    onVisibleChanged: visible && initPage()
    Component.onCompleted: initPage()

    ColumnLayout {
        width: root.availableWidth
        spacing: Kirigami.Units.largeSpacing * 2

        QQC2.Label {
            Layout.fillWidth: true
            // unused text (i18nc): "Some problems can surface with an uncommon combination of settings or third-party extensions, sometimes only on certain hardware.<nl/><nl/>"
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
                        text: xi18nc("@label", "Backup destination: <filename>%1</filename>", new URL(root.backupRestore.backupDir).pathname)
                        wrapMode: Text.WordWrap
                    }
                    trailingItems: QQC2.Button {
                        icon.name: "document-open-folder-symbolic"
                        enabled: root.backupRestore.successfulBackupCategories === 0
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
                            checkboxTitle: i18nc("@title:row", "Reset KDE Plasma configuration"),
                            successTitle: i18nc("@title:row", "KDE Plasma configuration was backed up"),
                            checkboxSubtitle: i18nc("@info possible contents of Plasma-related XDG config files, for reset, backup, and restore",
                                                    "System settings, desktop & applet settings."),
                            category: Private.SafeModeBackupRestore.Categories.PlasmaConfig,
                        },
                        {
                            checkboxTitle: i18nc("@title:row", "Reset app & miscellaneous configuration"),
                            successTitle: i18nc("@title:row", "App & miscellaneous configuration was backed up"),
                            checkboxSubtitle: i18nc("@info possible contents of non-Plasma XDG config files, for reset, backup, and restore",
                                                    "Settings for all other software apart from KDE Plasma."), // TODO: Select which other settings to back up and reset.
                            category: Private.SafeModeBackupRestore.Categories.NonPlasmaConfig,
                        },
                        {
                            checkboxTitle: i18nc("@title:row", "Reset state"),
                            successTitle: i18nc("@title:row", "State was backed up"),
                            checkboxSubtitle: i18nc("@info possible contents of XDG state folder, for reset, backup, and restore",
                                                    "Recent file history, restored window sizes, power draw history, …"),
                            category: Private.SafeModeBackupRestore.Categories.State,
                        },
                        {
                            checkboxTitle: i18nc("@title:row", "Reset desktop & application data"),
                            successTitle: i18nc("@title:row", "Desktop & application data was backed up"),
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

                        readonly property bool available: (root.backupRestore.availableBackupSources & delegate.category) !== 0
                        readonly property bool successfulCompletion: (root.backupRestore.successfulBackupCategories & delegate.category) !== 0

                        subtitle: (available || successfulCompletion) ? checkboxSubtitle : i18nc("@info can't back up files that don't exist", "Not present in your user account.")

                        contentItem: QQC2.CheckBox {
                            text: successfulCompletion ? delegate.successTitle : delegate.checkboxTitle
                            enabled: available && !successfulCompletion
                            checked: (enabled && (root.backupRestore.selectedBackupCategories & delegate.category) !== 0) || successfulCompletion
                            onToggled: {
                                root.backupRestore.selectedBackupCategories = checked
                                    ? (root.backupRestore.selectedBackupCategories | delegate.category)
                                    : (root.backupRestore.selectedBackupCategories & (root.backupRestore.selectedBackupCategories ^ delegate.category));
                            }
                        }
                    }
                }
            }
        }

        QQC2.Button {
            Layout.alignment: Qt.AlignHCenter
            enabled: (root.backupRestore.availableBackupSources & root.backupRestore.selectedBackupCategories) !== 0
                     && root.backupRestore.preExistingBackupTargetPaths.length === 0
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
            root.backupRestore.resetSuccessfulBackupCategories();
        }
    }

    footer: ColumnLayout {
        Kirigami.InlineMessage {
            visible: root.backupRestore.preExistingBackupTargetPaths.length > 0
            Layout.fillWidth: true
            text: i18ncp("@info",
                         "The following backup destination already exists: <ul>%2</ul> Select a different backup destination or delete your previously backed-up files to continue.",
                         "The following backup destinations already exist: <ul>%2</ul> Select a different backup destination or delete your previously backed-up files to continue.",
                         root.backupRestore.preExistingBackupTargetPaths.length,
                         root.backupRestore.preExistingBackupTargetPaths.map((url) => "<li>" + new URL(url).pathname + "</li>").join()
            )
            position: Kirigami.InlineMessage.Position.Footer
            type: Kirigami.MessageType.Warning
        }

        Kirigami.InlineMessage {
            visible: root.backupRestore.successfulBackupCategories !== 0 && !root.backupRestore.hasUserLogError
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
