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

    title: i18nc("@title", "Restore Customizations")

    Connections {
        target: root.safeMode

        function onAvailableRestoreSourcesChanged() {
            // Explicitly uncheck backup categories without source files.
            root.safeMode.selectedRestoreCategories &= root.safeMode.availableRestoreSources;
        }
        Component.onCompleted: {
            // Initialize correctly after not having observed the signal earlier.
            onAvailableRestoreSourcesChanged();

            root.safeMode.resetSuccessfulRestoreCategories();
        }
    }

    onIsCurrentPageChanged: root.safeMode.resetSuccessfulRestoreCategories();

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
                        text: xi18nc("@label", "Backup location: <filename>%1</filename>", new URL(root.safeMode.backupDir).pathname)
                        wrapMode: Text.WordWrap
                    }
                    trailingItems: QQC2.Button {
                        icon.name: "document-open-folder-symbolic"
                        enabled: root.safeMode.successfulRestoreCategories === 0
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
                            checkboxTitle: i18nc("@title:row", "Restore configuration"),
                            successTitle: i18nc("@title:row", "Configuration was restored"),
                            checkboxSubtitle: i18nc("@info possible contents of XDG config folder, for reset, backup, and restore",
                                                    "System settings, application settings, applet settings, …"),
                            backupCategory: Private.SafeModeFixes.BackupCategories.ConfigDir,
                        },
                        {
                            checkboxTitle: i18nc("@title:row", "Restore state"),
                            successTitle: i18nc("@title:row", "State was restored"),
                            checkboxSubtitle: i18nc("@info possible contents of XDG state folder, for reset, backup, and restore",
                                                    "Recent file history, restored window sizes, power draw history, …"),
                            backupCategory: Private.SafeModeFixes.BackupCategories.StateDir,
                        },
                        {
                            checkboxTitle: i18nc("@title:row", "Restore desktop & application data"),
                            successTitle: i18nc("@title:row", "Desktop & application data was restored"),
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

                        readonly property bool available: (root.safeMode.availableRestoreSources & delegate.backupCategory) !== 0
                        readonly property bool successfulCompletion: (root.safeMode.successfulRestoreCategories & delegate.backupCategory) !== 0

                        subtitle: (available || successfulCompletion) ? checkboxSubtitle : i18nc("@info can't back up a folder that doesn't exist", "Not present in your backup.")

                        contentItem: QQC2.CheckBox {
                            text: successfulCompletion ? delegate.successTitle : delegate.checkboxTitle
                            enabled: available && !successfulCompletion
                            checked: (enabled && (root.safeMode.selectedRestoreCategories & delegate.backupCategory) !== 0) || successfulCompletion
                            onToggled: {
                                root.safeMode.selectedRestoreCategories = checked
                                    ? (root.safeMode.selectedRestoreCategories | delegate.backupCategory)
                                    : (root.safeMode.selectedRestoreCategories & (root.safeMode.selectedRestoreCategories ^ delegate.backupCategory));
                            }
                        }
                    }
                }
            }
        }

        Kirigami.InlineMessage {
            visible: root.safeMode.preExistingRestoreTargetDirs.length > 0
            Layout.fillWidth: true
            type: Kirigami.MessageType.Warning
            text: i18ncp("@info",
                         "The following customization folder already exists: <ul>%2</ul> Move or delete your customization folder to continue.",
                         "The following customization folders already exist: <ul>%2</ul> Move or delete your customization folders to continue.",
                         root.safeMode.preExistingRestoreTargetDirs.length,
                         root.safeMode.preExistingRestoreTargetDirs.map((url) => "<li>" + new URL(url).pathname + "</li>").join()
            )
        }

        QQC2.Button {
            Layout.alignment: Qt.AlignHCenter
            visible: root.safeMode.successfulRestoreCategories === 0
            enabled: (root.safeMode.availableRestoreSources & root.safeMode.selectedRestoreCategories) !== 0
                     && root.safeMode.preExistingRestoreTargetDirs.length === 0
            icon.name: "edit-reset"
            text: xi18nc("@action:button", "Restore Customizations")

            onClicked: root.safeMode.restoreCustomizationsFromBackupDir()
        }

        Kirigami.InlineMessage {
            visible: root.safeMode.successfulRestoreCategories !== 0
            Layout.fillWidth: true
            type: Kirigami.MessageType.Positive
            text: i18nc("@info", "User customizations were successfully restored.")
        }
    }

    Dialogs.FolderDialog {
        id: backupDirDialog
        currentFolder: root.safeMode.backupDir
        onAccepted: {
            root.safeMode.backupDir = selectedFolder;
            root.safeMode.resetSuccessfulRestoreCategories();
        }
    }
}
