#include "appqrcode.h"

#include <QPainter>
#include <QQuickWindow>

#include <cmath>

#include "3rdparty/qrcodegen/qrcodegen.hpp"

namespace {
// Marginea albă din jurul codului, în pătrățele. Standardul QR cere 4.
constexpr int QuietZone = 4;
}

AppQrCode::AppQrCode(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
    // Pătrățelele trebuie să aibă margini tăiate drept, nu netezite.
    setAntialiasing(false);
    // Desenul acoperă tot (fond alb): Qt nu mai amestecă cu ce e dedesubt.
    setOpaquePainting(true);
}

void AppQrCode::itemChange(ItemChange change, const ItemChangeData &value)
{
    // Pe un ecran cu altă densitate de pixeli, pătrățelele se recalculează.
    if (change == ItemDevicePixelRatioHasChanged)
        update();
    QQuickPaintedItem::itemChange(change, value);
}

QString AppQrCode::text() const
{
    return m_text;
}

void AppQrCode::setText(const QString &text)
{
    if (m_text == text)
        return;
    m_text = text;

    m_size = 0;
    m_modules.clear();
    if (!m_text.isEmpty()) {
        try {
            // Corecție de erori medie: codul se citește și cu ecranul puțin zgâriat.
            const auto qr = qrcodegen::QrCode::encodeText(m_text.toUtf8().constData(),
                                                          qrcodegen::QrCode::Ecc::MEDIUM);
            m_size = qr.getSize();
            m_modules.resize(size_t(m_size) * size_t(m_size));
            for (int y = 0; y < m_size; ++y)
                for (int x = 0; x < m_size; ++x)
                    m_modules[size_t(y) * size_t(m_size) + size_t(x)] = qr.getModule(x, y);
        } catch (const std::exception &) {
            // Textul nu încape într-un QR (mii de caractere): nu desenăm nimic.
            m_size = 0;
            m_modules.clear();
        }
    }

    emit textChanged();
    update();
}

void AppQrCode::paint(QPainter *painter)
{
    painter->fillRect(boundingRect(), Qt::white);
    if (m_size == 0)
        return;

    // Pătrățel de mărime întreagă (în pixeli fizici), ca toate să fie egale și clare;
    // codul se centrează în spațiul rămas.
    const int total = m_size + 2 * QuietZone;
    const qreal dpr = window() ? window()->effectiveDevicePixelRatio() : 1.0;
    const qreal side = qMin(width(), height());
    const qreal module = qMax(1.0, std::floor(side * dpr / total)) / dpr;
    const qreal left = std::round((width() - module * m_size) / 2 * dpr) / dpr;
    const qreal top = std::round((height() - module * m_size) / 2 * dpr) / dpr;

    painter->setPen(Qt::NoPen);
    painter->setBrush(Qt::black);
    for (int y = 0; y < m_size; ++y) {
        for (int x = 0; x < m_size; ++x) {
            if (m_modules[size_t(y) * size_t(m_size) + size_t(x)])
                painter->drawRect(QRectF(left + x * module, top + y * module, module, module));
        }
    }
}
