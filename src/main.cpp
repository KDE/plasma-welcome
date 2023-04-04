/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <QApplication>
#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QSurfaceFormat>
#include <QUrl>
#include <QtQml>

#include "applicationInfo.h"
#include "config.h"
#include "controller.h"
#include "plasma-welcome-version.h"

#include "module.h"
#include <KAboutData>
#include <KDBusService>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <KWindowSystem>

int main(int argc, char *argv[])
{
    auto format = QSurfaceFormat::defaultFormat();
    format.setOption(QSurfaceFormat::ResetNotification);
    QSurfaceFormat::setDefaultFormat(format);

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("KDE"));
    QCoreApplication::setApplicationName(QStringLiteral("plasma-welcome"));
    KLocalizedString::setApplicationDomain("plasma-welcome");

    const QString description = i18nc("@info:usagetip", "A welcome app for KDE Plasma");
    KAboutData aboutData(
        // The program name used internally.
        QStringLiteral("plasma-welcome"),
        // A displayable program name string.
        i18nc("@title", "Welcome Center"),
        // The program version string.
        QStringLiteral(PLASMA_WELCOME_VERSION_STRING),
        // Short description of what the app does.
        description,
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

    qmlRegisterSingletonInstance("org.kde.plasma.welcome", 1, 0, "Config", Config::self());
    Controller controller;
    qmlRegisterSingletonInstance("org.kde.plasma.welcome", 1, 0, "Controller", &controller);
    qmlRegisterType<Module>("org.kde.plasma.welcome", 1, 0, "Module");
    qmlRegisterType<ApplicationInfo>("org.kde.plasma.welcome", 1, 0, "ApplicationInfo");

    // Parse CLI args
    QCommandLineParser parser;
    parser.setApplicationDescription(description);
    aboutData.setupCommandLine(&parser);
    parser.addOption(QCommandLineOption(QStringLiteral("post-update"), i18n("Display release notes for the current Plasma release.")));

    parser.process(app);
    aboutData.processCommandLine(&parser);
    if (parser.isSet(QStringLiteral("post-update"))) {
        controller.setMode(Controller::Mode::Update);
    }

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    // Make it single-instance so it raises e.g. when middle-clicking on taskmanager
    // or accidentally launching it while it's already open
    KDBusService service(KDBusService::Unique);
    QObject::connect(&service, &KDBusService::activateRequested, &engine, [&engine](const QStringList & /*arguments*/, const QString & /*workingDirectory*/) {
        const auto rootObjects = engine.rootObjects();
        for (auto obj : rootObjects) {
            auto view = qobject_cast<QQuickWindow *>(obj);
            if (view) {
                KWindowSystem::updateStartupId(view);
                KWindowSystem::activateWindow(view);
                return;
            }
        }
    });

    return app.exec();
}
