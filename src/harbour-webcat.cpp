/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include "myclass.h"
#include "DownloadManager.hpp"
#include "fmhelper.hpp"
#include "videohelper.hpp"
#include "folderlistmodel/qquickfolderlistmodel.h"
#include "transferengine/transferengine.h"
#include "transferengine/transfermethodmodel.h"
#include "dbus/webcatinterface.h"
#include "proxymanager.h"

// Compile everything needed for faster startup and less memory usage
#include <QQuickItem>
#include <QQuickView>
#include <QGuiApplication>
#include <QQmlContext>
#include <QDBusConnection>

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    //Some more speed & memory improvements
    setenv("QT_NO_FT_CACHE","1",1);
    setenv("QT_NO_FAST_SCROLL","1",1);
    setenv("QT_NO_ANTIALIASING","1",1);
    setenv("QT_NO_FREE","1",1);
    // Taken from sailfish-browser
    setenv("USE_ASYNC", "1", 1);
    QQuickWindow::setDefaultAlphaBuffer(true);

    QGuiApplication *app = SailfishApp::application(argc, argv);

    QDBusConnection sessionbus = QDBusConnection::sessionBus();

    qmlRegisterType<QQuickFolderListModel>("harbour.webcat.FolderListModel", 1, 0, "FolderListModel");
    qmlRegisterType<TransferEngine>("harbour.webcat.DBus.TransferEngine", 1, 0, "TransferEngine");
    qmlRegisterType<TransferMethodModel>("harbour.webcat.DBus.TransferEngine", 1, 0, "TransferMethodModel");
    qmlRegisterType<WebCatInterface>("harbour.webcat.DBus", 1, 0, "WebCatInterface");
    qmlRegisterType<ProxyManager>("harbour.webcat.Network", 1, 0, "ProxyManager");

    QString file;
    bool noHomepage = false;
    bool setDefault = false;
    bool resetDefault = false;
    bool openNewWindow = false;

    ProxyManager::loadAndSet();

    // Sometimes I get the feeling I don't know what I do. But it works and the only limitation so far is that '--private' needs to be the first argument
    if (QString(argv[1]) == "--private") {
        // Load private mode here
        app->setApplicationName("harbour-webcat_PRIVATE");
        ProxyManager::unloadAndSet();
        for(int i=1; i<argc; i++) {
            if (QString(argv[i]) == "about:bookmarks") file = "about:bookmarks";
            else if (!QString(argv[i]).startsWith("/") && !QString(argv[i]).startsWith("http://") && !QString(argv[i]).startsWith("rtsp://")
                     && !QString(argv[i]).startsWith("mms://") && !QString(argv[i]).startsWith("file://") && !QString(argv[i]).startsWith("https://") && !QString(argv[i]).startsWith("www.")) {
                QString pwd("");
                char * PWD;
                PWD = getenv ("PWD");
                pwd.append(PWD);
                file = pwd + "/" + QString(argv[i]);
            }
            else if (QString(argv[i]).startsWith("www.")) file = "http://" + QString(argv[i]);
            else file = QString(argv[i]);
        }
    }
    else if (QString(argv[1]) == "--no-homepage") {
        noHomepage = true;
    }
    else if (QString(argv[1]) == "--set-default") {
        printf("Setting Webcat as default browser...\n");
        setDefault = true;
    }
    else if (QString(argv[1]) == "--reset-default") {
        printf("Resetting to default browser...\n");
        resetDefault = true;
    }
    else if (QString(argv[1]) == "--new-window") {
        openNewWindow = true;

        for(int i=1; i<argc; i++) {
            if (QString(argv[i]) == "about:bookmarks") file = "about:bookmarks";
            else if (!QString(argv[i]).startsWith("/") && !QString(argv[i]).startsWith("http://") && !QString(argv[i]).startsWith("rtsp://")
                     && !QString(argv[i]).startsWith("mms://") && !QString(argv[i]).startsWith("file://") && !QString(argv[i]).startsWith("https://") && !QString(argv[i]).startsWith("www.")) {
                QString pwd("");
                char * PWD;
                PWD = getenv ("PWD");
                pwd.append(PWD);
                file = pwd + "/" + QString(argv[i]);
            }
            else if (QString(argv[i]).startsWith("www.")) file = "http://" + QString(argv[i]);
            else file = QString(argv[i]);
        }
    }
    else {
        app->setApplicationName("harbour-webcat");   // Hopefully no location changes with libsailfishapp affecting config
        if(sessionbus.interface()->isServiceRegistered(WebCatInterface::INTERFACE_NAME) && openNewWindow == false) // Only a Single Instance is allowed
        {
            WebCatInterface::sendArgs(app->arguments().mid(1)); // Forward URLs to the running instance

            if(app->hasPendingEvents())
                app->processEvents();

            return 0;
        }
        for(int i=1; i<argc; i++) {
            if (QString(argv[i]) == "about:bookmarks") file = "about:bookmarks";
            else if (!QString(argv[i]).startsWith("/") && !QString(argv[i]).startsWith("http://") && !QString(argv[i]).startsWith("rtsp://")
                     && !QString(argv[i]).startsWith("mms://") && !QString(argv[i]).startsWith("file://") && !QString(argv[i]).startsWith("https://") && !QString(argv[i]).startsWith("www.")) {
                QString pwd("");
                char * PWD;
                PWD = getenv ("PWD");
                pwd.append(PWD);
                file = pwd + "/" + QString(argv[i]);
            }
            else if (QString(argv[i]).startsWith("www.")) file = "http://" + QString(argv[i]);
            else file = QString(argv[i]);
        }
    }

    //app->setOrganizationName("Webcat");
    app->setApplicationVersion("2.0.0");
    QQuickView *view = SailfishApp::createView();

    view->setSource(SailfishApp::pathTo("qml/harbour-webcat.qml"));

    QObject *object = view->rootObject();

    //qDebug() << file.isEmpty();
    if (!file.isEmpty() ) {
        qDebug() << "Loading url " + file;
        object->setProperty("siteURL", file);
        qDebug() << object->property("siteURL");
        QMetaObject::invokeMethod(object, "loadInNewTab", Qt::DirectConnection, Q_ARG(QVariant, file));
    }
    else if (noHomepage) {
        qDebug() << "Calling with --no-homepage. This should only be done by dbus";
    }
    else QMetaObject::invokeMethod(object, "loadInitialTab");

    MyClass myClass(view);
    if (setDefault) {
        myClass.setDefaultBrowser();
        return 0;
    }
    else if (resetDefault) {
        myClass.resetDefaultBrowser();
        return 0;
    }

    QObject::connect(object, SIGNAL(clearCache()),
                     &myClass, SLOT(clearCache()));
    QObject::connect(object, SIGNAL(openNewWindow(QString)),
                     &myClass, SLOT(openNewWindow(QString)));
    QObject::connect(object, SIGNAL(openPrivateNewWindow(QString)),
                     &myClass, SLOT(openPrivateNewWindow(QString)));
    QObject::connect(object, SIGNAL(openWithvPlayerExternal(QString)),
                     &myClass, SLOT(openWithvPlayer(QString)));
    QObject::connect(object, SIGNAL(setDefaultBrowser()),
                     &myClass, SLOT(setDefaultBrowser()));
    QObject::connect(object, SIGNAL(resetDefaultBrowser()),
                     &myClass, SLOT(resetDefaultBrowser()));

    // Create download manager object
    DownloadManager manager;

    QFile vPlayer("/usr/bin/harbour-videoPlayer");
    if (vPlayer.exists()) {
        object->setProperty("vPlayerExists", true);
    }
    else {
        object->setProperty("vPlayerExists", false);
    }

    view->engine()->rootContext()->setContextProperty("_myClass", &myClass);
    view->engine()->rootContext()->setContextProperty("_manager", &manager);

    FM *fileAction = new FM();
    view->engine()->rootContext()->setContextProperty("_fm", fileAction);

    videoHelper *vHelper = new videoHelper();
    view->engine()->rootContext()->setContextProperty("_videoHelper", vHelper);

    view->showFullScreen();

    return app->exec();
}
