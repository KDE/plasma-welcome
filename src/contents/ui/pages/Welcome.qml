import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

import org.kde.welcome 1.0

Kirigami.ScrollablePage {
    title: i18n("Introduction")

    ColumnLayout {
        Image {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 16
            source: "konqi-kde-hi.png"
            fillMode: Image.PreserveAspectFit
        }
        QQC2.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: i18n("Welcome to KDE Plasma")
            font.pixelSize: 25
        }
        RowLayout {
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: Kirigami.Units.largeSpacing
            QQC2.Button {
                text: i18n("Skip")
                onClicked: {
                    Config.skip = true;
                    Config.save();
                    Controller.removeFromAutostart();
                    Qt.quit();
                }
            }

            QQC2.Button {
                text: i18n("Start")
                onClicked: swipeView.currentIndex += 1
            }
        }
    }
}
