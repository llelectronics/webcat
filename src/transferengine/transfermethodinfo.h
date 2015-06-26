#ifndef TRANSFERMETHODINFO_H
#define TRANSFERMETHODINFO_H

#include <QDBusArgument>

struct TransferMethodInfo
{
    public:
        TransferMethodInfo();
        TransferMethodInfo(const TransferMethodInfo& tmi);

    public:
        QString DisplayName;
        QString UserName;
        QString MethodId;
        QString ShareUIpath;
        QStringList Capabilities;
        quint32 AccountId;
};

Q_DECLARE_METATYPE(TransferMethodInfo)

QDBusArgument& operator <<(QDBusArgument &argument, const TransferMethodInfo &tmi);
const QDBusArgument& operator >>(const QDBusArgument &argument, TransferMethodInfo &tmi);

#endif // TRANSFERMETHODINFO_H
