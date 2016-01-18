#include "proxymanager.h"

const QString ProxyManager::PROXY_FILE = "proxy.conf";

ProxyManager::ProxyManager(QObject *parent) : QObject(parent), _port(0)
{
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::DataLocation));
    this->_proxyfile = dir.absoluteFilePath(ProxyManager::PROXY_FILE);
}

QString ProxyManager::host() const
{
    return this->_host;
}

int ProxyManager::port() const
{
    return this->_port;
}

void ProxyManager::setHost(const QString &host)
{
    if(this->_host == host)
        return;

    this->_host = host;
    emit hostChanged();
}

void ProxyManager::setPort(int port)
{
    if(this->_port == port)
        return;

    this->_port = port;
    emit portChanged();
}

bool ProxyManager::load()
{
    if(!QFile::exists(this->_proxyfile))
        return false;

    QFile file(this->_proxyfile);

    if(!file.open(QFile::ReadOnly))
        return false;

    bool res = false;
    QStringList settings = QString::fromUtf8(file.readAll()).simplified().split(":");

    if(settings.length() == 2)
    {
        this->_host = settings.first();
        this->_port = settings.last().toInt();

        emit hostChanged();
        emit portChanged();

        res = true;
    }

    file.close();
    return res;
}

void ProxyManager::save()
{
    QFile file(this->_proxyfile);
    file.open(QFile::WriteOnly);
    file.write(QString("%1:%2").arg(this->_host, QString::number(this->_port)).simplified().toUtf8());
    file.close();
}

void ProxyManager::set()
{
    QByteArray envvar = QString("http://%1:%2").arg(this->_host, QString::number(this->_port)).toUtf8();

    qputenv("http_proxy", envvar);
    qputenv("https_proxy", envvar);
    qputenv("ftp_proxy", envvar);
    qputenv("rsync_proxy", envvar);
}

void ProxyManager::unset()
{
    this->_host = QString();
    this->_port = 0;

    qunsetenv("http_proxy");
    qunsetenv("https_proxy");
    qunsetenv("ftp_proxy");
    qunsetenv("rsync_proxy");
}

void ProxyManager::remove()
{
    if(QFile::exists(this->_proxyfile))
        QFile::remove(this->_proxyfile);
}

void ProxyManager::loadAndSet()
{
    ProxyManager proxymanager;

    if(!proxymanager.load())
        return;

    proxymanager.set();
}

void ProxyManager::unloadAndSet()
{
    ProxyManager proxymanager;

    proxymanager.unset();
}

