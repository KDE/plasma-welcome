import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import Qt.labs.platform 1.1 as Labs

Labs.MenuBar {
    id: menubar

    Labs.Menu {
        title: i18nc("@action:menu", "File")

        Labs.MenuItem {
            text: i18nc("@action:menu", "Quit")
            icon.name: "application-exit"
            shortcut: StandardKey.Quit
            onTriggered: Qt.quit()
        }
    }

    Labs.Menu {
        title: i18nc("@action:menu", "Help")

        Labs.MenuItem {
            text: i18nc("@action:menu", "About Hello")
            icon.name: "help-about"
            onTriggered: pageStack.layers.push("AboutPage.qml")
            enabled: pageStack.layers.currentItem.objectName != "aboutPage"
        }
    }
}
