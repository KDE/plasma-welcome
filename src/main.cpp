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

#include "controller.h"
#include "plasma-welcome-version.h"

#include <KAboutData>
#include <KDBusService>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <KWindowSystem>
#include "about.h"
#include "module.h"

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
        i18nc("@title", "Welcome to KDE Plasma"),
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

    qmlRegisterSingletonInstance("org.kde.welcome", 1, 0, "AboutType", new AboutType);
    Controller controller;
    qmlRegisterSingletonInstance("org.kde.welcome", 1, 0, "Controller", &controller);
    qmlRegisterType<Module>("org.kde.welcome", 1, 0, "Module");

    // Parse CLI args
    QCommandLineParser parser;
    parser.setApplicationDescription(description);
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addOption(QCommandLineOption(QStringLiteral("after-upgrade-to"),
                                        i18n("Version number of the Plasma release to display release notes for, e.g. 5.25"),
                                        QStringLiteral("version number")));
    parser.process(app);
    QString versionNumber;
    if (parser.isSet(QStringLiteral("after-upgrade-to"))) {
        versionNumber = parser.value(QStringLiteral("after-upgrade-to"));
        controller.setPlasmaUpgradeVersion(versionNumber);
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
