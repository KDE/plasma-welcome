/*
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *  SPDX-FileCopyrightText: 2024 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    contentItem: QQC2.Label {
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        text: xi18nc("@info:usagetip", "If you find Plasma to be useful, consider getting involved or donating. KDE is an international volunteer community, not a big company; your contributions make a real difference!")
    }

    footer: RowLayout {
        spacing: 0

        Item {
            Layout.fillWidth: true
        }

        Kirigami.UrlButton {
            text: i18nc("@action:button", "Make a donation")
            url: "https://kde.org/community/donations?source=plasma-welcome"
        }

        Kirigami.UrlButton {
            Layout.leftMargin: Kirigami.Units.largeSpacing

            text: i18nc("@action:button", "Get involved")
            url: "https://community.kde.org/Get_Involved?source=plasma-welcome"
        }

        Item {
            Layout.fillWidth: true
        }
    }
}
