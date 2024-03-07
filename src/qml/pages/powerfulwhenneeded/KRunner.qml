/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome

GenericPage {
    heading: i18nc("@info:window", "KRunner")

    // Don't change the weird indentation; it's intentional to make this
    // long string nicer for translators
    description: xi18nc("@info:usagetip translators: In the example queries, make sure to use the keywords as they are localized in the actual runner plugins. If needed, change 'Shanghai' to a city that on the other side of the world from likely speakers of the language", "KRunner is Plasma's exceptionally powerful and versatile search system. It powers the search functionality in the Application Launcher menu and the Overview screen, and it can be accessed as a standalone search bar using the <shortcut>Alt+Space</shortcut> keyboard shortcut.<nl/><nl/>In addition to finding your files and folders, KRunner can launch apps, search the web, convert between currencies, calculate math problems, and a lot more. Try typing any of the following into one of those search fields:\
<nl/>\
<list><item>\"time Shanghai\"</item>\
<item>\"27/3\"</item>\
<item>\"200 EUR in USD\"</item>\
<item>\"25 miles in km\"</item>\
<item>…And much more!</item></list>\
<nl/>\
To learn more, open the KRunner search bar using the <shortcut>Alt+Space</shortcut> keyboard shortcut and click on the question mark icon.")
}
