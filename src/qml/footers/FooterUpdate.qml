/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome.private as Private

RowLayout {
    spacing: 0

    QQC2.Switch {
        Layout.fillWidth: true

        text: i18nc("@option:check", "Show after Plasma is updated")
        checked: Private.Config.showUpdatePage
        onToggled: { Private.Config.showUpdatePage = checked; Private.Config.save() }
    }

    Item {
        Layout.fillWidth: true
        Layout.minimumWidth: Kirigami.Units.smallSpacing
        Layout.horizontalStretchFactor: 1 // So this will be preferred to fill over the switch
    }

    QQC2.Button {
        id: okButton

        action: Kirigami.Action {
            text: i18nc("@action:button", "&OK")
            icon.name: "dialog-ok-apply-symbolic"
            shortcut: Qt.application.layoutDirection === Qt.LeftToRight ? "Right" : "Left"

            onTriggered: Qt.quit()
        }
    }
}
