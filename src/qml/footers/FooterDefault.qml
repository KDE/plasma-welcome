/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

RowLayout {
    id: root

    spacing: Kirigami.Units.smallSpacing

    QQC2.Button {
        Layout.alignment: Qt.AlignLeft

        action: app.backAction
    }

    QQC2.PageIndicator {
        Layout.alignment: Qt.AlignHCenter

        enabled: !app.inLayer
        count: pageStack.depth
        currentIndex: pageStack.currentIndex
        onCurrentIndexChanged: pageStack.currentIndex = currentIndex
        interactive: true
    }

    QQC2.Button {
        Layout.alignment: Qt.AlignRight

        action: app.forwardAction
    }
}
