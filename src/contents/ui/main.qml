import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

import org.kde.welcome 1.0

Kirigami.ApplicationWindow {
    id: root

    title: i18n("Plasma Welcome")

    minimumWidth: Kirigami.Units.gridUnit * 25
    minimumHeight: Kirigami.Units.gridUnit * 20
    width: Kirigami.Units.gridUnit * 50
    height: Kirigami.Units.gridUnit * 40
    //maximumWidth: Kirigami.Units.gridUnit * 50
    //maximumHeight: Kirigami.Units.gridUnit * 40

    QQC2.RoundButton {
        visible: swipeView.currentIndex > 0
        anchors {
            left: parent.left
            leftMargin: Kirigami.Units.largeSpacing
            verticalCenter: parent.verticalCenter
        }
        width: Kirigami.Units.gridUnit * 2
        height: width
        action: Kirigami.Action {
            icon.name: "arrow-left"
            shortcut: "Left"
            onTriggered: {
                if (swipeView.currentIndex != 0) {
                    swipeView.currentIndex -= 1
                }
            }
        }
    }

    QQC2.RoundButton {
        visible: swipeView.currentIndex != swipeView.count - 1
        anchors {
            right: parent.right
            rightMargin: Kirigami.Units.largeSpacing
            verticalCenter: parent.verticalCenter
        }
        width: Kirigami.Units.gridUnit * 2
        height: width
        action: Kirigami.Action {
            icon.name: "arrow-right"
            shortcut: "Right"
            onTriggered: {
                if (swipeView.currentIndex < swipeView.count - 1) {
                    swipeView.currentIndex += 1
                }
            }
        }
    }

    pageStack.initialPage: Kirigami.Page {
        title: swipeView.currentItem.title

        QQC2.SwipeView {
            id: swipeView
            anchors.fill: parent

            Welcome {}
            Discover {}
            SystemSettings {}
            Contribute {}

            onCurrentIndexChanged: {
                if (currentIndex == count - 1) {
                    Config.done = true;
                    Config.save();
                    Controller.removeFromAutostart();
                }
            }
        }
        footer: ColumnLayout {
            QQC2.PageIndicator {
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: Kirigami.Units.largeSpacing

                currentIndex: swipeView.currentIndex
                count: swipeView.count
                interactive: true
                onCurrentIndexChanged: swipeView.currentIndex = currentIndex
            }
        }
    }
}
