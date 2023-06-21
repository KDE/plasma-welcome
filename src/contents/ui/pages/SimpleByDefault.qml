/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import Qt5Compat.GraphicalEffects

import org.kde.plasma.welcome 1.0

GenericPage {
    heading: i18nc("@info:window", "Simple by Default")
    description: xi18nc("@info:usagetip", "Plasma is designed to be simple and usable out of the box. Things are where you'd expect, and there is generally no need to configure anything before you can be comfortable and productive.<nl/><nl/>Should you feel the need to, you'll find what you need in the <application>System Settings</application> app.")

    ApplicationIcon {
        anchors.centerIn: parent

        application: "systemsettings"
        size: Kirigami.Units.gridUnit * 10
    }
}
