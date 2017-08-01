#ifndef MYCLASS_H
#define MYCLASS_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QDebug>
#include <QQuickView>
#include <QQmlEngine>
#include <QProcess>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QDateTime>
#include <QByteArray>
#include <QClipboard>

class MyClass : public QObject
{
    Q_OBJECT

public:
    MyClass(QQuickView *v);
    ~MyClass();
    QQuickView *view;
    QQmlEngine *engine;

public slots:
    // Poor mans approach as the default Cookie and Cache stuff works pretty good // TODO: Need to reconsider this for specific cookie denial/approval
    void privateMode();

//    void clearCookies();
    void clearCache();

    void openNewWindow(const QString &url);
    void openPrivateNewWindow(const QString &url);
    void openWithvPlayer(const QString &url);
    void openExternally(const QString &url);
    void resetDefaultBrowser();
    void setDefaultBrowser();
    void backupConfig();
    void backupConfig(QString backupName);
    void checkBackup(QString backupFile);
    void copy2clipboard(QString text);
    void createDesktopLauncher(QString favIcon, QString title, QString url);

signals:
    void backupComplete();
    void restoreComplete();
    void error(QString message);

private:
    QDir *myHome;
    QString h;
    QString config_dir;
    QString data_dir;
    QString cache_dir;
    QString documents_dir;
    QString errorMsg;
    QString curBackupFile;
    QDateTime curDate;
    QProcess compress;
    QProcess checkProcess;
    QProcess decompress;
    void clear(QString dir);
    bool validBackupFile;
    bool isFile(const QString &url);
    bool existsPath(const QString &url);
    void setMime(const QString &mimeType, const QString &desktopFile);
    void restoreBackup();
    void remove(const QString &url);

private slots:
    void getCompressStatus(int exitCode);
    void getDecompressStatus(int exitCode);
    void getCheckStatus(int exitCode);
};

#endif // MYCLASS_H
