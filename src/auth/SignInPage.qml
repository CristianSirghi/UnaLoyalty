import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Intrarea în cont: telefonul (cod prin SMS) sau, la alegere, emailul (cod pe email; merge
// doar dacă emailul a fost adăugat și confirmat în Profil). După „Continue” vine pagina codului.
Page {
    id: page
    title: qsTr("Sign in")

    // Telefonul cu care să înceapă (ex. din dialogul „numărul are deja cont”).
    property string phone
    property bool byEmail: false
    property string errorText
    property bool noAccount: false

    background: Rectangle { color: Theme.background }

    Component { id: codePage; CodePage {} }
    Component { id: registerPage; RegisterPage {} }

    function submit() {
        page.errorText = ""
        page.noAccount = false
        SessionService.startSignIn(page.byEmail ? "email" : "sms", field.text)
    }

    Component.onCompleted: {
        field.text = page.phone
        field.focusField()
    }

    // Doar cât pagina e deasupra: altfel ar răspunde și la cererile altor pagini.
    Connections {
        target: SessionService
        enabled: page.StackView.status === StackView.Active

        function onCodeSent() {
            page.StackView.view.push(codePage)
        }
        function onRequestFailed(code, message) {
            page.errorText = message
            page.noAccount = code === "account_not_found"
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
                text: page.byEmail ? qsTr("We'll send a code to your email.")
                                   : qsTr("We'll send a code to your phone by SMS.")
                color: Theme.textSecondary
                font.pixelSize: Theme.fontBody
                wrapMode: Text.WordWrap
            }

            AppTextField {
                id: field
                Layout.fillWidth: true
                label: page.byEmail ? qsTr("Email") : qsTr("Phone number")
                prefix: page.byEmail ? "" : "+373"
                placeholderText: page.byEmail ? "name@example.com" : "60 000 000"
                inputMethodHints: page.byEmail ? Qt.ImhEmailCharactersOnly | Qt.ImhNoAutoUppercase
                                               : Qt.ImhDialableCharactersOnly
                enterKeyType: Qt.EnterKeyGo
                errorText: page.errorText
                onTextChanged: {
                    page.errorText = ""
                    page.noAccount = false
                }
                onAccepted: page.submit()
            }

            AppButton {
                Layout.fillWidth: true
                text: qsTr("Continue")
                enabled: field.text.trim() !== ""
                busy: SessionService.busy
                onClicked: page.submit()
            }

            // Nu există cont cu acest număr / email: drumul spre înregistrare.
            AppButton {
                Layout.fillWidth: true
                visible: page.noAccount
                text: qsTr("Create account")
                variant: "secondary"
                // push, nu replace: pagina nouă e creată din componenta acestei pagini;
                // cu replace pagina asta dispărea, iar cea nouă rămânea fără „înapoi”.
                onClicked: page.StackView.view.push(registerPage,
                                                    { phone: page.byEmail ? "" : field.text })
            }

            AppButton {
                Layout.alignment: Qt.AlignHCenter
                text: page.byEmail ? qsTr("Sign in with phone number instead")
                                   : qsTr("Sign in with email instead")
                variant: "text"
                onClicked: {
                    page.byEmail = !page.byEmail
                    field.text = ""
                    page.errorText = ""
                    page.noAccount = false
                    field.focusField()
                }
            }
        }
    }
}
