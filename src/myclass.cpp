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
    cookieF->setFileName(h + "/.local/share/harbour-webcat/.QtWebKit/cookies.db");
    cookieF->remove();
    // Reload webcat
    QProcess *proc = new QProcess();
    proc->startDetached("/usr/bin/harbour-webcat");
    // Efficient way to crash the app which is intended here :P
    view->close();
}

void MyClass::openNewWindow(const QString &url) {
    QProcess *proc = new QProcess();
    proc->startDetached("/usr/bin/harbour-webcat", QStringList(url));
}

