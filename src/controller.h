#include "QObject"

class Controller : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE static void open(const QString& program);
    Q_INVOKABLE static void removeFromAutostart();
};
