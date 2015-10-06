#ifndef WEBCATINTERFACE_H
#define WEBCATINTERFACE_H

#include <QtDBus>
#include <QDesktopServices>
#include <QObject>
#include <QDebug>
#include <QQuickView>
#include "webcatadaptor.h"

class WebCatInterface : public QObject
{
    Q_OBJECT

    public:
        explicit WebCatInterface(QObject *parent = 0);
        static void sendArgs(const QStringList& args);

    public slots:
        void openSingleUrl(const QString& url);
        void openUrl(const QStringList& args);

    signals:
        void urlRequested(QStringList args);

    public:
        static const QString INTERFACE_NAME;
};

#endif // WEBCATINTERFACE_H
