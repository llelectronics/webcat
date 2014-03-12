#ifndef MYCLASS_H
#define MYCLASS_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QDebug>
#include <QQuickView>
#include <QQmlEngine>
#include <QProcess>
#include <QStandardPaths>
#include <QCoreApplication>

class MyClass : public QObject
{
    Q_OBJECT

public:
    MyClass(QQuickView *v);
    QQuickView *view;
    QQmlEngine *engine;

public slots:
    // Poor mans approach as the default Cookie and Cache stuff works pretty good // TODO: Need to reconsider this for specific cookie denial/approval
    void privateMode();

    void clearCookies();
    void clearCache();

    void openNewWindow(const QString &url);
    void openWithvPlayer(const QString &url);

private:
    QDir *myHome;
    QString h;
    QString config_dir;
    QString data_dir;
    QString cache_dir;
    void clear(QString dir);
};

#endif // MYCLASS_H
