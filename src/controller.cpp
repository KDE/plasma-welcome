#include <QFile>
#include <QProcess>
#include <QStandardPaths>
#include <QString>

#include "controller.h"

#include "welcomeconfig.h"

void Controller::open(const QString& program)
{
    QProcess::startDetached(program, {});
}

void Controller::removeFromAutostart()
{
    if (WelcomeConfig::self()->skip() == true) {
        QString configPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
        QString autoStart = QString::fromUtf8("/autostart/");
        QString fileName = QString::fromUtf8("welcome.desktop");
        QString fullPath = configPath + autoStart + fileName;
        QFile file = fullPath;
        file.remove();
    }
}
