#include "transfermethodinfo.h"

TransferMethodInfo::TransferMethodInfo()
{

}

TransferMethodInfo::TransferMethodInfo(const TransferMethodInfo &tmi): DisplayName(tmi.DisplayName),
                                                                       UserName(tmi.UserName),
                                                                       MethodId(tmi.MethodId),
                                                                       ShareUIpath(tmi.ShareUIpath),
                                                                       Capabilities(tmi.Capabilities),
                                                                       AccountId(tmi.AccountId)
{

}

QDBusArgument &operator <<(QDBusArgument &argument, const TransferMethodInfo &tmi)
{
    argument.beginStructure();

    argument << tmi.DisplayName
             << tmi.UserName
             << tmi.MethodId
             << tmi.ShareUIpath
             << tmi.Capabilities
             << tmi.AccountId;

    argument.endStructure();
    return argument;
}


const QDBusArgument &operator >>(const QDBusArgument &argument, TransferMethodInfo &tmi)
{
    argument.beginStructure();

    argument >> tmi.DisplayName
             >> tmi.UserName
             >> tmi.MethodId
             >> tmi.ShareUIpath
             >> tmi.Capabilities
             >> tmi.AccountId;

    argument.endStructure();
    return argument;
}
