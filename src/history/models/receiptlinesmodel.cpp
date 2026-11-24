#include "receiptlinesmodel.h"

namespace {

// Date de exemplu, din schema ecranelor (bonurile de exemplu din ReceiptsModel).
// Se înlocuiesc cu răspunsul serverului: de unde vin liniile bonului în Back e
// întrebare deschisă (vezi docs/SCOP.md).
QList<ReceiptLine> sampleLines(int receiptId)
{
    const auto line = [](int n, double quantity, double price) {
        return ReceiptLine{ QStringLiteral("Produs %1").arg(n), quantity, price, quantity * price };
    };
    switch (receiptId) {
    case 1042: return { line(1, 2, 45.00), line(2, 1, 85.00), line(3, 1, 70.00) };
    case 987:  return { line(1, 2, 40.00), line(2, 1, 50.00) };
    case 915:  return { line(1, 2, 85.00), line(2, 1, 140.00) };
    }
    return {};
}

} // namespace

ReceiptLinesModel::ReceiptLinesModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int ReceiptLinesModel::receiptId() const
{
    return m_receiptId;
}

void ReceiptLinesModel::setReceiptId(int receiptId)
{
    if (m_receiptId == receiptId)
        return;
    m_receiptId = receiptId;
    emit receiptIdChanged();
    load();
}

int ReceiptLinesModel::count() const
{
    return int(m_lines.size());
}

int ReceiptLinesModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : count();
}

QVariant ReceiptLinesModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid | CheckIndexOption::ParentIsInvalid))
        return {};

    const ReceiptLine &line = m_lines.at(index.row());
    switch (role) {
    case NameRole:     return line.name;
    case QuantityRole: return line.quantity;
    case PriceRole:    return line.price;
    case SumRole:      return line.sum;
    }
    return {};
}

QHash<int, QByteArray> ReceiptLinesModel::roleNames() const
{
    return {
        { NameRole,     "name" },
        { QuantityRole, "quantity" },
        { PriceRole,    "price" },
        { SumRole,      "sum" },
    };
}

void ReceiptLinesModel::load()
{
    beginResetModel();
    m_lines = sampleLines(m_receiptId);
    endResetModel();
    emit countChanged();
}
