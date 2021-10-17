import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15

GenericPage {
    title: i18n("Knowing your Desktop")

    heading: i18n("Application Launcher")
    description: i18n("The Plasma Launcher lets you quickly and easily launch applications, but it can do much more – convenient tasks like bookmarking applications, searching for documents as you type, or navigating to common places help you getting straight to the point. With a history of recently started programs and opened files, you can return to where you left off. It even remembers previously entered search terms so you don’t have to.")

    Image {
        id: image
        anchors.centerIn: parent
        height: Kirigami.Units.gridUnit * 22
        source: "kickoff.webp"
        fillMode: Image.PreserveAspectFit
    }

    DropShadow {
        anchors.fill: image
        source: image
        horizontalOffset: 0
        verticalOffset: 5
        radius: 20
        samples: 20
        color: Qt.rgba(0, 0, 0, 0.25)
    }
}
