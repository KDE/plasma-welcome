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

Welcome.Page {
    id: root

    heading: i18nc("@title:window", "Plasma has been updated to %1", Private.Release.friendlyVersion)
    description: contentLoader.item?.description ?? ""

    topContent: contentLoader.item?.topContent ?? []

    Loader {
        id: contentLoader
        anchors.fill: parent

        source: Private.App.mode === Private.App.Beta ? "Beta.qml" : "Update.qml"
    }
}
