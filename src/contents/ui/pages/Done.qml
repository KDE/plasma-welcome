import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

import org.kde.welcome 1.0

Kirigami.Page {
    title: i18n("All Done")

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width - (Kirigami.Units.gridUnit * 4)

        Kirigami.Heading {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: i18n("You're ready to start using your Plasma Desktop.")
            wrapMode: Text.WordWrap
            type: Kirigami.Heading.Primary
        }
    }
}
