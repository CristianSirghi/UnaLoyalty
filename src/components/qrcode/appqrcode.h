#pragma once

#include <QQuickPaintedItem>
#include <QString>
#include <QtQml/qqmlregistration.h>

#include <vector>

// Codul QR al unui text, desenat pătrățel cu pătrățel: iese clar la orice mărime.
// În QML:  AppQrCode { text: "2803990000016"; width: 240; height: 240 }
// Mereu negru pe alb (și în tema întunecată), cu marginea albă cerută de scanere.
class AppQrCode : public QQuickPaintedItem
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)

public:
    explicit AppQrCode(QQuickItem *parent = nullptr);

    QString text() const;
    void setText(const QString &text);

    void paint(QPainter *painter) override;

protected:
    void itemChange(ItemChange change, const ItemChangeData &value) override;

signals:
    void textChanged();

private:
    QString m_text;
    int m_size = 0;                // pătrățele pe latură (0 = nimic de desenat)
    std::vector<bool> m_modules;   // m_size * m_size, rând cu rând
};
