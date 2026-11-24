#include "receiptsmodel.h"

namespace {

// Date de exemplu, din schema ecranelor. Se înlocuiesc cu răspunsul serverului
// (de unde vin bonurile în Back: întrebare deschisă, vezi docs/SCOP.md).
QList<Receipt> sampleReceipts(int cardId)
{
    if (cardId != 2)   // cardul de test cu 0 puncte nu are bonuri
        return {};

    const auto at = [](int day, int hour, int minute) {
        return QDateTime(QDate(2026, 11, day), QTime(hour, minute));
    };
    return {
        { 1042, QStringLiteral("1042"), at(21, 13, 45), 245.00, 12, 0 },
        {  987, QStringLiteral("0987"), at(14, 19, 40), 130.00,  6, 0 },
        {  915, QStringLiteral("0915"), at(2, 12, 15),  310.00, 15, 0 },
    };
}

} // namespace

ReceiptsModel::ReceiptsModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int ReceiptsModel::cardId() const
{
    return m_cardId;
}

void ReceiptsModel::setCardId(int cardId)
{
    if (m_cardId == cardId)
        return;
    m_cardId = cardId;
    emit cardIdChanged();
    load();
}

int ReceiptsModel::count() const
{
    return int(m_receipts.size());
}

int ReceiptsModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : count();
}

QVariant ReceiptsModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid | CheckIndexOption::ParentIsInvalid))
        return {};

    const Receipt &receipt = m_receipts.at(index.row());
    switch (role) {
    case ReceiptIdRole:    return receipt.id;
    case NumberRole:       return receipt.number;
    case DateTimeRole:     return receipt.dateTime;
    case TotalRole:        return receipt.total;
    case PointsEarnedRole: return receipt.pointsEarned;
    case PointsSpentRole:  return receipt.pointsSpent;
    }
    return {};
}

QHash<int, QByteArray> ReceiptsModel::roleNames() const
{
    return {
        { ReceiptIdRole,    "receiptId" },
        { NumberRole,       "number" },
        { DateTimeRole,     "dateTime" },
        { TotalRole,        "total" },
        { PointsEarnedRole, "pointsEarned" },
        { PointsSpentRole,  "pointsSpent" },
    };
}

void ReceiptsModel::load()
{
    beginResetModel();
    m_receipts = sampleReceipts(m_cardId);
    endResetModel();
    emit countChanged();
}
