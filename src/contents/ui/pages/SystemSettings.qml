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
import QtGraphicalEffects 1.15

GenericPage {
    heading: i18nc("@info:window", "Personalizing your System")
    description: i18nc("@info:usagetip", "System Settings lets you adjust the behaviors and appearance of the whole system. From theme options to device management, you can find it all here.")

    Kirigami.Icon {
        id: image
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Kirigami.Units.gridUnit * 4
        width: Kirigami.Units.gridUnit * 10
        height: Kirigami.Units.gridUnit * 10
        source: "systemsettings"

        HoverHandler {
            id: hoverhandler
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: Controller.open("systemsettings"); // Desktop file isn't namespaced, boo!
        }

        QQC2.ToolTip {
            visible: hoverhandler.hovered
            text: i18nc("@action:button", "Launch System Settings now")
        }

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 1
            radius: 20
            samples: 20
            color: Qt.rgba(0, 0, 0, 0.2)
        }
    }

    Kirigami.Heading {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: image.bottom
        text: i18nc("@title the name of the 'System Settings' app", "System Settings")
        wrapMode: Text.WordWrap
        level: 3
    }
}
