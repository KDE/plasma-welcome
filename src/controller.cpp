#include <QProcess>

#include "controller.h"

void Controller::open(const QString& program)
{
    QProcess::startDetached(program, {});
}
