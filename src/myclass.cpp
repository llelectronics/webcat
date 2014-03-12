#include "myclass.h"
//#include <QNetworkCookieJar>
//#include <QNetworkAccessManager>


MyClass::MyClass(QQuickView *v)
{
    view = new QQuickView();
    view = v;
    engine = new QQmlEngine();
    engine = view->engine();
    h = myHome->homePath();

    config_dir = QDir(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation))
            .filePath(QCoreApplication::applicationName());

    data_dir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);

    cache_dir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
}

// Not used for now until I figure out how to implement this in a sane manner.
// TODO: Instead of this I should somehow grab the NetworkAccessManager of WebView but I don't know how it is implemented in Qt5
//       as settings view->engine()->setNetworkAccessManager()
void MyClass::privateMode() {
    QFile *myFolder = new QFile();
    myFolder->setFileName(h + "/.local/share/harbour-webcat/.QtWebKit");
    myFolder->rename(".QtWebkit", ".QtWebkit-Private");
    // Start webcat in Private Mode
    QProcess *proc = new QProcess();
    proc->startDetached("/usr/bin/harbour-webcat");
}

void MyClass::clearCookies() {
    //privateMode();
    QFile *cookieF = new QFile();
    //qDebug() << data_dir + "/.QtWebKit/cookies.db";
    cookieF->setFileName(data_dir + "/.QtWebKit/cookies.db");
    cookieF->remove();

    // Clear LocalStorage
    clear(data_dir + "/.QtWebKit/LocalStorage");

    // Reload webcat
    QProcess *proc = new QProcess();
    proc->startDetached("/usr/bin/harbour-webcat");
    // Efficient way to crash the app which is intended here :P
    view->close();
}

void MyClass::clear(QString dir) {
    QDir real_dir(dir);

    qDebug() << real_dir;

    //First delete any files in the current directory
    QFileInfoList files = real_dir.entryInfoList(QDir::NoDotAndDotDot | QDir::Files);
    qDebug() << "Files : " + files.count();
    for(int file = 0; file < files.count(); file++)
    {
        qDebug() << "Removing file " + QString(files.at(file).fileName());
        real_dir.remove(files.at(file).fileName());
    }

    //Now recursively delete any child directories
    QFileInfoList dirs = real_dir.entryInfoList(QDir::NoDotAndDotDot | QDir::Dirs);
    qDebug() << "Dirs : " + dirs.count();
    for(int dir = 0; dir < dirs.count(); dir++)
    {
        qDebug() << "Start removing files in " + QString(dirs.at(dir).absoluteFilePath());
        this->clear(dirs.at(dir).absoluteFilePath());
    }
}

void MyClass::clearCache() {
    // Clear DiskCache
    clear(cache_dir + "/.QtWebKit/DiskCache");
}

void MyClass::openNewWindow(const QString &url) {
    QProcess *proc = new QProcess();
    proc->startDetached("/usr/bin/harbour-webcat", QStringList(url));
}

void MyClass::openWithvPlayer(const QString &url) {
    qDebug() << "[myclass.cpp]: trying to start harbour-videoPlayer -p " + url;
    QProcess *proc = new QProcess();
    proc->startDetached("/usr/bin/harbour-videoPlayer -p \"" + url + "\"");
}

