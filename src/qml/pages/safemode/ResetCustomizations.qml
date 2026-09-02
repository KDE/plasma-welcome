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

    readonly property Private.SafeModeFixes safeMode: Private.App.safeModeFixes

    title: i18nc("@title", "Reset Customizations and Restore Defaults")

    Connections {
        target: root.safeMode

        function onAvailableBackupSourcesChanged() {
            // Explicitly uncheck backup categories without source files.
            root.safeMode.selectedBackupCategories &= root.safeMode.availableBackupSources;
        }
        Component.onCompleted: {
            // Initialize correctly after not having observed the signal earlier.
            onAvailableRestoreSourcesChanged();

            root.safeMode.resetSuccessfulBackupCategories();
        }
    }

    onIsCurrentPageChanged: root.safeMode.resetSuccessfulBackupCategories();

    ColumnLayout {
        width: root.availableWidth
        spacing: Kirigami.Units.largeSpacing * 2

        QQC2.Label {
            Layout.fillWidth: true
            // unused text (i18nc): "Some problems can surface with an uncommon combination of settings or third-party extensions, sometimes only on certain hardware.<nl/><nl/>"
            text: i18nc("@info:usagetip", "To fix a broken Plasma session that used to work, you can try to reset customizations of your user account to restore system defaults.")
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
                        text: xi18nc("@label", "Backup destination: <filename>%1</filename>", new URL(root.safeMode.backupDir).pathname)
                        wrapMode: Text.WordWrap
                    }
                    trailingItems: QQC2.Button {
                        icon.name: "document-open-folder-symbolic"
                        enabled: root.safeMode.successfulBackupCategories === 0
                        text: i18nc("@action:button change backup folder for user customizations", "Change…")
                        onClicked: { backupDirDialog.open(); }
                    }
                }
            }

            Kirigami.FormGroup {
                Layout.fillWidth: true

                Repeater {
                    model: [
                        {
                            checkboxTitle: i18nc("@title:row", "Reset configuration"),
                            successTitle: i18nc("@title:row", "Configuration was backed up"),
                            checkboxSubtitle: i18nc("@info possible contents of XDG config folder, for reset, backup, and restore",
                                                    "System settings, application settings, applet settings, …"),
                            backupCategory: Private.SafeModeFixes.BackupCategories.ConfigDir,
                        },
                        {
                            checkboxTitle: i18nc("@title:row", "Reset state"),
                            successTitle: i18nc("@title:row", "State was backed up"),
                            checkboxSubtitle: i18nc("@info possible contents of XDG state folder, for reset, backup, and restore",
                                                    "Recent file history, restored window sizes, power draw history, …"),
                            backupCategory: Private.SafeModeFixes.BackupCategories.StateDir,
                        },
                        {
                            checkboxTitle: i18nc("@title:row", "Reset desktop & application data"),
                            successTitle: i18nc("@title:row", "Desktop & application data was backed up"),
                            checkboxSubtitle: i18nc("@info possible contents of XDG data folder, for reset, backup, and restore",
                                                    "Favorites, downloaded extensions, application sessions, custom menu entries, …"),
                            backupCategory: Private.SafeModeFixes.BackupCategories.DataDir,
                        }
                    ]
                    delegate: Kirigami.FormEntry {
                        id: delegate

                        required property string checkboxTitle
                        required property string successTitle
                        required property string checkboxSubtitle
                        required property int backupCategory

                        readonly property bool available: (root.safeMode.availableBackupSources & delegate.backupCategory) !== 0
                        readonly property bool successfulCompletion: (root.safeMode.successfulBackupCategories & delegate.backupCategory) !== 0

                        subtitle: (available || successfulCompletion) ? checkboxSubtitle : i18nc("@info can't back up a folder that doesn't exist", "Not present in your user account.")

                        contentItem: QQC2.CheckBox {
                            text: successfulCompletion ? delegate.successTitle : delegate.checkboxTitle
                            enabled: available && !successfulCompletion
                            checked: (enabled && (root.safeMode.selectedBackupCategories & delegate.backupCategory) !== 0) || successfulCompletion
                            onToggled: {
                                root.safeMode.selectedBackupCategories = checked
                                    ? (root.safeMode.selectedBackupCategories | delegate.backupCategory)
                                    : (root.safeMode.selectedBackupCategories & (root.safeMode.selectedBackupCategories ^ delegate.backupCategory));
                            }
                        }
                    }
                }
            }
        }

        Kirigami.InlineMessage {
            visible: root.safeMode.preExistingBackupTargetDirs.length > 0
            Layout.fillWidth: true
            type: Kirigami.MessageType.Warning
            text: i18ncp("@info",
                         "The following backup folder already exists: <ul>%2</ul> Select a different backup destination or delete your previous backup folder to continue.",
                         "The following backup folders already exist: <ul>%2</ul> Select a different backup destination or delete your previous backup folders to continue.",
                         root.safeMode.preExistingBackupTargetDirs.length,
                         root.safeMode.preExistingBackupTargetDirs.map((url) => "<li>" + new URL(url).pathname + "</li>").join()
            )
        }

        QQC2.Button {
            Layout.alignment: Qt.AlignHCenter
            visible: root.safeMode.successfulBackupCategories === 0
            enabled: (root.safeMode.availableBackupSources & root.safeMode.selectedBackupCategories) !== 0
                     && root.safeMode.preExistingBackupTargetDirs.length === 0
            icon.name: "edit-reset"
            text: xi18nc("@action:button", "Back Up and Reset Customizations")

            onClicked: root.safeMode.moveCustomizationsToBackupDir()
        }

        Kirigami.InlineMessage {
            visible: root.safeMode.successfulBackupCategories !== 0
            Layout.fillWidth: true
            type: Kirigami.MessageType.Positive
            text: i18nc("@info", "User customizations were successfully backed up.")
            actions: [
                Kirigami.Action {
                    icon.name: "document-open-folder-symbolic"
                    text: i18n("Open Backup Folder")
                    onTriggered: root.safeMode.openBackupDir()
                }
            ]
        }
    }

    Dialogs.FolderDialog {
        id: backupDirDialog
        currentFolder: root.safeMode.backupDir
        onAccepted: {
            root.safeMode.backupDir = selectedFolder;
            root.safeMode.resetSuccessfulBackupCategories();
        }
    }
}
