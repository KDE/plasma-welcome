/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Welcome.Page {
    id: root

    readonly property bool isPrerelease: Private.Release.isBeta || Private.Release.isDevelopment

    heading: i18nc("@title:window", "Plasma has been updated to %1", Private.Release.friendlyVersion)
    description: isPrerelease ? xi18nc("@info:usagetip", "Thank you for testing this beta release of Plasma — your feedback is fundamental to helping us improve it! Please report any and all bugs you find so that we can fix them.") : xi18nc("@info:usagetip", "KDE contributors have spent the last four months hard at work on this release. We hope you enjoy using Plasma as much as we enjoyed making it!")

    topContent: [
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing

            visible: root.isPrerelease
            text: i18nc("@label:URL", "Report a bug")
            url: "https://bugs.kde.org"
        }
    ]

    Component.onCompleted: {
        if (Private.Config.automaticUpdatePreview) {
            Private.Release.tryAutomaticPreview();
        }
    }

    ColumnLayout {
        anchors.fill: parent

        spacing: Kirigami.Units.gridUnit

        Private.MockCard {
            id: card
            Layout.fillWidth: true
            Layout.fillHeight: true

            // The initial state will not animate in, so we have a placeholder
            // initial state to ensure the subsequent state will animate in
            property bool ready: false
            Component.onCompleted: ready = true

            states: [
                State {
                    name: "None"
                    when: !card.ready
                },
                State {
                    name: "Unloaded"
                    when: Private.Release.previewStatus === Private.Release.Unloaded
                },
                State {
                    name: "Loading"
                    when: Private.Release.previewStatus === Private.Release.Loading
                },
                State {
                    name: "Loaded"
                    when: Private.Release.previewStatus === Private.Release.Loaded
                }
            ]

            focusPolicy: card.state === "Loaded" ? Qt.TabFocus : Qt.NoFocus
            showClickFeedback: card.state === "Loaded"
            hoverEnabled: card.state === "Loaded"

            onClicked: {
                if (card.state === "Loaded") {
                    Qt.openUrlExternally(Private.Release.announcementUrl);
                }
            }

            applyPlasmaColors: false
            backgroundAlignment: Qt.AlignHCenter | Qt.AlignVCenter
            blurRadius: 64

            Rectangle {
                anchors.fill: parent

                opacity: 0.7 // Same as overview underlay
                color: {
                    // Tint values taken from kirigamiaddons.formcard's FormDelegateBackground
                    let tintFactor;
                    if (card.showClickFeedback && card.pressed) {
                        tintFactor = 0.2;
                    } else if (card.visualFocus) {
                        tintFactor = 0.1;
                    } else if (card.hoverEnabled && !Kirigami.Settings.tabletMode && card.hovered) {
                        tintFactor = 0.07;
                    } else {
                        tintFactor = 0;
                    }

                    // Tint multiplied by 1/opacity to account for loss in intensity due to opacity
                    return Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor,
                                                             Kirigami.Theme.highlightColor,
                                                             tintFactor * (1 / opacity));
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Kirigami.Units.shortDuration
                    }
                }
            }

            Item {
                id: releasePreviewUnloaded
                anchors.centerIn: parent

                width: Math.min(parent.width - (Kirigami.Units.gridUnit * 2), Kirigami.Units.gridUnit * 24)
                height: parent.height - (Kirigami.Units.gridUnit * 2)

                opacity: card.state === "Unloaded" ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    PropertyAnimation {
                        easing.type: Easing.InOutQuad
                        duration: Kirigami.Units.longDuration
                    }
                }

                ColumnLayout {
                    anchors.fill: parent

                    spacing: 0

                    Item {
                        Layout.fillHeight: true
                    }

                    QQC2.Label {
                        Layout.fillWidth: true
                        Layout.bottomMargin: Kirigami.Units.gridUnit

                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        text: switch (Private.Release.previewError) {
                            case Private.Release.None:
                            default:
                                return i18nc("@info", "Download an embedded preview of the release announcement?");
                            case Private.Release.Metered:
                                return i18nc("@info", "The preview has not been automatically downloaded because you are using a metered network connection.");
                            case Private.Release.NetworkCode:
                                return i18nc("@info, %1 is an error code", "The preview could not be downloaded — a network error occurred (%1).").arg(Private.Release.previewErrorCode);
                            case Private.Release.ParseFailure:
                                return i18nc("@info", "The preview could not be loaded — a parse error occurred.");
                        }
                    }

                    QQC2.Button {
                        Layout.alignment: Qt.AlignHCenter

                        enabled: !releasePreviewUnloadedRetryTimer.running

                        Timer {
                            id: releasePreviewUnloadedRetryTimer
                            interval: Kirigami.Units.humanMoment
                        }

                        text: switch (Private.Release.previewError) {
                            case Private.Release.None:
                            default:
                                return i18nc("@action:button", "Download Preview");
                            case Private.Release.Metered:
                                return i18nc("@action:button", "Download Anyway");
                            case Private.Release.NetworkCode:
                                return i18nc("@action:button", "Retry");
                            case Private.Release.ParseFailure:
                                return i18nc("@action:button", "Open in Browser…");
                        }

                        icon.name: switch (Private.Release.previewError) {
                            case Private.Release.None:
                            case Private.Release.Metered:
                            default:
                                return "download-symbolic";
                            case Private.Release.NetworkCode:
                                return "view-refresh-symbolic";
                            case Private.Release.ParseFailure:
                                return "open-link-symbolic";
                        }

                        onClicked: switch (Private.Release.previewError) {
                            case Private.Release.None:
                            case Private.Release.Metered:
                            default:
                                Private.Release.getPreview();
                                break;
                            case Private.Release.NetworkCode:
                                Private.Release.getPreview();
                                releasePreviewUnloadedRetryTimer.start();
                                break;
                            case Private.Release.ParseFailure:
                                Qt.openUrlExternally(Private.Release.announcementUrl);
                                break;
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {

                        spacing: 0

                        Item {
                            Layout.fillWidth: true
                            Layout.horizontalStretchFactor: 1
                        }

                        QQC2.Switch {
                            Layout.fillWidth: true // Will only shrink, not grow, due to surrounding stretch factor items

                            text: i18nc("@option:check", "Load preview automatically")
                            checked: Private.Config.automaticUpdatePreview
                            onToggled: { Private.Config.automaticUpdatePreview = checked; Private.Config.save() }
                        }

                        Kirigami.ContextualHelpButton {
                            Layout.leftMargin: Kirigami.Units.smallSpacing

                            toolTipText: i18nc("@info:tooltip", "The preview will be loaded automatically when this page is shown for future Plasma updates, except when using a metered network connection.")
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.horizontalStretchFactor: 1
                        }
                    }
                }
            }

            Kirigami.LoadingPlaceholder {
                id: releasePreviewLoading
                anchors.centerIn: parent

                Timer {
                    id: releasePreviewLoadingTimer

                    interval: Kirigami.Units.humanMoment
                    running: card.state === "Loading"
                }

                opacity: (card.state === "Loading" && !releasePreviewLoadingTimer.running) ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    PropertyAnimation {
                        easing.type: Easing.InOutQuad
                        duration: Kirigami.Units.longDuration
                    }
                }
            }

            Item {
                id: releasePreview
                anchors.fill: parent
                anchors.margins: Kirigami.Units.gridUnit

                opacity: card.state === "Loaded" ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    PropertyAnimation {
                        easing.type: Easing.InOutQuad
                        duration: Kirigami.Units.longDuration
                    }
                }

                RowLayout {
                    anchors.fill: parent

                    spacing: Kirigami.Units.gridUnit

                    Item {
                        Layout.fillWidth: true
                    }

                    Item {
                        id: releasePreviewIconContainer
                        Layout.alignment: Qt.AlignCenter
                        Layout.preferredWidth: implicitWidth

                        // Only show if using no more than a quarter of the available width
                        readonly property bool show: {
                            if (!releasePreview.visible) {
                                return false;
                            }
                            if (releasePreview.width < 0) {
                                // Initially, it'll be negative
                                return true;
                            }
                            return Kirigami.Units.iconSizes.enormous <= (releasePreview.width / 4);
                        }

                        implicitWidth: show ? Kirigami.Units.iconSizes.enormous : 0
                        implicitHeight: Kirigami.Units.iconSizes.enormous
                        opacity: show ? 1 : 0
                        visible: opacity > 0

                        Behavior on implicitWidth {
                            PropertyAnimation {
                                easing.type: Easing.InOutQuad
                                duration: Kirigami.Units.longDuration
                            }
                        }

                        Behavior on opacity {
                            PropertyAnimation {
                                easing.type: Easing.InOutQuad
                                duration: Kirigami.Units.longDuration
                            }
                        }

                        Kirigami.Icon {
                            anchors.verticalCenter: releasePreviewIconContainer.verticalCenter
                            anchors.right: releasePreviewIconContainer.right

                            implicitWidth: Kirigami.Units.iconSizes.enormous
                            implicitHeight: Kirigami.Units.iconSizes.enormous
                            source: "start-here-kde-plasma"
                        }

                        Kirigami.Icon {
                            id: releasePreviewGearIcon

                            visible: root.isPrerelease

                            anchors.horizontalCenter: releasePreviewIconContainer.right
                            anchors.verticalCenter: releasePreviewIconContainer.bottom
                            anchors.horizontalCenterOffset: -width / 4
                            anchors.verticalCenterOffset: -height / 4

                            width: Kirigami.Units.iconSizes.huge
                            height: Kirigami.Units.iconSizes.huge

                            source: "process-working-symbolic"

                            TapHandler {
                                onTapped: releasePreviewGearSpin.start()
                            }

                            RotationAnimation {
                                id: releasePreviewGearSpin

                                target: releasePreviewGearIcon
                                from: 0
                                to: 180
                                duration: 800
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    ColumnLayout {
                        id: releasePreviewTextLayout

                        Layout.alignment: Qt.AlignCenter
                        Layout.fillHeight: true
                        Layout.maximumWidth: Kirigami.Units.gridUnit * 24

                        Kirigami.Heading {
                            id: title
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillWidth: true

                            level: 1
                            maximumLineCount: 1
                            elide: Text.ElideRight
                            text: Private.Release.previewTitle
                        }

                        Kirigami.Heading {
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillWidth: true
                            Layout.maximumHeight: releasePreviewIconContainer.height - parent.spacing - title.height

                            level: 2
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            text: Private.Release.previewDescription
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                QQC2.Label {
                    id: releasePreviewHint
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter

                    // Only show if there's a grid unit between it and the text
                    readonly property bool show: {
                        if (!releasePreview.visible) {
                            return false;
                        }
                        if (releasePreview.height < 0) {
                            // Initially, it'll be negative
                            return true;
                        }
                        return (releasePreviewTextLayout.y + releasePreviewTextLayout.height) <= (releasePreview.height - Kirigami.Units.gridUnit - height);
                    }

                    text: i18nc("@info", "<b>Click to read the announcement</b>")

                    anchors.bottomMargin: show ? 0 : (height + Kirigami.Units.gridUnit * 2) * -1
                    opacity: show ? 0.6 : 0
                    visible: opacity > 0

                    Behavior on anchors.bottomMargin {
                        PropertyAnimation {
                            easing.type: Easing.InOutQuad
                            duration: Kirigami.Units.longDuration
                        }
                    }

                    Behavior on opacity {
                        PropertyAnimation {
                            easing.type: Easing.InOutQuad
                            duration: Kirigami.Units.longDuration
                        }
                    }
                }
            }
        }

        Private.ContributionCard {
            Layout.fillWidth: true
        }
    }
}
