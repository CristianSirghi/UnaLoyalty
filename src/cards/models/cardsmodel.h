#pragma once

#include <QAbstractListModel>
#include <QColor>
#include <QList>
#include <QString>
#include <QtQml/qqmlregistration.h>

// Un card de fidelitate al clientului.
struct Card
{
    int id = 0;               // TMS_CARDS.ID
    QString localName;        // localul la care e cardul
    double points = 0;        // TMS_CARDS.BONUS_POINTS (pot fi fracționare: 5% din bon)
    QString barcode;          // codul EAN-13 (28... / 29...), cel scanat la casă
    QColor brandColor;        // culoarea localului (banda de sus, inițiala)
    double bonusPercent = 0;  // cât % din bon devine puncte (regula tipului de card)
    double maxPayPercent = 0; // cât % din bon se poate plăti cu puncte
};

// Lista cardurilor. În QML, fiecare rând are câmpurile cardId, localName, points,
// barcode, brandColor, bonusPercent, maxPayPercent. (Nu „id”: în QML e cuvânt rezervat.)
class CardsModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Lista vine din CardsService.cards")

public:
    enum Role {
        CardIdRole = Qt::UserRole + 1,
        LocalNameRole,
        PointsRole,
        BarcodeRole,
        BrandColorRole,
        BonusPercentRole,
        MaxPayPercentRole,
    };

    explicit CardsModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setCards(const QList<Card> &cards);

private:
    QList<Card> m_cards;
};
