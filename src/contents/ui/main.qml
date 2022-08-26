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

import org.kde.welcome 1.0

Kirigami.ApplicationWindow {
    id: root

    minimumWidth: Kirigami.Units.gridUnit * 40
    minimumHeight: Kirigami.Units.gridUnit * 35
    width: Kirigami.Units.gridUnit * 42
    height: Kirigami.Units.gridUnit * 37

    header: QQC2.ToolBar {
        contentItem: RowLayout {
            QQC2.Button {
                Layout.alignment: Qt.AlignLeft
                action: Kirigami.Action {
                    text: swipeView.currentIndex === 0 ? i18nc("@action:button", "Skip") : i18nc("@action:button", "Back")
                    icon.name: swipeView.currentIndex === 0 ? "" : "arrow-left"
                    shortcut: "Left"
                    onTriggered: {
                        if (swipeView.currentIndex != 0) {
                            swipeView.currentIndex -= 1
                        } else {
                            Config.skip = true;
                            Config.save();
                            Controller.removeFromAutostart();
                            Qt.quit();
                        }
                    }
                }
            }
            QQC2.Button {
                Layout.alignment: Qt.AlignRight
                action: Kirigami.Action {
                    text: swipeView.currentIndex === swipeView.count - 1 ? i18nc("@action:button", "Finish") : i18nc("@action:button", "Next")
                    icon.name: swipeView.currentIndex === swipeView.count - 1 ? "" : "arrow-right"
                    shortcut: "Right"
                    onTriggered: {
                        if (swipeView.currentIndex < swipeView.count - 1) {
                            swipeView.currentIndex += 1
                        } else {
                            Config.done = true;
                            Config.save();
                            Controller.removeFromAutostart();
                            Qt.quit()
                        }
                    }
                }
            }
        }
    }

    QQC2.SwipeView {
        id: swipeView
        anchors.fill: parent

        Welcome {}
        Discover {}
        SystemSettings {}
        Contribute {}
    }
}
