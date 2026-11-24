#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

#include "cardsmodel.h"

// Cardurile clientului, pentru QML: CardsService.cards.
// Deocamdată cu date de exemplu; mai târziu le ia de la server prin ApiClient.
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
    CardsModel *m_cards;
};
