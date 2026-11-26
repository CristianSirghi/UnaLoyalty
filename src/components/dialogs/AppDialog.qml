import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Templates as T
import UnaLoyalty

// Fereastra de confirmare a aplicației: titlu, text, unul sau două butoane, unul sub altul.
//   AppDialog {
//       id: signOutDialog
//       title: qsTr("Sign out?")
//       text: qsTr("You can sign in again with your phone number.")
//       acceptText: qsTr("Sign out")
//       rejectText: qsTr("Cancel")              // gol = un singur buton
//       destructive: true                       // butonul principal roșu
//       onAccepted: SessionService.signOut()
//   }
//   signOutDialog.open()
// Atingerea în afara ferestrei sau „înapoi” o închide fără alegere (rejected nu vine).
T.Popup {
    id: control

    property string title
    property string text
    property string acceptText: qsTr("OK")
    property string rejectText
    property bool destructive: false

    signal accepted()
    signal rejected()

    parent: T.Overlay.overlay
    anchors.centerIn: parent
    width: parent ? Math.min(parent.width - Theme.spaceXxl * 2, 360) : 320
    modal: true
    focus: true
    padding: Theme.spaceXxl
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutside

    T.Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.45)
    }

    background: Rectangle {
        radius: Theme.radiusL
        color: Theme.surface
    }

    contentItem: ColumnLayout {
        spacing: Theme.spaceS

        Text {
            Layout.fillWidth: true
            visible: control.title !== ""
            text: control.title
            color: Theme.textPrimary
            font.pixelSize: Theme.fontSubheading
            font.weight: Font.Bold
            wrapMode: Text.WordWrap
        }

        Text {
            Layout.fillWidth: true
            visible: control.text !== ""
            text: control.text
            color: Theme.textSecondary
            font.pixelSize: Theme.fontBody
            wrapMode: Text.WordWrap
        }

        AppButton {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spaceL
            text: control.acceptText
            variant: control.destructive ? "dangerFilled" : "primary"
            onClicked: {
                control.close()
                control.accepted()
            }
        }

        AppButton {
            Layout.fillWidth: true
            visible: control.rejectText !== ""
            text: control.rejectText
            variant: "text"
            onClicked: {
                control.close()
                control.rejected()
            }
        }
    }
}
