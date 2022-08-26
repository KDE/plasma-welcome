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
    //maximumWidth: Kirigami.Units.gridUnit * 50
    //maximumHeight: Kirigami.Units.gridUnit * 40

    header: QQC2.ToolBar {
        RowLayout {
            anchors.fill: parent
            QQC2.Button {
                Layout.alignment: Qt.AlignLeft
                action: Kirigami.Action {
                    text: swipeView.currentIndex === 0 ? i18n("Skip") : i18n("Back")
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
                    text: swipeView.currentIndex === swipeView.count - 1 ? i18n("Finish") : i18n("Next")
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
