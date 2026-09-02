/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

import org.kde.plasma.welcome as Welcome

Welcome.Page {
    title: i18nc("@info:window", "Fix Your Desktop")
    description: xi18nc("@info:usagetip", "Here are some actions you can take to try fixing your regular Plasma session:")

    ColumnLayout {
        id: layout
        anchors.fill: parent

        spacing: Kirigami.Units.largeSpacing

        FormCard.FormCard {
            id: formCard

            Layout.alignment: Qt.AlignTop
            maximumWidth: Kirigami.Units.gridUnit * 25

            Repeater {
                id: formCardRepeater
                model: [
                    {
                        leadingIcon: "edit-clear-all",
                        title: i18nc("@title:row", "Clear Cache Files"),
                        subtitle: i18nc("@info subtitle for Open Config Folder", "Safe to try; cache files are automatically regenerated"),
                        page: "ClearCache.qml"
                    },
                    {
                        leadingIcon: "edit-reset",
                        title: i18nc("@title:row", "Reset Customizations and Restore Defaults"),
                        subtitle: i18nc("@info subtitle for Reset Customizations", "Your data will be safely backed up"),
                        page: "ResetCustomizations.qml"
                    },
                    {
                        leadingIcon: "document-import",
                        title: i18nc("@title:row", "Restore Customizations"),
                        subtitle: i18nc("@info subtitle for Restore Customizations", "Select a backup location to restore previous customizations"),
                        page: "RestoreCustomizations.qml"
                    },
                    {
                        leadingIcon: LayoutMirroring.enabled ? "system-log-out-rtl-symbolic" : "system-log-out-symbolic",
                        title: i18nc("@title:row", "Exit Safe Mode"),
                        subtitle: i18nc("@info subtitle for Exit Safe Mode", "Switch back to your regular session when you are done"),
                        page: "ExitSafeMode.qml"
                    },
                ]
                delegate: FormCard.FormButtonDelegate {
                    id: delegate

                    required property string leadingIcon
                    required property string title
                    required property string subtitle
                    required property string page

                    // We can set icon.name, but we want it bigger
                    leading: Kirigami.Icon {
                        implicitWidth: Kirigami.Units.iconSizes.medium
                        implicitHeight: Kirigami.Units.iconSizes.medium

                        source: delegate.leadingIcon
                    }

                    text: delegate.title
                    description: delegate.subtitle

                    onClicked: {
                        pageStack.layers.push(app._createPage(delegate.page))
                    }
                }
            }
        }
    }
}
