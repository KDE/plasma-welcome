import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

import org.kde.welcome 1.0

Kirigami.ApplicationWindow {
    id: root

    title: i18n("Welcome")

    minimumWidth: Kirigami.Units.gridUnit * 25
    minimumHeight: Kirigami.Units.gridUnit * 20
    width: Kirigami.Units.gridUnit * 50
    height: Kirigami.Units.gridUnit * 40
    //maximumWidth: Kirigami.Units.gridUnit * 50
    //maximumHeight: Kirigami.Units.gridUnit * 40

    pageStack.defaultColumnWidth: Kirigami.Units.gridUnit * 40
    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.NoNavigationButtons

    Loader {
        active: !Kirigami.Settings.isMobile
        source: Qt.resolvedUrl("GlobalMenu.qml")
    }

    QQC2.RoundButton {
        visible: swipeView.currentIndex > 0
        anchors {
            left: parent.left
            leftMargin: Kirigami.Units.largeSpacing
            verticalCenter: parent.verticalCenter
        }
        width: Kirigami.Units.gridUnit * 2
        height: width
        icon.name: "arrow-left"
        Keys.forwardTo: [root]
        onClicked: swipeView.currentIndex -= 1
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
        radius: width / 2
        icon.name: "arrow-right"
        onClicked: swipeView.currentIndex += 1
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

        Discover {}
        Apps {}
        SystemSettings {}
        Done {}
    }
}
