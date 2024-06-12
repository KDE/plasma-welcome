/*
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@ooutlook.com>
 *  SPDX-FileCopyrightText: 2024 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    contentItem: QQC2.Label {
        wrapMode: Text.Wrap
        text: xi18nc("@info:usagetip", "If you find Plasma to be useful, consider getting involved or donating. KDE is an international volunteer community, not a big company; your contributions make a real difference!")
    }
    footer: Kirigami.ActionToolBar {
        position: QQC2.ToolBar.Footer
        actions: [
            Kirigami.Action {
                icon.name: "donate-symbolic"
                text: i18nc("@action:button", "Make a donation…")
                onTriggered: Qt.openUrlExternally("https://kde.org/community/donations?source=plasma-welcome")
            },
            Kirigami.Action {
                icon.name: "group-symbolic"
                text: i18nc("@action:button", "Get involved…")
                onTriggered: Qt.openUrlExternally("https://community.kde.org/Get_Involved?source=plasma-welcome")
            }
        ]
    }
}
