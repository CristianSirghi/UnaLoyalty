#pragma once

#include <QAbstractListModel>
#include <QDateTime>
#include <QList>
#include <QString>
#include <QtQml/qqmlregistration.h>

// Un bon pe care s-a folosit cardul (get_receipts, docs/SCOP.md).
struct Receipt
{
    int serverId = 0;         // casa bonului (SERVER_ID)
    int id = 0;               // bonul pe casa lui (CHECK_ID = TMDB_COMENZ.COD); unic doar
                              // împreună cu serverId
    QString number;           // numărul afișat al bonului
    QDateTime dateTime;       // când s-a închis bonul
    double total = 0;         // suma bonului, lei (bani + puncte folosite)
    double paid = 0;          // cât s-a plătit în bani, lei (total - puncte folosite)
    double pointsEarned = 0;  // puncte primite (bonus din bon)
    double pointsSpent = 0;   // puncte folosite la plată (0 dacă nu)
};

// Bonurile unui card, cele mai noi primele, de pe server. În QML:
//   ReceiptsModel { barcode: page.selectedCard.barcode }
// Rândurile au câmpurile serverId, receiptId, number, dateTime, total, paid, pointsEarned,
// pointsSpent. Cât timp așteaptă răspunsul, loading e true.
class ReceiptsModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString barcode READ barcode WRITE setBarcode NOTIFY barcodeChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    enum Role {
        ServerIdRole = Qt::UserRole + 1,
        ReceiptIdRole,
        NumberRole,
        DateTimeRole,
        TotalRole,
        PaidRole,
        PointsEarnedRole,
        PointsSpentRole,
    };

    explicit ReceiptsModel(QObject *parent = nullptr);

    QString barcode() const;
    void setBarcode(const QString &barcode);

    int count() const;
    bool loading() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void barcodeChanged();
    void countChanged();
    void loadingChanged();

private:
    void load();
    void setReceipts(const QList<Receipt> &receipts);
    void setLoading(bool loading);

    QString m_barcode;
    QList<Receipt> m_receipts;
    bool m_loading = false;
};
