/*
 *   SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
 *   SPDX-FileCopyrightText: 2022 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

import org.kde.plasma.welcome 1.0

GenericPage
{
    id: container

    required property string path

    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    flickable: module.kcm.mainUi.flickable
    actions: module.kcm.mainUi.actions

    onActiveFocusChanged: {
        if (activeFocus) {
            module.kcm.mainUi.forceActiveFocus();
        }
    }

    Component.onCompleted: {
        module.kcm.load()
        module.kcm.mainUi.parent = contentItem;
        module.kcm.mainUi.anchors.fill = contentItem;
        module.kcm.mainUi.extraFooterTopPadding = false;
    }

    data: [
        Connections {
            target: module.kcm
            function onPagePushed(page) {
                pageStack.layers.push(page);
                page.extraFooterTopPadding = false;
            }
            function onPageRemoved() {
                pageStack.layers.pop(); //PROBABLY THIS SHOULDN't BE SUPPORTED
            }
            function onNeedsSaveChanged () {
                if (module.kcm.needsSave) {
                    module.kcm.save()
                }
            }
        },
        Connections {
            target: pageStack
            function onPageRemoved(page) {
                if (module.kcm.needsSave) {
                    module.kcm.save()
                }
                if (page == container) {
                    page.destroy();
                }
            }
        },
        Connections {
            target: module.kcm
            function onCurrentIndexChanged(index) {return;
                const index_with_offset = index + 1;
                if (index_with_offset !== pageStack.currentIndex) {
                    pageStack.currentIndex = index_with_offset;
                }
            }
        }
    ]

    Kirigami.Separator {
        width: parent.width
        anchors.bottom: parent.top
    }

    Module {
        id: module
        path: container.path
    }
}
