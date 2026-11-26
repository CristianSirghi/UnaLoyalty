import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import UnaLoyalty

// Câmpul de text al aplicației: eticheta deasupra, căsuța, sub ea un ajutor sau eroarea.
//   AppTextField { label: qsTr("First name") }
//   AppTextField {
//       label: qsTr("Phone")
//       prefix: "+373"                                  // text fix în fața câmpului
//       inputMethodHints: Qt.ImhDialableCharactersOnly
//       errorText: "..."                                // roșu; ascunde helperText
//   }
// Pornește de la T.TextField (șablonul fără stil): îl desenăm noi, deci arată la fel pe
// toate platformele. Ce înseamnă textul (validare, trimitere) decide pagina.
ColumnLayout {
    id: control

    property string label
    property string placeholderText
    property string helperText
    property string errorText
    property string prefix
    property alias text: field.text
    property alias inputMethodHints: field.inputMethodHints
    property alias maximumLength: field.maximumLength
    property alias validator: field.validator
    // Ce apare pe tasta Enter a tastaturii: Qt.EnterKeyNext, Qt.EnterKeyDone...
    property int enterKeyType: Qt.EnterKeyDefault

    readonly property bool hasError: errorText !== ""

    // Enter pe tastatură
    signal accepted()

    function focusField() {
        field.forceActiveFocus()
    }

    spacing: Theme.spaceXsPlus

    Text {
        visible: control.label !== ""
        text: control.label
        color: Theme.textSecondary
        font.pixelSize: Theme.fontCaption
        font.weight: Font.DemiBold
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: Theme.touchTarget + Theme.spaceXs
        radius: Theme.radiusS
        color: Theme.surface
        border.width: field.activeFocus || control.hasError ? 2 : 1
        border.color: control.hasError ? Theme.danger
                      : field.activeFocus ? Theme.primary : Theme.border

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spaceM
            anchors.rightMargin: Theme.spaceM
            spacing: Theme.spaceXsPlus

            Text {
                visible: control.prefix !== ""
                text: control.prefix
                color: Theme.textSecondary
                font.pixelSize: Theme.fontBody
            }

            T.TextField {
                id: field
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.textPrimary
                selectionColor: Theme.primarySubtle
                selectedTextColor: Theme.textPrimary
                font.pixelSize: Theme.fontBody
                EnterKey.type: control.enterKeyType
                onAccepted: control.accepted()

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    visible: field.displayText === "" && !field.inputMethodComposing
                    text: control.placeholderText
                    color: Theme.textSecondary
                    font: field.font
                    elide: Text.ElideRight
                }
            }
        }

        // Atingerea oriunde în căsuță (și pe prefix) pune cursorul în câmp.
        TapHandler {
            onTapped: field.forceActiveFocus()
        }
    }

    Text {
        Layout.fillWidth: true
        visible: text !== ""
        text: control.hasError ? control.errorText : control.helperText
        color: control.hasError ? Theme.danger : Theme.textSecondary
        font.pixelSize: Theme.fontCaption
        wrapMode: Text.WordWrap
    }
}
