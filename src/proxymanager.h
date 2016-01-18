#ifndef PROXYMANAGER_H
#define PROXYMANAGER_H

#include <QObject>
#include <QStandardPaths>
#include <QDir>
#include <QFile>

class ProxyManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString host READ host WRITE setHost NOTIFY hostChanged)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)

    public:
        explicit ProxyManager(QObject *parent = 0);
        QString host() const;
        int port() const;
        void setHost(const QString& host);
        void setPort(int port);

    public slots:
        bool load();
        void save();
        void set();
        void unset();
        void remove();

    public:
        static void loadAndSet();
        static void unloadAndSet();

    signals:
       void hostChanged();
       void portChanged();

    private:
       QString _proxyfile;
       QString _host;
       int _port;

    private:
       static const QString PROXY_FILE;
};

#endif // PROXYMANAGER_H
