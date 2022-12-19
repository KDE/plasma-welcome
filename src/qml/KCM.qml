/*
 *   SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
 *   SPDX-FileCopyrightText: 2022 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

import org.kde.plasma.welcome 1.0

GenericPage
{
    id: container
    property QtObject kcm
    property Item internalPage
    property bool showSeparator: false

    title: internalPage.title

    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    flickable: internalPage.flickable
    actions.main: internalPage.actions.main
    actions.contextualActions: internalPage.contextualActions

    onInternalPageChanged: {
        internalPage.parent = contentItem;
        internalPage.anchors.fill = contentItem;
    }
    onActiveFocusChanged: {
        if (activeFocus) {
            internalPage.forceActiveFocus();
        }
    }

    Component.onCompleted: {
        kcm.load()
    }

    data: [
        Connections {
            target: kcm
            function onPagePushed(page) {
                pageStack.layers.push(page);
            }
            function onPageRemoved() {
                pageStack.layers.pop(); //PROBABLY THIS SHOULDN't BE SUPPORTED
            }
            function onNeedsSaveChanged () {
                if (kcm.needsSave) {
                    kcm.save()
                }
            }
        },
        Connections {
            target: pageStack
            function onPageRemoved(page) {
                if (kcm.needsSave) {
                    kcm.save()
                }
                if (page == container) {
                    page.destroy();
                }
            }
        },
        Connections {
            target: kcm
            function onCurrentIndexChanged(index) {return;
                const index_with_offset = index + 1;
                if (index_with_offset !== pageStack.currentIndex) {
                    pageStack.currentIndex = index_with_offset;
                }
            }
        }
    ]
    Kirigami.Separator {
        visible: container.showSeparator
        width: parent.width
        anchors.bottom: parent.top
    }
}
