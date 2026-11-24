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
    case CardIdRole:    return card.id;
    case LocalNameRole: return card.localName;
    case PointsRole:    return card.points;
    case BarcodeRole:   return card.barcode;
    case BrandColorRole:    return card.brandColor;
    case BonusPercentRole:  return card.bonusPercent;
    case MaxPayPercentRole: return card.maxPayPercent;
    }
    return {};
}

QHash<int, QByteArray> CardsModel::roleNames() const
{
    return {
        { CardIdRole,    "cardId" },
        { LocalNameRole, "localName" },
        { PointsRole,    "points" },
        { BarcodeRole,   "barcode" },
        { BrandColorRole,    "brandColor" },
        { BonusPercentRole,  "bonusPercent" },
        { MaxPayPercentRole, "maxPayPercent" },
    };
}

void CardsModel::setCards(const QList<Card> &cards)
{
    beginResetModel();
    m_cards = cards;
    endResetModel();
}
