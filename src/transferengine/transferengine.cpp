#include "transferengine.h"

const QString TransferEngine::DBUS_SERVICE = "org.nemo.transferengine";
const QString TransferEngine::DBUS_SERVICE_PATH = "/org/nemo/transferengine";

TransferEngine::TransferEngine(QObject* parent): QObject(parent)
{
    qDBusRegisterMetaType<TransferMethodInfo>();
    qDBusRegisterMetaType< QList<TransferMethodInfo> >();

    this->transferMethods(); // Initialize list
}

const QList<TransferMethodInfo> &TransferEngine::transferMethods()
{
    if(this->_methods.isEmpty())
    {
        QDBusConnection bus = QDBusConnection::sessionBus();
        QDBusInterface interface(TransferEngine::DBUS_SERVICE, TransferEngine::DBUS_SERVICE_PATH, QString(), bus);
        QDBusReply< QList<TransferMethodInfo> > reply = interface.call("transferMethods");

        if(!reply.isValid())
        {
            qWarning() << Q_FUNC_INFO << reply.error().message();
            this->_methods.clear();
        }
        else
            this->_methods = reply.value();

        emit countChanged();
    }

    return this->_methods;
}

int TransferEngine::count()
{
    return this->_methods.count();
}
