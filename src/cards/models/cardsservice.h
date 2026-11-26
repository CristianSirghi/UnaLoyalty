#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

#include "cardsmodel.h"

class QQmlEngine;
class QJSEngine;

// Cardurile clientului, pentru QML: CardsService.cards.
// Le cere de la server (get_cards, după tokenul contului) la pornire, dacă s-a intrat în cont,
// și la fiecare intrare; la ieșire lista se golește. Până vin, lista e goală.
class CardsService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(CardsModel *cards READ cards CONSTANT)

public:
    explicit CardsService(QQmlEngine *engine, QObject *parent = nullptr);

    // Qt creează singletonul prin funcția asta: serviciul are nevoie de motor ca să găsească
    // SessionService (intrarea / ieșirea din cont).
    static CardsService *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    CardsModel *cards() const;

private:
    void loadCards();

    CardsModel *m_cards;
};
