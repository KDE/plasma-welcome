/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome

import org.kde.plasma.components as PC3
import org.kde.ksvg as KSvg
//NOTE: necessary for KSvg to load the Plasma theme
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support

Item {
    id: root

    property bool onlyShowTrayArea: false
    property bool networkArrowAnimates: false
    property bool networkIconConnecting: false
    property string networkIcon: "network-wireless-symbolic"

    // To get the current date and time
    P5Support.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }

    // Wallpaper background image
    Image {
        // Anchor the wallpaper to the bottom-right
        // Above 1280x800, it will grow to fit, otherwise show a cropped region
        width: Math.max(root.width, 1280)
        height: Math.max(root.height, 800)
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        fillMode: Image.PreserveAspectCrop
        source: "file:" + Controller.installPrefix() + "/share/wallpapers/Next/contents/images/1280x800.png"

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 1.0
            blurMax: 32
        }
    }

    HoverHandler {
        id: desktopWatcher
        enabled: !root.onlyShowTrayArea
        onHoveredChanged: {
            if (hovered) {
                explanatoryLabel.text = xi18nc("@info", "This is the Desktop. You can drag files to or from it for quick access to recent work. Right-click on it and choose <interface>Desktop and Wallpaper</interface> to change the wallpaper.");
            }
        }
    }

    // Info box
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width / 2, Kirigami.Units.gridUnit * 25)
        height: explanatoryLabel.implicitHeight + (explanatoryLabel.anchors.margins * 2)
        Behavior on height {
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
        radius: explanatoryLabel.anchors.margins

        visible: !root.onlyShowTrayArea && opacity > 0
        color: "black"

        opacity: (desktopWatcher.hovered
            || kickoffWatcher.hovered
            || taskManagerWatcher.hovered
            || panelWatcher.hovered
            || systemTrayWatcher.hovered
            || digitalClockWatcher.hovered
            || peekAtDesktopWatcher.hovered) ? 0.8 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }

        PC3.Label {
            id: explanatoryLabel

            anchors {
                margins: Kirigami.Units.largeSpacing
                left: parent.left
                top: parent.top
                right: parent.right

            }
            wrapMode: Text.Wrap

            color: "white"
            // Text is set imperatively by the hover handlers below, so that it
            // can remain visible after stuff is no longer hovered and the info
            // box can do a nice fade-out
        }
    }

    // Panel shadow
    KSvg.FrameSvgItem {
        anchors.fill: panelContainer
        anchors.topMargin: -margins.top
        anchors.leftMargin: -margins.left
        anchors.rightMargin: -margins.right
        anchors.bottomMargin: -margins.bottom

        imagePath: "solid/widgets/panel-background"
        prefix: "shadow"
    }

    // Panel container
    Item {
        id: panelContainer

        readonly property int rightMargin: root.onlyShowTrayArea ? anchors.margins * 2 : 0
        readonly property int spaceNeeded: appletContainer.implicitWidth + systemTrayContainer.implicitWidth + Kirigami.Units.largeSpacing

        width: Math.max(root.width, 1280) - rightMargin // This overflows, but we clip both it and the background
                                                        // 1280 matches the size of the wallpaper
        height: 44 // Default panel height

        anchors.margins: Kirigami.Units.largeSpacing // Floating margins
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: root.onlyShowTrayArea ? undefined : parent.left

        readonly property int contentPadding: Kirigami.Units.largeSpacing
        readonly property int contentHeight: panelContainer.height - panelContainer.contentPadding * 2

        // Panel background
        KSvg.FrameSvgItem {
            anchors.fill: parent

            imagePath: "widgets/panel-background"
        }

        HoverHandler {
            id: panelWatcher
            enabled: !root.onlyShowTrayArea
            onHoveredChanged: {
                if (hovered) {
                    explanatoryLabel.text = xi18nc("@info", "This is a “Panel”—a container to hold widgets. Right-click on it and choose <interface>Show Panel Configuration</interface> to change how it behaves, which screen edge it lives on, and what widgets it contains.");
                }
            }
        }

        // Kickoff and Task manager
        RowLayout {
            id: appletContainer

            readonly property int iconSize: Kirigami.Units.iconSizes.roundedIconSize(height)

            anchors {
                left: parent.left
                leftMargin: Kirigami.Units.largeSpacing
                top: parent.top
                bottom: parent.bottom
            }

            spacing: Kirigami.Units.largeSpacing * 2

            visible: !root.onlyShowTrayArea

            // Kickoff
            Kirigami.Icon {
                implicitWidth: appletContainer.iconSize
                implicitHeight: appletContainer.iconSize

                source: "start-here-kde-plasma-symbolic"
                color: PlasmaCore.Theme.textColor

                HoverHandler {
                    id: kickoffWatcher
                    onHoveredChanged: {
                        if (hovered) {
                            explanatoryLabel.text = i18nc("@info", "This is the “Kickoff” widget, a multipurpose launcher. Here you can launch apps, shut down or restart the system, access recent files, and more. Click on it to get started!");
                        }
                    }
                }
            }

            // Task Manager
            RowLayout {
                spacing: appletContainer.spacing

                HoverHandler {
                    id: taskManagerWatcher
                    onHoveredChanged: {
                        if (hovered) {
                            explanatoryLabel.text = i18nc("@info", "This is the “Task Manager” widget, where you can switch between open apps and also launch new ones. Drag app icons to re-arrange them.")
                        }
                    }
                }

                // Pinned Dolphin icon
                Kirigami.Icon {
                    implicitWidth: appletContainer.iconSize
                    implicitHeight: appletContainer.iconSize
                    source: "system-file-manager"
                }
                // Pinned System Settings icon
                Kirigami.Icon {
                    implicitWidth: appletContainer.iconSize
                    implicitHeight: appletContainer.iconSize
                    source: "systemsettings"
                }
                // Pinned Discover icon
                Kirigami.Icon {
                    implicitWidth: appletContainer.iconSize
                    implicitHeight: appletContainer.iconSize
                    source: "plasmadiscover"
                }
            }
        }

        // Applet container
        RowLayout {
            id: systemTrayContainer

            readonly property int iconSize: Kirigami.Units.iconSizes.roundedIconSize(height - (panelContainer.contentPadding * 2))

            anchors {
                right: parent.right
                rightMargin: Kirigami.Units.largeSpacing
                top: parent.top
                bottom: parent.bottom
            }

            spacing: Kirigami.Units.smallSpacing

            // System Tray
            RowLayout {
                id: appletSystemTray

                readonly property int iconMargins: Kirigami.Units.smallSpacing

                spacing: 0

                opacity: panelContainer.width > panelContainer.spaceNeeded ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Kirigami.Units.shortDuration
                        easing.type: Easing.InOutQuad
                    }
                }

                HoverHandler {
                    id: systemTrayWatcher
                    enabled: !root.onlyShowTrayArea && appletSystemTray.opacity > 0
                    onHoveredChanged: {
                        if (hovered) {
                            explanatoryLabel.text = i18nc("@info", "This is the “System Tray” widget, which lets you control system functions like changing the volume and connecting to networks. Items will become visible here only when relevant. To see all available items, click the arrow.")
                        }
                    }
                }

                Kirigami.Icon {
                    Layout.leftMargin: appletSystemTray.iconMargins
                    Layout.rightMargin: appletSystemTray.iconMargins

                    implicitWidth: systemTrayContainer.iconSize
                    implicitHeight: systemTrayContainer.iconSize

                    source: "klipper-symbolic"
                    color: PlasmaCore.Theme.textColor
                }

                Kirigami.Icon {
                    Layout.leftMargin: appletSystemTray.iconMargins
                    Layout.rightMargin: appletSystemTray.iconMargins

                    implicitWidth: systemTrayContainer.iconSize
                    implicitHeight: systemTrayContainer.iconSize

                    source: "audio-volume-high"
                    color: PlasmaCore.Theme.textColor
                }

                Kirigami.Icon {
                    Layout.leftMargin: appletSystemTray.iconMargins
                    Layout.rightMargin: appletSystemTray.iconMargins

                    implicitWidth: Kirigami.Units.iconSizes.smallMedium
                    implicitHeight: Kirigami.Units.iconSizes.smallMedium

                    source: root.networkIcon
                    color: PlasmaCore.Theme.textColor

                    PC3.BusyIndicator {
                        id: connectingIndicator

                        anchors.centerIn: parent
                        height: Math.min(parent.width, parent.height)
                        width: height
                        running: root.networkIconConnecting
                        visible: running
                    }
                }

                Kirigami.Icon {
                    id: trayExpanderArrow
                    implicitWidth: Kirigami.Units.iconSizes.smallMedium
                    implicitHeight: Kirigami.Units.iconSizes.smallMedium

                    source: "arrow-up"
                    color: PlasmaCore.Theme.textColor

                    Rectangle {
                        z: -1
                        anchors.centerIn: parent
                        implicitWidth: trayExpanderArrow.implicitWidth * 2
                        implicitHeight: trayExpanderArrow.implicitHeight * 2
                        radius: implicitWidth / 2
                        color: "white"
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            blurEnabled: true
                            blur: 1.0
                            blurMax: 36
                        }
                        visible: opacity > 0
                        opacity: systemTrayWatcher.hovered ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Kirigami.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }
            }

            // Digital Clock
            Item {
                Layout.preferredWidth: Math.max(timeLabel.paintedWidth,
                                                dateLabel.paintedWidth + Kirigami.Units.largeSpacing)
                implicitHeight: panelContainer.contentHeight

                HoverHandler {
                    id: digitalClockWatcher
                    enabled: !root.onlyShowTrayArea
                    onHoveredChanged: {
                        if (hovered) {
                            explanatoryLabel.text = i18nc("@info", "This is the “Digital Clock” widget. Click on it to show a calendar. It can be also configured to show other timezones and events from your digital calendars.")
                        }
                    }
                }

                PC3.Label {
                    id: timeLabel

                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: Qt.formatTime(timeSource.data["Local"]["DateTime"])

                    width: paintedWidth
                    height: 15.68
                    font.pixelSize: 16
                    color: PlasmaCore.Theme.textColor

                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                PC3.Label {
                    id: dateLabel

                    anchors.top: timeLabel.bottom
                    anchors.horizontalCenter: timeLabel.horizontalCenter

                    text: Qt.formatDate(timeSource.data["Local"]["DateTime"], Qt.DefaultLocaleShortDate)

                    width: paintedWidth
                    height: 12.544
                    font.pixelSize: 13
                    color: PlasmaCore.Theme.textColor

                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Peek at Desktop
            Item {
                width: 32
                height: systemTrayContainer.iconSize

                HoverHandler {
                    id: peekAtDesktopWatcher
                    enabled: !root.onlyShowTrayArea
                    onHoveredChanged: {
                        if (hovered) {
                            explanatoryLabel.text = i18nc("@info", "This is the “Peek at Desktop” widget. Click on it to temporarily hide all open windows so you can access the desktop. Click on it again to bring them back.")
                        }
                    }
                }

                Kirigami.Icon {
                    anchors.centerIn: parent
                    implicitWidth: systemTrayContainer.iconSize
                    implicitHeight: systemTrayContainer.iconSize

                    source: "user-desktop-symbolic"
                    color: PlasmaCore.Theme.textColor
                }
            }
        }
    }

    // Arrow container
    Kirigami.Icon {
        id: indicatorArrow

        width : Kirigami.Units.iconSizes.large
        height: Kirigami.Units.iconSizes.large

        source: "arrow-down"

        property real yOffset: Kirigami.Units.gridUnit

        anchors.right: panelContainer.right
        anchors.rightMargin: - (width / 2)                                                        // Center the arrow on target
                             + systemTrayContainer.width + systemTrayContainer.anchors.rightMargin        // Align with the left of the applet container
                             - (systemTrayContainer.iconSize / 2 + appletSystemTray.iconMargins)      // Align with the first icon
                             - (systemTrayContainer.iconSize + appletSystemTray.iconMargins * 2 ) * 2 // Align with the network icon
        anchors.bottom: panelContainer.top
        anchors.bottomMargin: yOffset

        layer.enabled: true
        layer.effect: Glow {
            radius: 6
            samples: (radius * 2) + 1
            spread: 0.5
            color: "white"
        }

        SequentialAnimation on yOffset {
            running: root.networkArrowAnimates
            loops: Animation.Infinite
            alwaysRunToEnd: true

            NumberAnimation {
                from: Kirigami.Units.gridUnit
                to: 0
                duration: 1000
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                from: 0
                to: Kirigami.Units.gridUnit
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }

        visible: opacity > 0
        opacity: root.networkArrowAnimates ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
}
