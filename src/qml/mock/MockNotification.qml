/*
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3

import org.kde.plasma.welcome

Item {
    id: notification

    property string title: ""

    default property alias children: contentItem.children

    implicitWidth: Kirigami.Units.gridUnit * 18 + Kirigami.Units.smallSpacing * 2
    implicitHeight: 73

    KSvg.FrameSvgItem {
        anchors.fill: parent

        imagePath: "dialogs/background"
        //enabledBorders: KSvg.FrameSvg.AllBorders
    }

    KSvg.FrameSvgItem {
        anchors.fill: parent
        anchors.topMargin: -margins.top
        anchors.leftMargin: -margins.left
        anchors.rightMargin: -margins.right
        anchors.bottomMargin: -margins.bottom

        imagePath: "dialogs/background"
        prefix: "shadow"
    }

    Item {
        id: headingItem
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Kirigami.Units.smallSpacing

        height: headingLayout.implicitHeight

        KSvg.FrameSvgItem {
            anchors.fill: parent
            anchors.margins: -Kirigami.Units.smallSpacing

            imagePath: "widgets/plasmoidheading"
            prefix: "header"
            enabledBorders: KSvg.FrameSvg.AllBorders
        }

        RowLayout {
            id: headingLayout
            anchors.fill: parent

            Kirigami.Heading {
                Layout.fillWidth: true

                text: notification.title
                level: 5
            }

            Kirigami.Icon {
                Layout.margins: Kirigami.Units.smallSpacing

                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                implicitWidth: Kirigami.Units.iconSizes.smallMedium

                source: "window-close"
            }
        }
    }

    Item {
        id: contentItem
        anchors.top: headingItem.bottom
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.smallSpacing
        anchors.right: parent.right
        anchors.rightMargin: Kirigami.Units.smallSpacing
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.smallSpacing

        clip: true

        //opacity: plasmoid.actuallyOverflowing ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    PC3.Label {
        anchors.centerIn: contentItem

        //opacity: plasmoid.actuallyOverflowing ? 1 : 0
        opacity: 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        text: i18nc("@info:placeholder Shown when there is insufficent width", "Expand the window")
        color: PlasmaCore.Theme.textColor
    }
}
