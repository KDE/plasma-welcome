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
    description: xi18nc("@info:usagetip %1 is either 'System Settings' or 'Plasma Settings', the settings app for Plasma Desktop or Plasma Mobile", "Plasma is designed to be simple and usable out of the box. Things are where you'd expect, and there is generally no need to configure anything before you can be comfortable and productive.<nl/><nl/>Should you feel the need to, you'll find what you need in the <application>%1</application> app.", application.name)

    ApplicationIcon {
        anchors.centerIn: parent

        application: ApplicationInfo {
            id: application
            // TODO: If Plasma Mobile, use plasma-settings
            desktopName: "systemsettings"
        }

        size: Kirigami.Units.gridUnit * 10
    }
}
