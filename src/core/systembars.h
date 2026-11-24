#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

// Culoarea iconițelor din barele telefonului (ora/bateria sus, butoanele de navigare
// jos), după ce e sub ele: albe pe banda colorată sau pe tema întunecată, închise pe
// fond deschis. Aplicația desenează sub bare (Main.qml), deci culoarea o alegem noi.
//   lightStatusBarIcons     — iconițe albe sus
//   lightNavigationBarIcons — iconițe albe jos
//   whiteOverlay            — e deschis un ecran alb peste tot (codul mărit):
//                             iconițele de sus devin închise, orice ar spune celelalte
// Android: prin WindowInsetsController (Android 11+) sau steagurile vechi (Android 9–10).
// iOS și desktop: nu face nimic deocamdată.
class SystemBars : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool lightStatusBarIcons READ lightStatusBarIcons WRITE setLightStatusBarIcons
                   NOTIFY lightStatusBarIconsChanged)
    Q_PROPERTY(bool lightNavigationBarIcons READ lightNavigationBarIcons
                   WRITE setLightNavigationBarIcons NOTIFY lightNavigationBarIconsChanged)
    Q_PROPERTY(bool whiteOverlay READ whiteOverlay WRITE setWhiteOverlay NOTIFY whiteOverlayChanged)

public:
    explicit SystemBars(QObject *parent = nullptr);

    bool lightStatusBarIcons() const;
    void setLightStatusBarIcons(bool light);

    bool lightNavigationBarIcons() const;
    void setLightNavigationBarIcons(bool light);

    bool whiteOverlay() const;
    void setWhiteOverlay(bool open);

signals:
    void lightStatusBarIconsChanged();
    void lightNavigationBarIconsChanged();
    void whiteOverlayChanged();

private:
    void apply();

    bool m_lightStatusBarIcons = false;
    bool m_lightNavigationBarIcons = false;
    bool m_whiteOverlay = false;
};
