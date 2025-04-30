/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Kirigami.Page {
    id: root

    required property string error
    required property int pageType

    title: i18nc("@info:window", "Error loading page")

    actions: [
        Kirigami.Action {
            icon.name: "tools-report-bug-symbolic"
            text: i18nc("@action:button", "Report Bug…")
            onTriggered: Qt.openUrlExternally(root.pageType == Private.App.Distro ? Welcome.Distro.bugReportUrl : "https://bugs.kde.org/enter_bug.cgi?product=Welcome%20Center")
            visible: root.pageType != Private.App.Unknown
        },
        Kirigami.Action {
            icon.name: "edit-copy-symbolic"
            text: i18nc("@action:button", "Copy Details")
            onTriggered: Welcome.Utils.copyToClipboard(error)
        }
    ]

    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent

        width: parent.width - (Kirigami.Units.gridUnit * 2)

        icon.name: "tools-report-bug"
        text: {
            switch (root.pageType) {
                case Private.App.KDE:
                    return xi18nc("@info:usagetip", "This page provided by Welcome Center could not be loaded");
                case Private.App.Distro:
                    return xi18nc("@info:usagetip", "This page provided by your distribution could not be loaded");
                case Private.App.Unknown:
                    return xi18nc("@info:usagetip", "This page could not be loaded");
            }
        }
        explanation: root.error
    }
}
