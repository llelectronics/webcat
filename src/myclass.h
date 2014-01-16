#ifndef MYCLASS_H
#define MYCLASS_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QDebug>
#include <QQuickView>
#include <QQmlEngine>
#include <QProcess>

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

    void openNewWindow(const QString &url);

private:
    QDir *myHome;
    QString h;
};

#endif // MYCLASS_H
