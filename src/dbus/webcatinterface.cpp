#include "webcatinterface.h"

const QString WebCatInterface::INTERFACE_NAME = "org.harbour.webcat";

WebCatInterface::WebCatInterface(QObject *parent): QObject(parent)
{
    qDBusRegisterMetaType<QStringList>();
    new WebCatAdaptor(this);

    QDBusConnection connection = QDBusConnection::sessionBus();

    if(!connection.isConnected())
    {
        qWarning("Cannot connect to the D-Bus session bus.");
        return;
    }

    if(!connection.registerService(WebCatInterface::INTERFACE_NAME))
    {
        qWarning() << connection.lastError().message();
        return;
    }

    if(!connection.registerObject("/", this))
        qWarning() << connection.lastError().message();
}

void WebCatInterface::sendArgs(const QStringList &args)
{
    QList<QVariant> urls;
    urls.append(QVariant::fromValue(args));

    QDBusMessage message = QDBusMessage::createMethodCall(WebCatInterface::INTERFACE_NAME, "/", WebCatInterface::INTERFACE_NAME, "openUrl");
    QDBusConnection connection(QDBusConnection::sessionBus());

    message.setArguments(urls);
    connection.asyncCall(message);
}

void WebCatInterface::openSingleUrl(const QString &url)
{
    this->sendArgs((QStringList() << url));
}

void WebCatInterface::openUrl(const QStringList &args)
{
    emit urlRequested(args);
}
