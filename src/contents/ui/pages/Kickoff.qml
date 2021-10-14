import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

Kirigami.Page {
    title: i18n("Knowing your Desktop")

    ColumnLayout {
        width: parent.width - (Kirigami.Units.gridUnit * 4)
        Kirigami.Heading {
            Layout.fillWidth: true
            text: i18n("Application Launcher")
            wrapMode: Text.WordWrap
            type: Kirigami.Heading.Primary
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("The Plasma Launcher lets you quickly and easily launch applications, but it can do much more – convenient tasks like bookmarking applications, searching for documents as you type, or navigating to common places help you getting straight to the point. With a history of recently started programs and opened files, you can return to where you left off. It even remembers previously entered search terms so you don’t have to.")
            wrapMode: Text.WordWrap
        }
    }

    Image {
        id: image
        anchors.fill: parent
        anchors.topMargin: Kirigami.Units.gridUnit * 7
        fillMode: Image.PreserveAspectFit
        source: "kickoff.webp"
    }
}
