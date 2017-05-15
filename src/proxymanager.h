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
    Q_PROPERTY(bool isSocks5 READ isSocks5 WRITE setSocks5 NOTIFY socks5Changed)

    public:
        explicit ProxyManager(QObject *parent = 0);
        QString host() const;
        int port() const;
        bool isSocks5() const;
        void setHost(const QString& host);
        void setPort(int port);
        void setSocks5(bool socks5);

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
       void socks5Changed();

    private:
       QString _proxyfile;
       QString _host;
       int _port;
       bool _socks5 = false;

    private:
       static const QString PROXY_FILE;
};

#endif // PROXYMANAGER_H
