import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Datele personale, ca un singur formular: prenumele, numele, emailul, telefonul.
// - Prenumele și numele se pot schimba.
// - Emailul: dacă nu există, se scrie aici; „Save” trimite un cod pe el (pagina codului de la
//   intrare) și, după cod, emailul e al contului. Dacă există, e doar de citit.
// - Telefonul e doar de citit: cu el se intră în cont.
// „Save” salvează ce s-a schimbat (întâi numele, apoi emailul) și se întoarce în Profil.
// Numele se schimbă doar în cont; cardurile din Back rămân pe numele cu care au fost făcute.
Page {
    id: page
    title: qsTr("Personal details")

    property string nameError
    property string emailError
    property string errorText
    // Numele s-a salvat; urmează codul pentru email (după nameUpdated).
    property bool emailPending: false

    readonly property bool hasEmail: SessionService.email !== ""
    readonly property bool nameChanged: firstName.text.trim() !== SessionService.firstName
                                        || lastName.text.trim() !== SessionService.lastName
    readonly property bool emailEntered: !hasEmail && email.text.trim() !== ""
    // Adresa arată a email (verificarea din C++, aceeași regulă ca pe server).
    readonly property bool emailValid: SessionService.checkEmail(email.text) === ""
    readonly property bool nameComplete: firstName.text.trim() !== "" && lastName.text.trim() !== ""

    background: Rectangle { color: Theme.background }

    Component { id: codePage; CodePage {} }

    function submit() {
        if (!page.nameComplete || !(page.nameChanged || page.emailEntered) || SessionService.busy)
            return
        // Adresă evident greșită: eroarea sub câmp, nimic nu pleacă la server.
        if (page.emailEntered && !page.emailValid) {
            page.emailError = SessionService.checkEmail(email.text)
            return
        }
        page.nameError = ""
        page.emailError = ""
        page.errorText = ""
        page.emailPending = page.nameChanged && page.emailEntered
        if (page.nameChanged)
            SessionService.updateName(firstName.text, lastName.text)
        else
            SessionService.startAddEmail(email.text)
    }

    Component.onCompleted: {
        firstName.text = SessionService.firstName
        lastName.text = SessionService.lastName
        email.text = SessionService.email
    }

    Connections {
        target: SessionService
        enabled: page.StackView.status === StackView.Active

        function onNameUpdated() {
            if (page.emailPending) {
                page.emailPending = false
                SessionService.startAddEmail(email.text)
            } else {
                page.StackView.view.pop()
            }
        }
        // Codul pentru email a plecat: după confirmare, pagina codului duce direct în Profil.
        function onCodeSent() {
            const view = page.StackView.view
            view.push(codePage, { returnTo: view.get(page.StackView.index - 1) })
        }
        function onRequestFailed(code, message) {
            page.emailPending = false
            if (code === "name_invalid")
                page.nameError = message
            else if (code === "email_invalid" || code === "email_taken")
                page.emailError = message
            else
                page.errorText = message
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

            // Câmpurile nu se dezactivează cât se salvează: un câmp reactivat își lua singur
            // focusul înapoi și deschidea tastatura (docs/SCOP.md, „Conturile”).
            AppTextField {
                id: firstName
                Layout.fillWidth: true
                label: qsTr("First name")
                maximumLength: 64
                enterKeyType: Qt.EnterKeyNext
                errorText: page.nameError
                onTextChanged: page.nameError = ""
                onAccepted: lastName.focusField()
            }

            AppTextField {
                id: lastName
                Layout.fillWidth: true
                label: qsTr("Last name")
                maximumLength: 64
                enterKeyType: page.hasEmail ? Qt.EnterKeyDone : Qt.EnterKeyNext
                onTextChanged: page.nameError = ""
                onAccepted: page.hasEmail ? page.submit() : email.focusField()
            }

            AppTextField {
                id: email
                Layout.fillWidth: true
                label: qsTr("Email")
                placeholderText: "name@example.com"
                helperText: page.hasEmail ? qsTr("You can also sign in with this email.")
                                          : qsTr("We'll send a code to confirm it.")
                readOnly: page.hasEmail
                maximumLength: 254
                inputMethodHints: Qt.ImhEmailCharactersOnly | Qt.ImhNoAutoUppercase
                                  | Qt.ImhNoPredictiveText
                enterKeyType: Qt.EnterKeyDone
                errorText: page.emailError
                // Adresa se verifică doar la „Save” (submit), nu cât se scrie: la ieșirea din
                // câmp (ex. tastatura închisă ca să vezi pagina) eroarea apărea prea devreme.
                onTextChanged: page.emailError = ""
                // Tasta ✓: închide tastatura și face exact ce face „Save”.
                onAccepted: {
                    Qt.inputMethod.hide()
                    page.submit()
                }
            }

            AppTextField {
                Layout.fillWidth: true
                label: qsTr("Phone number")
                text: Format.phone(SessionService.phone)
                helperText: qsTr("You sign in with this number.")
                readOnly: true
            }

            Text {
                Layout.fillWidth: true
                visible: page.errorText !== ""
                text: page.errorText
                color: Theme.danger
                font.pixelSize: Theme.fontCaption
                wrapMode: Text.WordWrap
            }

            AppButton {
                Layout.fillWidth: true
                text: qsTr("Save")
                // Activ și cu un email greșit: apăsarea arată eroarea sub câmp (fără cerere).
                enabled: page.nameComplete && (page.nameChanged || page.emailEntered)
                busy: SessionService.busy
                onClicked: page.submit()
            }
        }
    }

    AppStatusBarScrim { color: Theme.background }
}
