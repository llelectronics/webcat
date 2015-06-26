#ifndef TRANSFERENGINE_H
#define TRANSFERENGINE_H

#include <QObject>
#include <QtDBus>
#include <QList>
#include <QDBusMetaType>
#include "transfermethodinfo.h"

class TransferEngine: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int count READ count NOTIFY countChanged)

    public:
        TransferEngine(QObject* parent = 0);
        const QList<TransferMethodInfo>& transferMethods();

    public:
        int count();

    signals:
        void countChanged();

    private:
        static const QString DBUS_SERVICE;
        static const QString DBUS_SERVICE_PATH;

    private:
        QList<TransferMethodInfo> _methods;
};

#endif // TRANSFERENGINE_H
