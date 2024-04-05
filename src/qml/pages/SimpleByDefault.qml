/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome

GenericPage {
    heading: i18nc("@info:window", "Simple by Default")
    description: xi18nc("@info:usagetip", "Plasma is designed to be simple and usable out of the box. Things are where you'd expect, and there is generally no need to configure anything before you can be comfortable and productive.<nl/><nl/>Below is a visual representation of a typical Plasma Desktop; move the pointer over things to learn what they are!")

    Kirigami.AbstractCard {
        anchors.fill: parent

        MockPanel {
            id: mockPanel

            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing

            clip: true
        }
    }
}
