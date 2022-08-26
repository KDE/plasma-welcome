#include <QApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QtQml>

#include "controller.h"

#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>
#include "about.h"
#include "config-welcome.h"

#include "welcomeconfig.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("KDE"));
    QCoreApplication::setApplicationName(QStringLiteral("welcome"));

    KAboutData aboutData(
                         // The program name used internally.
                         QStringLiteral("welcome"),
                         // A displayable program name string.
                         i18nc("@title", "Welcome to KDE Plasma"),
                         // The program version string.
                         QStringLiteral(WELCOME_VERSION_STRING),
                         // Short description of what the app does.
                         i18n("A welcome app to Plasma"),
                         // The license this code is released under.
                         KAboutLicense::GPL,
                         // Copyright Statement.
                         i18n("(c) 2021"));
    aboutData.addAuthor(i18nc("@info:credit", "Felipe Kinoshita"), i18nc("@info:credit", "Author"), QStringLiteral("kinofhek@gmail.com"), QStringLiteral("https://fhek.gitlab.io.com"));
    KAboutData::setApplicationData(aboutData);

    QQmlApplicationEngine engine;

    auto config = WelcomeConfig::self();
    qmlRegisterSingletonInstance("org.kde.welcome", 1, 0, "Config", config);

    qmlRegisterSingletonInstance("org.kde.welcome", 1, 0, "AboutType", new AboutType);
    qmlRegisterSingletonInstance("org.kde.welcome", 1, 0, "Controller", new Controller);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
