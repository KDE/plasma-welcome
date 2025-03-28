/*
 *  SPDX-FileCopyrightText: 2024 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Welcome.Page {
    id: root

    heading: i18nc("@info:window", "Simple by Default")
    description: xi18nc("@info:usagetip", "Plasma is designed to be simple and usable out of the box. Things are where you would expect, and there is generally no need to configure anything before you can be comfortable and productive.")

    // Internal navigation
    readonly property bool canDoSlideshow: !mockPanel.overflowing
    readonly property int slideshowCount: 8
    property int slideshowIndex: 0

    // Override external navigation for slideshow
    overrideBack: slideshowIndex != 0 && canDoSlideshow
    overrideForward: slideshowIndex != (slideshowCount - 1) && canDoSlideshow

    function back() {
        slideshowIndex -= 1;
    }

    function forward() {
        slideshowIndex += 1;
    }

    // Update internal navigation based on external navigation
    // i.e. if a user skips to before the slideshow, they'll expect to see the start of it
    Connections {
        target: pageStack
        function onCurrentItemChanged() {
            let pageIndex = pageStack.items.indexOf(root);
            if (pageStack.currentIndex < pageIndex) {
                // External navigation is before our page, so the slideshow should be at beginning
                slideshowIndex = 0;
            } else if (pageStack.currentIndex > pageIndex) {
                // External navigation is after our page, slideshow should be at end
                slideshowIndex = (slideshowCount - 1);
            }
        }
    }

    states: [
        State {
            name: "overflowing"
            when: !root.canDoSlideshow
            PropertyChanges {
                target: explanatoryLabel
                text: i18nc("@info", "The window is not large enough to show a visual representation of the Plasma desktop — please expand the window.")
            }
            PropertyChanges { target: explanatoryIndicator; enabled: false }
            PropertyChanges { target: mock;              blurRadius: 64 }
            PropertyChanges { target: backgroundOverlay; opacity: 0.6 }
            PropertyChanges { target: mockPanel;         opacity: 0   }
            PropertyChanges { target: mockKickoff;       opacity: 1   }
            PropertyChanges { target: mockTaskManager;   opacity: 1   }
            PropertyChanges { target: mockTray;          opacity: 1   }
            PropertyChanges { target: mockClock;         opacity: 1   }
            PropertyChanges { target: mockShowDesktop;   opacity: 1   }
        },
        State {
            name: "initial"
            when: root.slideshowIndex == 0
            PropertyChanges {
                target: explanatoryLabel
                text: i18nc("@info", "This is a visual representation of a typical Plasma desktop: continue to learn about all its parts!")
            }
            PropertyChanges { target: explanatoryIndicator; enabled: true }
            PropertyChanges { target: mock;              blurRadius: 32 }
            PropertyChanges { target: backgroundOverlay; opacity: 0 }
            PropertyChanges { target: mockPanel;         opacity: 1 }
            PropertyChanges { target: mockKickoff;       opacity: 1 }
            PropertyChanges { target: mockTaskManager;   opacity: 1 }
            PropertyChanges { target: mockTray;          opacity: 1 }
            PropertyChanges { target: mockClock;         opacity: 1 }
            PropertyChanges { target: mockShowDesktop;   opacity: 1 }
        },
        State {
            name: "desktop"
            when: root.slideshowIndex == 1
            PropertyChanges {
                target: explanatoryLabel
                text: xi18nc("@info", "This is the “Desktop”. It shows files and folders that are contained in your <filename>Desktop</filename> folder, and can hold widgets. Right-click on it and choose <interface>Desktop and Wallpaper…</interface> to configure the appearance of the desktop. You can also choose <interface>Enter Edit Mode</interface> to add, remove or modify widgets.")
            }
            PropertyChanges { target: explanatoryIndicator; enabled: true }
            PropertyChanges { target: mock;              blurRadius: 0 }
            PropertyChanges { target: backgroundOverlay; opacity: 0   }
            PropertyChanges { target: mockPanel;         opacity: 0.4 }
            PropertyChanges { target: mockKickoff;       opacity: 1   }
            PropertyChanges { target: mockTaskManager;   opacity: 1   }
            PropertyChanges { target: mockTray;          opacity: 1   }
            PropertyChanges { target: mockClock;         opacity: 1   }
            PropertyChanges { target: mockShowDesktop;   opacity: 1   }
        },
        State {
            name: "panel"
            when: root.slideshowIndex == 2
            PropertyChanges {
                target: explanatoryLabel
                text: xi18nc("@info", "This is a “Panel” — a container to hold widgets. Right-click on it and choose <interface>Show Panel Configuration</interface> to change how it behaves, which screen edge it lives on, and to add, remove or modify widgets.")
            }
            PropertyChanges { target: explanatoryIndicator; enabled: true }
            PropertyChanges { target: mock;              blurRadius: 64 }
            PropertyChanges { target: backgroundOverlay; opacity: 0.6 }
            PropertyChanges { target: mockPanel;         opacity: 1   }
            PropertyChanges { target: mockKickoff;       opacity: 1   }
            PropertyChanges { target: mockTaskManager;   opacity: 1   }
            PropertyChanges { target: mockTray;          opacity: 1   }
            PropertyChanges { target: mockClock;         opacity: 1   }
            PropertyChanges { target: mockShowDesktop;   opacity: 1   }
        },
        State {
            when: root.slideshowIndex == 3
            name: "kickoff"
            PropertyChanges {
                target: explanatoryLabel
                text: i18nc("@info", "This is the “Kickoff” widget, a multipurpose launcher. Here you can launch apps, shut down or restart the system, access recent files, and more. Click on it to get started!")
            }
            PropertyChanges { target: explanatoryIndicator; enabled: true }
            PropertyChanges { target: mock;              blurRadius: 64 }
            PropertyChanges { target: backgroundOverlay; opacity: 0.6 }
            PropertyChanges { target: mockPanel;         opacity: 1   }
            PropertyChanges { target: mockKickoff;       opacity: 1   }
            PropertyChanges { target: mockTaskManager;   opacity: 0.4 }
            PropertyChanges { target: mockTray;          opacity: 0.4 }
            PropertyChanges { target: mockClock;         opacity: 0.4 }
            PropertyChanges { target: mockShowDesktop;   opacity: 0.4 }
        },
        State {
            when: root.slideshowIndex == 4
            name: "taskManager"
            PropertyChanges {
                target: explanatoryLabel
                text: i18nc("@info", "This is the “Task Manager” widget, where you can switch between open apps and also launch new ones. Drag app icons to re-arrange them.")
            }
            PropertyChanges { target: explanatoryIndicator; enabled: true }
            PropertyChanges { target: mock;              blurRadius: 64 }
            PropertyChanges { target: backgroundOverlay; opacity: 0.6 }
            PropertyChanges { target: mockPanel;         opacity: 1   }
            PropertyChanges { target: mockKickoff;       opacity: 0.4 }
            PropertyChanges { target: mockTaskManager;   opacity: 1   }
            PropertyChanges { target: mockTray;          opacity: 0.4 }
            PropertyChanges { target: mockClock;         opacity: 0.4 }
            PropertyChanges { target: mockShowDesktop;   opacity: 0.4 }
        },
        State {
            when: root.slideshowIndex == 5
            name: "tray"
            PropertyChanges {
                target: explanatoryLabel
                text: i18nc("@info", "This is the “System Tray” widget, which lets you control system functions like changing the volume and connecting to networks. Items will become visible here only when relevant. To see all available items, click the ⌃ arrow next to the clock.")
            }
            PropertyChanges { target: explanatoryIndicator; enabled: true }
            PropertyChanges { target: mock;              blurRadius: 64 }
            PropertyChanges { target: backgroundOverlay; opacity: 0.6 }
            PropertyChanges { target: mockPanel;         opacity: 1   }
            PropertyChanges { target: mockKickoff;       opacity: 0.4 }
            PropertyChanges { target: mockTaskManager;   opacity: 0.4 }
            PropertyChanges { target: mockTray;          opacity: 1   }
            PropertyChanges { target: mockClock;         opacity: 0.4 }
            PropertyChanges { target: mockShowDesktop;   opacity: 0.4 }
        },
        State {
            when: root.slideshowIndex == 6
            name: "clock"
            PropertyChanges {
                target: explanatoryLabel
                text: i18nc("@info", "This is the “Digital Clock” widget. Click on it to show a calendar. It can be also configured to show other timezones and events from your digital calendars.")
            }
            PropertyChanges { target: explanatoryIndicator; enabled: true }
            PropertyChanges { target: mock;              blurRadius: 64 }
            PropertyChanges { target: backgroundOverlay; opacity: 0.6 }
            PropertyChanges { target: mockPanel;         opacity: 1   }
            PropertyChanges { target: mockKickoff;       opacity: 0.4 }
            PropertyChanges { target: mockTaskManager;   opacity: 0.4 }
            PropertyChanges { target: mockTray;          opacity: 0.4 }
            PropertyChanges { target: mockClock;         opacity: 1   }
            PropertyChanges { target: mockShowDesktop;   opacity: 0.4 }
        },
        State {
            when: root.slideshowIndex == 7
            name: "showDesktop"
            PropertyChanges {
                target: explanatoryLabel
                text: i18nc("@info", "This is the “Peek at Desktop” widget. Click on it to temporarily hide all open windows so you can access the desktop. Click on it again to bring them back.")
            }
            PropertyChanges { target: explanatoryIndicator; enabled: true }
            PropertyChanges { target: mock;              blurRadius: 64 }
            PropertyChanges { target: backgroundOverlay; opacity: 0.6 }
            PropertyChanges { target: mockPanel;         opacity: 1   }
            PropertyChanges { target: mockKickoff;       opacity: 0.4 }
            PropertyChanges { target: mockTaskManager;   opacity: 0.4 }
            PropertyChanges { target: mockTray;          opacity: 0.4 }
            PropertyChanges { target: mockClock;         opacity: 0.4 }
            PropertyChanges { target: mockShowDesktop;   opacity: 1   }
        }
    ]

    PlasmaNMLoader {
        id: nmLoader
    }

    Private.MockCard {
        id: mock
        anchors.fill: parent

        backgroundAlignment: Qt.AlignHCenter | Qt.AlignBottom

        Behavior on blurRadius { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }}

        Rectangle {
            id: backgroundOverlay
            anchors.fill: parent

            Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }}
            color: Kirigami.Theme.backgroundColor
        }

        Private.MockPanel {
            id: mockPanel
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            layer.enabled: true
            Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }}

            readonly property bool overflowing: parent.width < implicitWidth

            width: parent.width

            Private.MockKickoffApplet {
                id: mockKickoff
                active: root.state == "kickoff"
                Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }}
            }

            Private.MockTaskManager {
                id: mockTaskManager
                active: root.state == "taskManager"
                Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }}
            }

            // Minimum free space
            Item {
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Private.MockSystemTrayApplet {
                id: mockTray

                layer.enabled: true
                Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }}

                active: root.state == "tray"

                Private.MockSystemTrayIcon { source: "audio-volume-high-symbolic" }
                Private.MockSystemTrayIcon { source: "brightness-high-symbolic" }
                Private.MockSystemTrayIcon { source: nmLoader.icon }
            }

            Private.MockDigitalClockApplet {
                id: mockClock
                active: root.state == "clock"
                Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }}
            }

            Private.MockShowDesktopApplet {
                id: mockShowDesktop
                active: root.state == "showDesktop"
                Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }}
            }
        }

        Item {
            id: explanatoryContainer

            anchors.centerIn: parent
            anchors.verticalCenterOffset: root.canDoSlideshow ? Math.round(-mockPanel.height / 2) : 0
            Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }}

            width: explanatoryShadow.width
            height: explanatoryShadow.height

            KSvg.FrameSvgItem {
                id: explanatoryShadow
                anchors.fill: explanatoryBackground

                anchors.topMargin: -margins.top
                anchors.leftMargin: -margins.left
                anchors.rightMargin: -margins.right
                anchors.bottomMargin: -margins.bottom

                imagePath: "widgets/tooltip"
                prefix: "shadow"
            }

            KSvg.FrameSvgItem {
                id: explanatoryBackground
                anchors.fill: explanatoryLayout

                anchors.topMargin: -margins.top
                anchors.leftMargin: -margins.left
                anchors.rightMargin: -margins.right
                anchors.bottomMargin: -margins.bottom

                imagePath: "widgets/tooltip"
            }

            ColumnLayout {
                id: explanatoryLayout
                anchors.centerIn: parent

                width: Math.min(Math.round(mock.width / 1.5), Kirigami.Units.gridUnit * 25)
                height: explanatoryLayout.implicitHeight

                spacing: 0

                // Item so we can clip label
                Item {
                    Layout.fillWidth: true
                    Layout.margins: Kirigami.Units.smallSpacing
                    implicitHeight: explanatoryLabel.implicitHeight

                    Behavior on implicitHeight {
                        NumberAnimation {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }

                    clip: true

                    PC3.Label {
                        id: explanatoryLabel
                        anchors.fill: parent

                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        color: PlasmaCore.Theme.textColor
                    }
                }

                QQC2.PageIndicator {
                    id: explanatoryIndicator
                    Layout.margins: Kirigami.Units.smallSpacing
                    Layout.alignment: Qt.AlignHCenter

                    count: root.slideshowCount
                    currentIndex: root.slideshowIndex
                    onCurrentIndexChanged: root.slideshowIndex = currentIndex
                    interactive: true
                }
            }
        }
    }
}
