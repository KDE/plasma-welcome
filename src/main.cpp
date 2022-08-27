/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QtQml>

#include "controller.h"

#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>
#include "about.h"
#include "module.h"
#include "config-welcome.h"

#include "welcomeconfig.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("KDE"));
    QCoreApplication::setApplicationName(QStringLiteral("welcomecenter"));

    KAboutData aboutData(
                         // The program name used internally.
                         QStringLiteral("welcomecenter"),
                         // A displayable program name string.
                         i18nc("@title", "Welcome to KDE Plasma"),
                         // The program version string.
                         QStringLiteral(WELCOME_VERSION_STRING),
                         // Short description of what the app does.
                            i18nc("@info:usagetip", "A welcome app for KDE Plasma"),
                         // The license this code is released under.
                         KAboutLicense::GPL,
                         // Copyright Statement.
                         i18nc("@info copyright string", "(c) 2021"));
    aboutData.addAuthor(i18nc("@info:credit", "Felipe Kinoshita"),
                        i18nc("@info:credit", "Author"),
                        QStringLiteral("kinofhek@gmail.com"),
                        QStringLiteral("https://fhek.gitlab.io.com"));
    aboutData.addAuthor(i18nc("@info:credit", "Nate Graham"),
                        i18nc("@info:credit", "Author"),
                        QStringLiteral("nate@kde.org"),
                        QStringLiteral("https://pointieststick.com"));
    KAboutData::setApplicationData(aboutData);

    QQmlApplicationEngine engine;

    auto config = WelcomeConfig::self();
    qmlRegisterSingletonInstance("org.kde.welcome", 1, 0, "Config", config);

    qmlRegisterSingletonInstance("org.kde.welcome", 1, 0, "AboutType", new AboutType);
    qmlRegisterSingletonInstance("org.kde.welcome", 1, 0, "Controller", new Controller);
    qmlRegisterType<Module>("org.kde.welcome", 1, 0, "Module");

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
