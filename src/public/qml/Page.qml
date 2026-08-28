/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: page

    required property string heading
    required property string description

    // This property can overridden to conditionally hide the page
    property bool show: true

    property alias topContent: topContentLayout.children

    Component {
        id: globalToolBarMenuSeparator

        Kirigami.Separator {
            Layout.fillHeight: true
        }
    }

    // HACK: Insert a separator action before the GlobalDrawer's
    //       handle button, when the actionToolBar has content.
    actions: [
        Kirigami.Action {
            displayComponent: Item {
                width: 0
                height: 0

                Component.onCompleted: {
                    const actionToolBar = parent.parent;
                    const rowLayout = actionToolBar.parent;

                    if (!(actionToolBar instanceof Kirigami.ActionToolBar)
                        || !(rowLayout instanceof RowLayout)) {
                        return;
                    }

                    // Detatch the last item so our separator is in the right place
                    const lastItem = rowLayout.children[rowLayout.children.length - 1];
                    lastItem.parent = null;

                    // Add the separator
                    const separator = globalToolBarMenuSeparator.createObject(rowLayout);
                    separator.visible = Qt.binding(() => actionToolBar.visibleWidth > 0);

                    // And add it back
                    lastItem.parent = rowLayout;
                }
            }
        }
    ]

    title: heading
    topPadding: 0 // Provided by required header

    header: Item {
        height: layout.implicitHeight + (page.padding * 2)

        ColumnLayout {
            id: layout
            width: parent.width - (page.padding * 2)
            anchors.centerIn: parent

            QQC2.Label {
                focusPolicy: Qt.StrongFocus
                Layout.fillWidth: true
                text: page.description
                wrapMode: Text.WordWrap
            }

            ColumnLayout {
                id: topContentLayout
                visible: children.length > 0
            }
        }
    }
}
