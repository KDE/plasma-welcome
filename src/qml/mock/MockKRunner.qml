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
import org.kde.plasma.extras as PlasmaExtras

import org.kde.plasma.welcome

Item {
    id: root

    // NOTE: Distros overriding our default KRunner position should patch this
    // e.g. 'Position on screen: Center' as `position: Qt.AlignCenter`
    readonly property int position: Qt.AlignHCenter | Qt.AlignTop

    property string searchText: ""

    implicitWidth: layout.implicitWidth + layout.anchors.margins * 2
    implicitHeight: layout.implicitHeight + layout.anchors.margins * 2

    KSvg.FrameSvgItem {
        anchors.fill: background

        anchors.topMargin: -margins.top
        anchors.leftMargin: -margins.left
        anchors.rightMargin: -margins.right
        anchors.bottomMargin: -margins.bottom

        imagePath: "dialogs/background"
        prefix: "shadow"
    }

    KSvg.FrameSvgItem {
        id: background
        anchors.fill: parent

        imagePath: "dialogs/background"
        enabledBorders: {
            if (root.position == Qt.AlignCenter) {
                // Position on screen: Center
                return KSvg.FrameSvg.AllBorders
            } else {
                // Position on screen: Top
                return KSvg.FrameSvg.BottomBorder | KSvg.FrameSvg.LeftBorder | KSvg.FrameSvg.RightBorder
            }
        }
    }

    RowLayout {
        id: layout
        anchors.fill: root
        anchors.margins: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            Layout.margins: Kirigami.Units.smallSpacing

            implicitHeight: Kirigami.Units.iconSizes.smallMedium
            implicitWidth: Kirigami.Units.iconSizes.smallMedium

            source: "configure"
            color: PlasmaCore.Theme.textColor
        }

        // Wrapped so disabling the search field does not affect the icons
        // and we can position search/clear icons with anchors
        Item {
            Layout.fillWidth: true

            implicitWidth: Kirigami.Units.gridUnit * 25
            implicitHeight: field.implicitHeight

            PlasmaExtras.ActionTextField {
                id: field
                anchors.fill: parent

                enabled: false
                opacity: 1

                color: PlasmaCore.Theme.textColor
                placeholderTextColor: PlasmaCore.Theme.disabledTextColor

                placeholderText: i18nd("libplasma6", "Search…")
                text: root.searchText

                cursorVisible: true

                Timer {
                    id: cursorVisibleTimer

                    running: true
                    repeat: true
                    interval: Qt.styleHints.cursorFlashTime / 2
                    onTriggered: field.cursorVisible = !field.cursorVisible
                }

                background: KSvg.FrameSvgItem {
                    implicitWidth: Kirigami.Units.gridUnit * 8 + margins.left + margins.right
                    implicitHeight: Kirigami.Units.gridUnit + margins.top + margins.bottom
                    imagePath: "widgets/lineedit"
                    prefix: "base"

                    KSvg.FrameSvgItem {
                        anchors.fill: parent
                        anchors.leftMargin: -margins.left
                        anchors.topMargin: -margins.top
                        anchors.rightMargin: -margins.right
                        anchors.bottomMargin: -margins.bottom

                        imagePath: "widgets/lineedit"
                        prefix: "focus"
                    }
                }

                readonly property bool hasMargins: field.background.hasOwnProperty("margins")

                leftPadding: searchIcon.width + searchIcon.anchors.leftMargin + (hasMargins ? field.background.margins.left : 0)
                rightPadding: clearIcon.width + clearIcon.anchors.rightMargin + (hasMargins ? field.background.margins.right : 0)
            }

            Kirigami.Icon {
                id: searchIcon
                anchors.left: field.left
                anchors.leftMargin: Kirigami.Units.smallSpacing * 2
                anchors.verticalCenter: field.verticalCenter
                anchors.verticalCenterOffset: Math.round((field.topPadding - field.bottomPadding) / 2)

                implicitHeight: Kirigami.Units.iconSizes.sizeForLabels
                implicitWidth: Kirigami.Units.iconSizes.sizeForLabels

                color: PlasmaCore.Theme.textColor
                source: "search"
            }

            Kirigami.Icon {
                id: clearIcon

                anchors.right: field.right
                anchors.rightMargin: Kirigami.Units.smallSpacing * 2
                anchors.verticalCenter: field.verticalCenter
                anchors.verticalCenterOffset: Math.round((field.topPadding - field.bottomPadding) / 2)

                readonly property bool isClear: field.text.length > 0

                implicitHeight: isClear ? Kirigami.Units.iconSizes.sizeForLabels : Kirigami.Units.iconSizes.smallMedium
                implicitWidth: isClear ? Kirigami.Units.iconSizes.sizeForLabels : Kirigami.Units.iconSizes.smallMedium

                color: PlasmaCore.Theme.textColor
                // "Expand" icon looks slightly different in KRunner, likely implemented on
                // top of the search field ...there are limits to what we should copy
                source: isClear ? "edit-clear-locationbar-rtl" : "expand"
            }
        }

        Kirigami.Icon {
            Layout.margins: Kirigami.Units.smallSpacing

            implicitHeight: Kirigami.Units.iconSizes.smallMedium
            implicitWidth: Kirigami.Units.iconSizes.smallMedium

            source: "question"
            color: PlasmaCore.Theme.textColor
        }

        Kirigami.Icon {
            Layout.margins: Kirigami.Units.smallSpacing

            implicitHeight: Kirigami.Units.iconSizes.smallMedium
            implicitWidth: Kirigami.Units.iconSizes.smallMedium

            source: "window-pin"
            color: PlasmaCore.Theme.textColor
        }
    }
}
