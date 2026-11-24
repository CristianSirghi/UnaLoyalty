#include "cardsmodel.h"

CardsModel::CardsModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int CardsModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : int(m_cards.size());
}

QVariant CardsModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid | CheckIndexOption::ParentIsInvalid))
        return {};

    const Card &card = m_cards.at(index.row());
    switch (role) {
    case IdRole:        return card.id;
    case LocalNameRole: return card.localName;
    case PointsRole:    return card.points;
    case BarcodeRole:   return card.barcode;
    }
    return {};
}

QHash<int, QByteArray> CardsModel::roleNames() const
{
    return {
        { IdRole,        "id" },
        { LocalNameRole, "localName" },
        { PointsRole,    "points" },
        { BarcodeRole,   "barcode" },
    };
}

void CardsModel::setCards(const QList<Card> &cards)
{
    beginResetModel();
    m_cards = cards;
    endResetModel();
}
