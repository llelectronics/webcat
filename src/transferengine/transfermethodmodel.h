#ifndef TRANSFERMETHODMODEL_H
#define TRANSFERMETHODMODEL_H

#include <QHash>
#include <QAbstractItemModel>
#include "transferengine.h"

class TransferMethodModel: public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
    Q_PROPERTY(TransferEngine* transferEngine READ transferEngine WRITE setTransferEngine NOTIFY transferEngineChanged)

    public:
        enum RoleNames { UserName, MethodId, ShareUIPath, AccountId };

    public:
        explicit TransferMethodModel(QObject *parent = 0);
        QString filter() const;
        void setFilter(const QString& s);
        TransferEngine* transferEngine() const;
        void setTransferEngine(TransferEngine* te);

    private:
        void updateMethods();
        bool isTransferMethodRequested(const TransferMethodInfo& tmi);

    signals:
        void filterChanged();
        void transferEngineChanged();

    public: /* Overriden Methods */
        virtual QHash<int, QByteArray> roleNames() const;
        virtual int rowCount(const QModelIndex&) const;
        virtual QVariant data(const QModelIndex &index, int role) const;

    private:
        QString _filter;
        TransferEngine* _transferengine;
        QList<TransferMethodInfo> _methods;
};

#endif // TRANSFERMETHODMODEL_H
