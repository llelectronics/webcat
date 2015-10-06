#include "webcatadaptor.h"

WebCatAdaptor::WebCatAdaptor(QObject *parent): QDBusAbstractAdaptor(parent)
{

}

WebCatAdaptor::~WebCatAdaptor()
{

}

void WebCatAdaptor::openUrl(const QStringList &args)
{
    QMetaObject::invokeMethod(parent(), "openUrl", Q_ARG(QStringList, args));
}

