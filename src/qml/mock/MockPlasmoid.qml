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
    id: plasmoid

    property bool floating: true
    property bool showBackButton: true
    property string title: ""
    property var extraHeaderIcons: []
    property bool overflowing: false

    // Necessary to prevent the message appearing briefly when first shown
    readonly property bool actuallyOverflowing: overflowing && contentItem.height > 0

    default property alias children: contentItem.children

    implicitWidth: Kirigami.Units.gridUnit * 24 + Kirigami.Units.smallSpacing * 2
    implicitHeight: Kirigami.Units.gridUnit * 24 + Kirigami.Units.smallSpacing * 2

    KSvg.FrameSvgItem {
        anchors.fill: parent

        imagePath: "dialogs/background"
        enabledBorders: plasmoid.floating ? KSvg.FrameSvg.AllBorders : (KSvg.FrameSvg.TopBorder | KSvg.FrameSvg.LeftBorder | KSvg.FrameSvg.RightBorder)
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

    KSvg.SvgItem {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        imagePath: "widgets/line"
        elementId: "horizontal-line"
        visible: !plasmoid.floating
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

            Kirigami.Icon {
                Layout.margins: Kirigami.Units.smallSpacing

                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                implicitWidth: Kirigami.Units.iconSizes.smallMedium

                source: "go-previous-symbolic"
                visible: plasmoid.showBackButton
            }

            Kirigami.Heading {
                Layout.fillWidth: true

                text: plasmoid.title
            }

            Repeater {
                model: plasmoid.extraHeaderIcons.concat(["configure", "window-pin"])
                delegate: Kirigami.Icon {
                    Layout.margins: Kirigami.Units.smallSpacing

                    implicitHeight: Kirigami.Units.iconSizes.smallMedium
                    implicitWidth: Kirigami.Units.iconSizes.smallMedium

                    source: modelData
                }
            }
        }
    }

    Item {
        id: contentItem
        anchors.top: headingItem.bottom
        anchors.topMargin: Kirigami.Units.smallSpacing * 2
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.smallSpacing
        anchors.right: parent.right
        anchors.rightMargin: Kirigami.Units.smallSpacing
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.smallSpacing

        clip: true

        opacity: plasmoid.actuallyOverflowing ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    PC3.Label {
        anchors.centerIn: contentItem

        opacity: plasmoid.actuallyOverflowing ? 1 : 0
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
