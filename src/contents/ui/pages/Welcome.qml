import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

import org.kde.welcome 1.0

Kirigami.Page {
    title: i18n("Welcome")

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width - (Kirigami.Units.gridUnit * 4)

        Kirigami.Heading {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: i18n("Welcome to Plasma")
            wrapMode: Text.WordWrap
            type: Kirigami.Heading.Primary
        }

        RowLayout {
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: Kirigami.Units.largeSpacing
            QQC2.Button {
                text: i18n("Skip")
                onClicked: {
                    Config.skip = true;
                    Config.save();
                    Qt.quit();
                }
            }

            QQC2.Button {
                text: i18n("Take Tour")
                onClicked: swipeView.currentIndex += 1
            }
        }
    }
}
