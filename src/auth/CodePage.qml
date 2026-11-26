import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Codul primit prin SMS (sau pe email): 6 căsuțe; se trimite singur la ultima cifră.
// Aceeași pagină pentru înregistrare și intrare: SessionService știe ce a cerut.
// „Resend code” se poate apăsa după câte secunde spune serverul (RESEND_AFTER).
Page {
    id: page
    title: qsTr("Enter the code")

    property string errorText
    property int secondsLeft: SessionService.resendAfter

    background: Rectangle { color: Theme.background }

    Component.onCompleted: codeField.focusField()

    Timer {
        interval: 1000
        repeat: true
        running: page.secondsLeft > 0
        onTriggered: page.secondsLeft -= 1
    }

    Connections {
        target: SessionService
        enabled: page.StackView.status === StackView.Active

        // Cod nou trimis (retrimis): numărătoarea de la capăt.
        function onCodeSent() {
            page.errorText = ""
            page.secondsLeft = SessionService.resendAfter
            codeField.clear()
            codeField.focusField()
        }
        function onRequestFailed(code, message) {
            page.errorText = message
            codeField.clear()
            codeField.focusField()
        }
    }

    AppFlickable {
        anchors.fill: parent
        contentHeight: content.implicitHeight + content.anchors.topMargin + Theme.spaceXl

        ColumnLayout {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: Theme.spaceXl
                rightMargin: Theme.spaceXl
                topMargin: page.SafeArea.margins.top + Theme.spaceL
            }
            spacing: Theme.spaceL

            AppPageHeader {
                Layout.fillWidth: true
                title: page.title
                onBackClicked: page.StackView.view.pop()
            }

            Text {
                Layout.fillWidth: true
                text: SessionService.codeChannel === "email"
                      ? qsTr("We sent a 6-digit code to %1.").arg(SessionService.codeTarget)
                      : qsTr("We sent a 6-digit code by SMS to %1.")
                            .arg(Format.phone(SessionService.codeTarget))
                color: Theme.textSecondary
                font.pixelSize: Theme.fontBody
                wrapMode: Text.WordWrap
            }

            AppCodeField {
                id: codeField
                Layout.fillWidth: true
                length: 6
                hasError: page.errorText !== ""
                // Nu se dezactivează cât se verifică codul (confirmCode ignoră oricum a doua
                // cerere): reactivat, câmpul își lua singur focusul înapoi și deschidea
                // tastatura peste portofel.
                onCodeChanged: if (code !== "") page.errorText = ""
                onCompleted: (code) => SessionService.confirmCode(code)
            }

            Text {
                Layout.fillWidth: true
                visible: page.errorText !== ""
                text: page.errorText
                color: Theme.danger
                font.pixelSize: Theme.fontCaption
                wrapMode: Text.WordWrap
            }

            // Doar pe serverul de test: codul nu se trimite, vine în răspuns.
            Text {
                Layout.fillWidth: true
                visible: SessionService.testCode !== ""
                text: qsTr("Test server: the code is %1").arg(SessionService.testCode)
                color: Theme.textSecondary
                font.pixelSize: Theme.fontCaption
            }

            AppButton {
                Layout.alignment: Qt.AlignHCenter
                variant: "text"
                enabled: page.secondsLeft <= 0
                busy: SessionService.busy
                text: page.secondsLeft > 0
                      ? qsTr("Resend code in %1").arg(Format.duration(page.secondsLeft))
                      : qsTr("Resend code")
                onClicked: SessionService.resendCode()
            }
        }
    }
}
