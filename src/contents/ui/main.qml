import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

import org.kde.welcome 1.0

Kirigami.ApplicationWindow {
    id: root

    title: i18n("Plasma Tour")

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

    header: QQC2.ToolBar {
        Layout.fillWidth: true
        Layout.preferredHeight: pageStack.globalToolBar.preferredHeight

        leftPadding: Kirigami.Units.smallSpacing
        rightPadding: Kirigami.Units.smallSpacing
        topPadding: 0
        bottomPadding: 0

        RowLayout {
            anchors.fill: parent

            Kirigami.Heading {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
                text: swipeView.currentItem.title
            }
        }
    }

    pageStack.initialPage: QQC2.SwipeView {
        id: swipeView

        Welcome {}
        Plasma {}
        Kickoff {}
        SystemTray {}
        Discover {}
        Apps {}
        SystemSettings {}
        Contribute {}
        Done {}

        onCurrentIndexChanged: {
            if (currentIndex == count - 1) {
                Config.done = true;
                Config.save();
            }
        }
    }
}
