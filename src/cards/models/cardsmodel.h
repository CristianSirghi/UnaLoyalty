#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QString>
#include <QtQml/qqmlregistration.h>

// Un card de fidelitate al clientului.
struct Card
{
    int id = 0;            // TMS_CARDS.ID
    QString localName;     // localul la care e cardul (afișat pe placă)
    double points = 0;     // TMS_CARDS.BONUS_POINTS (pot fi fracționare: 5% din bon)
    QString barcode;       // codul EAN-13 (28... / 29...), cel scanat la casă
};

// Lista cardurilor, pentru ListView. În QML, fiecare rând are câmpurile
// id, localName, points, barcode.
class CardsModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Lista vine din CardsService.cards")

public:
    enum Role {
        IdRole = Qt::UserRole + 1,
        LocalNameRole,
        PointsRole,
        BarcodeRole,
    };

    explicit CardsModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setCards(const QList<Card> &cards);

private:
    QList<Card> m_cards;
};
