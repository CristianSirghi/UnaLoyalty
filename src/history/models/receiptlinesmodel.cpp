#include "receiptlinesmodel.h"

#include "core/apiclient.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>
#include <QPointer>

namespace {

// O linie din răspunsul get_receipt_lines (docs/SCOP.md, „Serverul de test”).
ReceiptLine lineFromJson(const QJsonObject &json)
{
    ReceiptLine line;
    line.name = json.value(QLatin1String("NAME")).toString();
    line.quantity = json.value(QLatin1String("QUANTITY")).toDouble();
    line.price = json.value(QLatin1String("PRICE")).toDouble();
    line.sum = json.value(QLatin1String("SUM")).toDouble();
    return line;
}

} // namespace

ReceiptLinesModel::ReceiptLinesModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

QString ReceiptLinesModel::barcode() const
{
    return m_barcode;
}

void ReceiptLinesModel::setBarcode(const QString &barcode)
{
    if (m_barcode == barcode)
        return;
    m_barcode = barcode;
    emit barcodeChanged();
    scheduleLoad();
}

int ReceiptLinesModel::serverId() const
{
    return m_serverId;
}

void ReceiptLinesModel::setServerId(int serverId)
{
    if (m_serverId == serverId)
        return;
    m_serverId = serverId;
    emit serverIdChanged();
    scheduleLoad();
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
    scheduleLoad();
}

int ReceiptLinesModel::count() const
{
    return int(m_lines.size());
}

bool ReceiptLinesModel::loading() const
{
    return m_loading;
}

bool ReceiptLinesModel::failed() const
{
    return m_failed;
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

void ReceiptLinesModel::scheduleLoad()
{
    // Cele trei proprietăți vin una după alta din QML: o singură cerere, după ultima.
    if (m_loadScheduled)
        return;
    m_loadScheduled = true;
    setLoading(true);
    QMetaObject::invokeMethod(this, &ReceiptLinesModel::load, Qt::QueuedConnection);
}

void ReceiptLinesModel::load()
{
    m_loadScheduled = false;
    const int request = ++m_request;
    setLines({});
    setFailed(false);
    if (m_barcode.isEmpty() || m_serverId == 0 || m_receiptId == 0) {
        setLoading(false);
        return;
    }

    setLoading(true);
    ApiClient::instance()->command(
        QStringLiteral("get_receipt_lines"),
        {{QStringLiteral("card"), m_barcode},
         {QStringLiteral("server"), m_serverId},
         {QStringLiteral("check"), m_receiptId}},
        [self = QPointer<ReceiptLinesModel>(this), request](const ApiClient::Result &result) {
            // Între timp s-a cerut alt bon: răspunsul ăsta nu mai contează.
            if (!self || self->m_request != request)
                return;
            self->setLoading(false);
            if (!result.ok) {
                qWarning() << "get_receipt_lines:" << result.error;
                self->setFailed(true);
                return;
            }
            QList<ReceiptLine> lines;
            const QJsonArray rows = result.data.toArray();
            for (const QJsonValue &row : rows)
                lines.append(lineFromJson(row.toObject()));
            self->setLines(lines);
        });
}

void ReceiptLinesModel::setLines(const QList<ReceiptLine> &lines)
{
    if (m_lines.isEmpty() && lines.isEmpty())
        return;
    beginResetModel();
    m_lines = lines;
    endResetModel();
    emit countChanged();
}

void ReceiptLinesModel::setLoading(bool loading)
{
    if (m_loading == loading)
        return;
    m_loading = loading;
    emit loadingChanged();
}

void ReceiptLinesModel::setFailed(bool failed)
{
    if (m_failed == failed)
        return;
    m_failed = failed;
    emit failedChanged();
}
