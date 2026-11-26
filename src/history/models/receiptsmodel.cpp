#include "receiptsmodel.h"

#include "core/apiclient.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>
#include <QPointer>

namespace {

// Un bon din răspunsul get_receipts (docs/SCOP.md, „Serverul de test”).
Receipt receiptFromJson(const QJsonObject &json)
{
    Receipt receipt;
    receipt.serverId = json.value(QLatin1String("SERVER_ID")).toInt();
    receipt.id = json.value(QLatin1String("CHECK_ID")).toInt();
    // Numărul tipărit pe bon încă nu-l știm (docs/SCOP.md); până atunci, codul bonului.
    receipt.number = QString::number(receipt.id);
    receipt.dateTime = QDateTime::fromString(json.value(QLatin1String("CLOSED_AT")).toString(),
                                             Qt::ISODate);
    receipt.total = json.value(QLatin1String("TOTAL")).toDouble();
    receipt.paid = json.value(QLatin1String("PAID")).toDouble();
    receipt.pointsEarned = json.value(QLatin1String("POINTS_EARNED")).toDouble();
    receipt.pointsSpent = json.value(QLatin1String("POINTS_SPENT")).toDouble();
    return receipt;
}

} // namespace

ReceiptsModel::ReceiptsModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

QString ReceiptsModel::barcode() const
{
    return m_barcode;
}

void ReceiptsModel::setBarcode(const QString &barcode)
{
    if (m_barcode == barcode)
        return;
    m_barcode = barcode;
    emit barcodeChanged();
    load();
}

int ReceiptsModel::count() const
{
    return int(m_receipts.size());
}

bool ReceiptsModel::loading() const
{
    return m_loading;
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
    case ServerIdRole:     return receipt.serverId;
    case ReceiptIdRole:    return receipt.id;
    case NumberRole:       return receipt.number;
    case DateTimeRole:     return receipt.dateTime;
    case TotalRole:        return receipt.total;
    case PaidRole:         return receipt.paid;
    case PointsEarnedRole: return receipt.pointsEarned;
    case PointsSpentRole:  return receipt.pointsSpent;
    }
    return {};
}

QHash<int, QByteArray> ReceiptsModel::roleNames() const
{
    return {
        { ServerIdRole,     "serverId" },
        { ReceiptIdRole,    "receiptId" },
        { NumberRole,       "number" },
        { DateTimeRole,     "dateTime" },
        { TotalRole,        "total" },
        { PaidRole,         "paid" },
        { PointsEarnedRole, "pointsEarned" },
        { PointsSpentRole,  "pointsSpent" },
    };
}

void ReceiptsModel::load()
{
    // Bonurile cardului vechi dispar imediat: să nu apară o clipă sub cardul nou.
    setReceipts({});
    if (m_barcode.isEmpty()) {
        setLoading(false);
        return;
    }

    setLoading(true);
    const QString barcode = m_barcode;
    ApiClient::instance()->command(
        QStringLiteral("get_receipts"),
        {{QStringLiteral("card"), barcode}},
        [self = QPointer<ReceiptsModel>(this), barcode](const ApiClient::Result &result) {
            // Între timp s-a ales alt card: răspunsul ăsta nu mai contează.
            if (!self || self->m_barcode != barcode)
                return;
            self->setLoading(false);
            if (!result.ok) {
                qWarning() << "get_receipts:" << result.error;
                return;
            }
            QList<Receipt> receipts;
            const QJsonArray rows = result.data.toArray();
            for (const QJsonValue &row : rows)
                receipts.append(receiptFromJson(row.toObject()));
            self->setReceipts(receipts);
        });
}

void ReceiptsModel::setReceipts(const QList<Receipt> &receipts)
{
    if (m_receipts.isEmpty() && receipts.isEmpty())
        return;
    beginResetModel();
    m_receipts = receipts;
    endResetModel();
    emit countChanged();
}

void ReceiptsModel::setLoading(bool loading)
{
    if (m_loading == loading)
        return;
    m_loading = loading;
    emit loadingChanged();
}
