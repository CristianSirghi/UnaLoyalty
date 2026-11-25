#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

#include "cardsmodel.h"

// Cardurile clientului, pentru QML: CardsService.cards.
// Le cere de la server la pornire (comanda get_cards); până vin, lista e goală.
class CardsService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(CardsModel *cards READ cards CONSTANT)

public:
    explicit CardsService(QObject *parent = nullptr);

    CardsModel *cards() const;

private:
    void loadCards();

    CardsModel *m_cards;
};
