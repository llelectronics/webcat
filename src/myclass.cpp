#include "myclass.h"
//#include <QNetworkCookieJar>
//#include <QNetworkAccessManager>


MyClass::MyClass(QQuickView *v)
{
//    view = v;
//    engine = new QQmlEngine();
//    engine = view->engine();
    h = myHome->homePath();

    config_dir = QDir(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation))
            .filePath(QCoreApplication::applicationName());

    data_dir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);

    cache_dir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);

    //qDebug() << data_dir;
}

MyClass::~MyClass() {
    if (data_dir.contains("PRIVATE")) {
        qDebug() << "[myclass.cpp]: Seems to be a private browsing mode so remove the data_dir for it...";
        clear(data_dir); // Site specific stuff
        clear(data_dir + "/.QtWebKit"); // The rest (cookies, bookmarks, settings and so on)
    }
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

//void MyClass::clearCookies() {
//    //privateMode();
//    QFile *cookieF = new QFile();
//    //qDebug() << data_dir + "/.QtWebKit/cookies.db";
//    cookieF->setFileName(data_dir + "/.QtWebKit/cookies.db");
//    cookieF->remove();

//    // Clear LocalStorage
//    clear(data_dir + "/.QtWebKit/LocalStorage");

//    // Reload webcat
//    QProcess *proc = new QProcess();
//    proc->startDetached("/usr/bin/harbour-webcat");
//    // Efficient way to crash the app which is intended here :P
//    view->close();
//}

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
    proc->startDetached("/usr/bin/harbour-webcat --new-window " + url);
}

void MyClass::openPrivateNewWindow(const QString &url) {
    QProcess *proc = new QProcess();
    proc->startDetached("/usr/bin/harbour-webcat --private " + url);
}

void MyClass::openWithvPlayer(const QString &url) {
    qDebug() << "[myclass.cpp]: trying to start harbour-videoPlayer -p " + url;
    QProcess *proc = new QProcess();
    proc->startDetached("/usr/bin/harbour-videoPlayer -p \"" + url + "\"");
}

bool MyClass::isFile(const QString &url)
{
    return QFileInfo(url).isFile();
}

bool MyClass::existsPath(const QString &url)
{
    return QDir(url).exists();
}

void MyClass::setMime(const QString &mimeType, const QString &desktopFile)
{
    // Workaround for SailfishOS which only works if defaults.list is available. Xdg-mime only produces mimeapps.list however
    if (!isFile(h + "/.local/share/applications/defaults.list"))  {
        QProcess linking;
        linking.start("ln -sf " + h + "/.local/share/applications/mimeapps.list " + h + "/.local/share/applications/defaults.list");
        linking.waitForFinished();
    }
    QProcess mimeProc;
    mimeProc.start("xdg-mime default " + desktopFile + " " + mimeType);
    mimeProc.waitForFinished();
}

void MyClass::setDefaultBrowser()
{
    QFile cpFile;
    if (!isFile(h + "/.local/share/applications/open-url-webcat.desktop")) {
        cpFile.copy("/usr/share/harbour-webcat/open-url-webcat.desktop", h + "/.local/share/applications/open-url-webcat.desktop");
    }
    if (!existsPath(h + "/.local/share/dbus-1/services")) {
        QDir makePath;
        makePath.mkpath(h + "/.local/share/dbus-1/services");
    }
    cpFile.copy("/usr/share/harbour-webcat/org.harbour.webcat.service", h+ "/.local/share/dbus-1/services/org.harbour.webcat.service");
    setMime("text/html", "open-url-webcat.desktop");
    setMime("x-maemo-urischeme/http", "open-url-webcat.desktop");
    setMime("x-maemo-urischeme/https", "open-url-webcat.desktop");
}

void MyClass::resetDefaultBrowser()
{
    setMime("text/html", "open-url.desktop");
    setMime("x-maemo-urischeme/http", "open-url.desktop");
    setMime("x-maemo-urischeme/https", "open-url.desktop");
}

void MyClass::backupConfig()
{
    backupConfig("webcat_backup" + curDate.currentDateTime().toString("yyyy_MM_dd_hh_mm_ss") +".tar.gz");
}

void MyClass::backupConfig(QString backupName)
{
    if (existsPath(data_dir)) {
        if (backupName.isEmpty())
            backupName = "webcat_backup" + curDate.currentDateTime().toString("yyyy_MM_dd_hh_mm_ss") +".tar.gz";
        compress.start("tar -zcvf " + h + "/" + backupName + " " + data_dir + "/");
        connect(&compress, SIGNAL(finished(int)), this, SLOT(getCompressStatus(int)));
    }
    else {
        errorMsg = "Webcat config dir not found"; // This should never happen
        error(errorMsg);
    }
}

void MyClass::getCompressStatus(int exitCode)
{
    if (exitCode == 0) {
        backupComplete();
    }
    else {
        QByteArray errorOut = compress.readAllStandardError();
        qDebug() << "Called the C++ slot and got following error:" << errorOut.simplified();
        errorMsg = errorOut.simplified();
        error(errorMsg);
    }
}
