import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Contul nou: prenumele, numele, telefonul. Telefonul se confirmă cu codul primit prin SMS
// (pagina codului); contul se creează abia după cod. Dacă numărul are deja un cont, omul
// alege: intră în el sau numărul e acum al lui (trece la contul nou).
Page {
    id: page
    title: qsTr("Create account")

    property string phone
    property string nameError
    property string phoneError
    property string errorText

    background: Rectangle { color: Theme.background }

    Component { id: codePage; CodePage {} }

    function clearErrors() {
        page.nameError = ""
        page.phoneError = ""
        page.errorText = ""
    }

    function submit(force) {
        clearErrors()
        SessionService.startRegistration(firstName.text, lastName.text, phoneField.text, force)
    }

    Component.onCompleted: {
        phoneField.text = page.phone
        firstName.focusField()
    }

    Connections {
        target: SessionService
        enabled: page.StackView.status === StackView.Active

        function onCodeSent() {
            page.StackView.view.push(codePage)
        }
        function onRequestFailed(code, message) {
            if (code === "phone_registered")
                takenDialog.open()
            else if (code === "name_invalid")
                page.nameError = message
            else if (code === "phone_invalid")
                page.phoneError = message
            else
                page.errorText = message
        }
    }

    AppDialog {
        id: takenDialog
        title: qsTr("This number already has an account")
        text: qsTr("If the account is yours, sign in. If you got this number recently and the old account isn't yours, create a new one: the number will move to it.")
        acceptText: qsTr("Sign in")
        rejectText: qsTr("The number is mine now")
        onAccepted: SessionService.startSignIn("sms", phoneField.text)
        onRejected: page.submit(true)
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
                enterKeyType: Qt.EnterKeyNext
                onTextChanged: page.nameError = ""
                onAccepted: phoneField.focusField()
            }

            AppTextField {
                id: phoneField
                Layout.fillWidth: true
                label: qsTr("Phone number")
                prefix: "+373"
                placeholderText: "60 000 000"
                helperText: qsTr("We'll send a code by SMS to confirm it.")
                inputMethodHints: Qt.ImhDialableCharactersOnly
                enterKeyType: Qt.EnterKeyGo
                errorText: page.phoneError
                onTextChanged: page.phoneError = ""
                onAccepted: page.submit(false)
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
                text: qsTr("Continue")
                enabled: firstName.text.trim() !== "" && lastName.text.trim() !== ""
                         && phoneField.text.trim() !== ""
                busy: SessionService.busy
                onClicked: page.submit(false)
            }
        }
    }
}
