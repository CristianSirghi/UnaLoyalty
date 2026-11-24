#include "systembars.h"

#ifdef Q_OS_ANDROID
#include <QCoreApplication>
#include <QJniObject>
#endif

SystemBars::SystemBars(QObject *parent)
    : QObject(parent)
{
}

bool SystemBars::lightStatusBarIcons() const
{
    return m_lightStatusBarIcons;
}

void SystemBars::setLightStatusBarIcons(bool light)
{
    if (m_lightStatusBarIcons == light)
        return;
    m_lightStatusBarIcons = light;
    emit lightStatusBarIconsChanged();
    apply();
}

bool SystemBars::lightNavigationBarIcons() const
{
    return m_lightNavigationBarIcons;
}

void SystemBars::setLightNavigationBarIcons(bool light)
{
    if (m_lightNavigationBarIcons == light)
        return;
    m_lightNavigationBarIcons = light;
    emit lightNavigationBarIconsChanged();
    apply();
}

bool SystemBars::whiteOverlay() const
{
    return m_whiteOverlay;
}

void SystemBars::setWhiteOverlay(bool open)
{
    if (m_whiteOverlay == open)
        return;
    m_whiteOverlay = open;
    emit whiteOverlayChanged();
    apply();
}

void SystemBars::apply()
{
#ifdef Q_OS_ANDROID
    const bool lightStatus = m_lightStatusBarIcons && !m_whiteOverlay;
    const bool lightNavigation = m_lightNavigationBarIcons;

    auto done = QNativeInterface::QAndroidApplication::runOnAndroidMainThread(
        [lightStatus, lightNavigation]() {
            QJniObject activity = QNativeInterface::QAndroidApplication::context();
            if (!activity.isValid())
                return;
            QJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
            if (!window.isValid())
                return;

            const int sdk = QNativeInterface::QAndroidApplication::sdkVersion();
            if (sdk >= 30) {
                // WindowInsetsController: APPEARANCE_LIGHT_STATUS_BARS = 8,
                // APPEARANCE_LIGHT_NAVIGATION_BARS = 16 („light” = fond deschis,
                // deci iconițe închise).
                QJniObject controller = window.callObjectMethod(
                    "getInsetsController", "()Landroid/view/WindowInsetsController;");
                if (!controller.isValid())
                    return;
                const jint mask = 8 | 16;
                const jint appearance = (lightStatus ? 0 : 8) | (lightNavigation ? 0 : 16);
                controller.callMethod<void>("setSystemBarsAppearance", "(II)V", appearance, mask);
            } else {
                // Android 9–10: SYSTEM_UI_FLAG_LIGHT_STATUS_BAR = 0x2000,
                // SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR = 0x10.
                QJniObject decor = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
                if (!decor.isValid())
                    return;
                jint flags = decor.callMethod<jint>("getSystemUiVisibility", "()I");
                flags &= ~(0x2000 | 0x10);
                if (!lightStatus)
                    flags |= 0x2000;
                if (!lightNavigation)
                    flags |= 0x10;
                decor.callMethod<void>("setSystemUiVisibility", "(I)V", flags);
            }
        });
    Q_UNUSED(done);
#endif
}
