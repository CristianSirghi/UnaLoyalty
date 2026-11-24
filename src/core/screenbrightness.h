#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

// Luminozitatea ecranului, pentru codul arătat la casă: scanerele citesc mult mai
// sigur un ecran luminos. În QML:
//   ScreenBrightness.setMaximum(true)   // la deschiderea codului mărit
//   ScreenBrightness.setMaximum(false)  // la închidere: revine la setarea telefonului
// Android: doar pentru fereastra aplicației, nu schimbă setarea telefonului.
// iOS: de făcut (cere cod Objective-C++, se compilează doar pe macOS).
// Desktop: nu face nimic.
class ScreenBrightness : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit ScreenBrightness(QObject *parent = nullptr);

    Q_INVOKABLE void setMaximum(bool maximum);
};
