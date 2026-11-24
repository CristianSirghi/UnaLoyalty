#include "screenbrightness.h"

#ifdef Q_OS_ANDROID
#include <QCoreApplication>
#include <QJniObject>
#endif

ScreenBrightness::ScreenBrightness(QObject *parent)
    : QObject(parent)
{
}

void ScreenBrightness::setMaximum(bool maximum)
{
#ifdef Q_OS_ANDROID
    // WindowManager.LayoutParams.screenBrightness: 1.0 = maxim, -1 = după setarea
    // telefonului. Fereastra Android se schimbă doar din firul principal Android.
    const float value = maximum ? 1.0f : -1.0f;
    auto done = QNativeInterface::QAndroidApplication::runOnAndroidMainThread([value]() {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (!activity.isValid())
            return;
        QJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
        if (!window.isValid())
            return;
        QJniObject params = window.callObjectMethod(
            "getAttributes", "()Landroid/view/WindowManager$LayoutParams;");
        if (!params.isValid())
            return;
        params.setField<jfloat>("screenBrightness", value);
        window.callMethod<void>("setAttributes",
                                "(Landroid/view/WindowManager$LayoutParams;)V",
                                params.object());
    });
    Q_UNUSED(done);
#else
    Q_UNUSED(maximum);
#endif
}
