#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QString>
#include <QtQml/qqmlregistration.h>

// O linie de pe bon: un produs.
struct ReceiptLine
{
    QString name;        // denumirea produsului
    double quantity = 0; // cantitatea (poate fi fracționară: produse la cântar)
    double price = 0;    // prețul unitar, lei
    double sum = 0;      // suma liniei, lei
};

// Liniile unui bon, în ordinea de pe bon. În QML:
//   ReceiptLinesModel { receiptId: page.receiptId }
// Rândurile au câmpurile name, quantity, price, sum.
class ReceiptLinesModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int receiptId READ receiptId WRITE setReceiptId NOTIFY receiptIdChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Role {
        NameRole = Qt::UserRole + 1,
        QuantityRole,
        PriceRole,
        SumRole,
    };

    explicit ReceiptLinesModel(QObject *parent = nullptr);

    int receiptId() const;
    void setReceiptId(int receiptId);

    int count() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void receiptIdChanged();
    void countChanged();

private:
    void load();

    int m_receiptId = 0;
    QList<ReceiptLine> m_lines;
};
