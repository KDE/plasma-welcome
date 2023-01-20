<!--
    SPDX-License-Identifier: CC0-1.0
    SPDX-FileCopyrightText: 2022-Nate Graham <nate@kde.org>
-->
# Plasma Welcome App

A Friendly onboarding wizard for Plasma

Welcome Center is the perfect introduction to KDE Plasma! It can help you learn how to connect to the internet, install apps, customize the system, and more!

There are two usage modes:
- Run the app normally and it will show a welcome/onboarding wizard.
- Run the app with the `--after-upgrade-to` argument to show a post-upgrade message. For example: `plasma-welcome --after-upgrade-to 5.25`.


## Screenshots
![First page](https://cdn.kde.org/screenshots/plasma-welcome/plasma-welcome-page-1.png)

![Second page](https://cdn.kde.org/screenshots/plasma-welcome/plasma-welcome-page-2.png)

![Sixth page](https://cdn.kde.org/screenshots/plasma-welcome/plasma-welcome-page-6.png)


# Extending Welcome Center with custom pages
Custom distro-specific pages can be embedded in the app, and will appear right before the "Get Involved" page. Only content that is safely skippable should be added, since the user can close the app at any time, potentially before they see your custom pages.

To make custom pages visible to the app, place them in `/usr/share/plasma-welcome-extra-pages/`, prefixed with a number and a dash. For example if you define two pages with the following names:

- 01-WelcomeToDistro.qml
- 02-InstallMediaCodecs.qml

These two pages will be added into the wizard, with WelcomeToDistro shown first, and then InstallMediaCodecs.

Custom pages are QML files with a root item that inherits from Kirigami.Page. Any content within the page is supported, though to maintain visual consistency with existing pages, it is recommended to use `GenericPage` or `KCM` as the root item and set the `heading` and `description` properties, with any custom content going beneath them.

Because pages are written in QML without support for C++ support code, only functions that can be performed entirely with QML are available. Here are some examples:

## Open a URL in the default web browser
Example:
```
Kirigami.Icon {
    source: "media-default-track"
    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: Qt.openUrlExternally("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    }
}
```

## Open an external app
```
Kirigami.Icon {
    source: "document-open-folder"
    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: Controller.launchApp("org.kde.dolphin")
    }
}
```

## Run a terminal command
```
Kirigami.Icon {
    source: "notification"
    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: Controller.runCommand("notify-send foo bar")
    }
}
```

## Embed a KCM in the page
Example:
```
KCM {
    heading: i18nc("@title: window", "Learn about Activities")
    description: i18nc("@info:usagetip", "Activities can be used to separate high-level projects or tasks so you can focus on one at a time. You can set them up in System Settings, and also right here.")

    Module {
        id: moduleActivities
        path: "kcm_activities"
    }
    kcm: moduleActivities.kcm
    internalPage: moduleActivities.kcm.mainUi
    }
```


If you find that your specific use case can't be supported with these tools, please file a bug report at https://bugs.kde.org/enter_bug.cgi?product=Welcome%20Center detailing the use case and what would be needed to support it.

## Example custom page

Name this file `01-NateOS.qml` and place it in `/usr/share/plasma-welcome-extra-pages/`:

```
/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15

import org.kde.welcome 1.0
import org.kde.plasma.welcome 1.0

GenericPage {
    heading: i18nc("@info:window", "Welcome to NateOS")
    description: i18nc("@info:usagetip", "It's the best distro in the world, until it explodes.")

    Kirigami.Icon {
        id: image
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Kirigami.Units.gridUnit * 4
        width: Kirigami.Units.gridUnit * 10
        height: Kirigami.Units.gridUnit * 10
        source: "granatier"

        HoverHandler {
            id: hoverhandler
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: showPassiveNotification(i18n("Why on earth would you click this!?"));
        }

        QQC2.ToolTip {
            visible: hoverhandler.hovered
            text: i18nc("@action:button", "Detonating the bomb in 3... 2... 1...")
        }

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 1
            radius: 20
            samples: 20
            color: Qt.rgba(0, 0, 0, 0.2)
        }
    }

    Kirigami.Heading {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: image.bottom
        text: i18nc("@title the name of the 'System Exploder' app", "Someone set up us the bomb")
        wrapMode: Text.WordWrap
        level: 3
    }
}
```
