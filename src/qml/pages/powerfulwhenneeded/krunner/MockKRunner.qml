/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome

import org.kde.plasma.components as PC3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.ksvg as KSvg
//NOTE: necessary for KSvg to load the Plasma theme
import org.kde.plasma.core as PlasmaCore

Item {
    id: root

    property string runnerText: ""

    // Wallpaper background image
    Image {
        // Anchor the wallpaper to the center
        // Above 1280x800, it will grow to fit, otherwise show the center
        width: Math.max(root.width, 1280)
        height: Math.max(root.height, 800)
        anchors.centerIn: parent

        fillMode: Image.PreserveAspectCrop
        source: "file:" + Controller.installPrefix() + "/share/wallpapers/Next/contents/images/1280x800.png"

        layer.enabled: true
        layer.effect: GaussianBlur {
            radius: 32
            samples: (radius * 2) + 1
            cached: true
        }
    }

    // Dialog container
    Item {
        width: layout.width + background.margins.left + background.margins.right
        height: layout.height + background.margins.top + background.margins.bottom

        anchors.centerIn: parent

        // Dialog background
        KSvg.FrameSvgItem {
            id: background
            anchors.fill: parent

            imagePath: "dialogs/background"
        }

        // Contents
        RowLayout {
            id: layout

            anchors.centerIn: parent

            width: Math.min(root.width - Kirigami.Units.gridUnit * 2, implicitWidth)

            Kirigami.Icon {
                Layout.margins: Kirigami.Units.smallSpacing
                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                implicitWidth: Kirigami.Units.iconSizes.smallMedium
                source: "configure"
                color: PlasmaCore.Theme.textColor
            }

            // Search field - wrapped in Item so disabling does not affect icons
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

                    text: root.runnerText

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

                    readonly property bool isClear: field.text.length > 0

                    anchors.right: field.right
                    anchors.rightMargin: Kirigami.Units.smallSpacing * 2
                    anchors.verticalCenter: field.verticalCenter
                    anchors.verticalCenterOffset: Math.round((field.topPadding - field.bottomPadding) / 2)

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
}
