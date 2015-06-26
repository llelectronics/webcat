#include "transfermethodmodel.h"

TransferMethodModel::TransferMethodModel(QObject *parent): QAbstractListModel(parent), _transferengine(NULL)
{

}

QString TransferMethodModel::filter() const
{
    return this->_filter;
}

void TransferMethodModel::setFilter(const QString &s)
{
    if(this->_filter == s)
        return;

    this->_filter = s;

    if(this->_transferengine)
        this->updateMethods();

    emit filterChanged();
}

TransferEngine *TransferMethodModel::transferEngine() const
{
    return this->_transferengine;
}

void TransferMethodModel::setTransferEngine(TransferEngine *te)
{
    if(this->_transferengine == te)
        return;

    this->_transferengine = te;

    if(this->_transferengine)
        this->updateMethods();

    emit transferEngineChanged();
}

void TransferMethodModel::updateMethods()
{
    if(!this->_filter.isEmpty())
    {
        QList<TransferMethodInfo> methods = this->_transferengine->transferMethods();

        foreach(TransferMethodInfo method, methods)
        {
            if(!this->isTransferMethodRequested(method))
                continue;

            this->_methods.append(method);
        }
    }
    else
        this->_methods = this->_transferengine->transferMethods();

    this->beginInsertRows(QModelIndex(), 0, this->_filter.count() - 1);
    this->endInsertRows();
}

bool TransferMethodModel::isTransferMethodRequested(const TransferMethodInfo &tmi)
{
    const QStringList& capabilities = tmi.Capabilities;

    if(this->_filter.isEmpty())
        return true;

    QRegExp rgxfilter("(.+)/(.+)");

    if(!rgxfilter.exactMatch(this->_filter))
        return false;

    foreach(QString capability, capabilities)
    {
        if(capability == "*")
            return true;

        QStringList types = capability.split("/");

        if(rgxfilter.cap(1) != types[0]) // Validate Prefix
            return false;

        if((rgxfilter.cap(2) == types[1]) || types[1] == "*") // Validate Suffix
            return true;
    }

    return false;
}

QHash<int, QByteArray> TransferMethodModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TransferMethodModel::UserName] = "userName";
    roles[TransferMethodModel::MethodId] = "methodId";
    roles[TransferMethodModel::ShareUIPath] = "shareUIPath";
    roles[TransferMethodModel::AccountId] = "accountId";

    return roles;
}

int TransferMethodModel::rowCount(const QModelIndex&) const
{
    if(!this->_transferengine)
        return 0;

    return this->_methods.count();
}

QVariant TransferMethodModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid() || !this->_transferengine || index.row() >= this->_methods.count())
        return QVariant();

    const TransferMethodInfo& tmi = this->_methods.at(index.row());

    switch(role)
    {
        case TransferMethodModel::UserName:
            return tmi.UserName;

        case TransferMethodModel::MethodId:
            return tmi.MethodId;

        case TransferMethodModel::ShareUIPath:
            return tmi.ShareUIpath;

        case TransferMethodModel::AccountId:
            return tmi.AccountId;

        default:
            break;
    }

    return QVariant();
}
