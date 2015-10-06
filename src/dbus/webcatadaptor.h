#ifndef WEBPIRATEADAPTOR_H
#define WEBPIRATEADAPTOR_H

#include <QDBusAbstractAdaptor>

class WebCatAdaptor: public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.harbour.webcat")

    public:
        WebCatAdaptor(QObject *parent);
        virtual ~WebCatAdaptor();

    public slots:
        void openUrl(const QStringList &args);
};

#endif
