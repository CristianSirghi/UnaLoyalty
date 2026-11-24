#pragma once

#include <QAbstractListModel>
#include <QDateTime>
#include <QList>
#include <QString>
#include <QtQml/qqmlregistration.h>

// Un bon pe care s-a folosit cardul.
struct Receipt
{
    int id = 0;               // id-ul bonului (pentru „Detaliul bonului”)
    QString number;           // numărul bonului, cum apare tipărit
    QDateTime dateTime;       // când s-a închis bonul
    double total = 0;         // suma bonului, lei
    double pointsEarned = 0;  // puncte primite (bonus din bon)
    double pointsSpent = 0;   // puncte folosite la plată (0 dacă nu)
};

// Bonurile unui card, cele mai noi primele. În QML:
//   ReceiptsModel { cardId: page.cardId }
// Rândurile au câmpurile receiptId, number, dateTime, total, pointsEarned, pointsSpent.
class ReceiptsModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int cardId READ cardId WRITE setCardId NOTIFY cardIdChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Role {
        ReceiptIdRole = Qt::UserRole + 1,
        NumberRole,
        DateTimeRole,
        TotalRole,
        PointsEarnedRole,
        PointsSpentRole,
    };

    explicit ReceiptsModel(QObject *parent = nullptr);

    int cardId() const;
    void setCardId(int cardId);

    int count() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void cardIdChanged();
    void countChanged();

private:
    void load();

    int m_cardId = 0;
    QList<Receipt> m_receipts;
};
