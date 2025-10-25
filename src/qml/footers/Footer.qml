/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

QQC2.ToolBar {
    id: footer

    required property string contentSource

    // Even though a normal footer wouldn't be styled like the header, it seems
    // like the right thing to do here to help frame the whole application.
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Header

    position: QQC2.ToolBar.Footer

    contentItem: Loader {
        source: footer.contentSource
    }
}
