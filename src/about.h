#pragma once

#include <QObject>
#include <KAboutData>

class AboutType : public QObject
{
    Q_OBJECT
    Q_PROPERTY(KAboutData aboutData READ aboutData CONSTANT)
public:
    [[nodiscard]] KAboutData aboutData() const
    {
        return KAboutData::applicationData();
    }
};
