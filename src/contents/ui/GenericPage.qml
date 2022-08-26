import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15

Kirigami.Page {
    id: page

    required property string heading
    required property string description
    property alias topContent: layout.children

    leftPadding: Kirigami.Units.gridUnit * 3
    rightPadding: Kirigami.Units.gridUnit * 3

    ColumnLayout {
        id: layout
        width: parent.width - (Kirigami.Units.gridUnit * 4)
        Kirigami.Heading {
            Layout.fillWidth: true
            text: page.heading
            wrapMode: Text.WordWrap
            type: Kirigami.Heading.Primary
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: page.description
            wrapMode: Text.WordWrap
        }
    }
}
