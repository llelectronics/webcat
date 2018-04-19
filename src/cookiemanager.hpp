#ifndef COOKIEMANAGER_HPP
#define COOKIEMANAGER_HPP

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>
#include "fmhelper.hpp"


class CookieManager : public QObject
{
    Q_OBJECT

signals:
    void addCookieToList(QString cookieTxt);

public:
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "Connection");

public slots:
    bool openDB() {
        db.setDatabaseName(_fm->data_dir() + "/.QtWebKit/cookies.db");
        if (!db.open()) {
            qDebug() << ("Error occurred opening the database: " + _fm->data_dir() + "/.QtWebKit/cookies.db");
            qDebug() << ("%s.", qPrintable(db.lastError().text()));
            return -1;
        }
        return true;
    }

    int getCookies() {
        QSqlQuery query(db);
        query.prepare("SELECT cookieId FROM cookies;");
        if (!query.exec()) {
            qDebug() << ("Error occurred querying.");
            qDebug() << ("%s.", qPrintable(db.lastError().text()));
            return -1;
        }
        while (query.next()) {
            //qDebug() << ("cookie = %s.", query.value(0).toString());
            addCookieToList(query.value(0).toString());
        }
        return 0;
    }

    int removeCookie(QString cookieTxt) {
        QSqlQuery query(db);
        query.prepare("DELETE FROM cookies WHERE cookieId = '" + cookieTxt + "';");
        if (!query.exec()) {
            qDebug() << ("Error occurred removing cookie.");
            qDebug() << ("%s.", qPrintable(db.lastError().text()));
            return -1;
        }
        return 0;
    }

private:
    FM *_fm = new FM();

};

#endif // COOKIEMANAGER_HPP
