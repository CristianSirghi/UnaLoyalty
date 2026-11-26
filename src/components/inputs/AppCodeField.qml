pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import UnaLoyalty

// Căsuțe pentru un cod din cifre, câte o cifră în fiecare (codul din SMS, un PIN):
//   AppCodeField {
//       length: 6
//       hasError: page.wrongCode                       // contur roșu
//       onCompleted: (code) => page.check(code)        // la ultima cifră
//   }
// Nu știe de unde vine codul: anunță doar când e complet. Cifrele se scriu într-un câmp
// ascuns (tastatura numerică); căsuțele doar le arată.
Item {
    id: control

    property int length: 6
    property bool hasError: false
    readonly property alias code: input.text

    signal completed(string code)

    function clear() {
        input.clear()
    }
    function focusField() {
        input.forceActiveFocus()
    }

    implicitWidth: cells.implicitWidth
    implicitHeight: Theme.touchTarget + Theme.spaceM

    TextInput {
        id: input
        anchors.fill: parent
        // Nevăzut, dar primește tastatura; căsuțele de deasupra arată cifrele.
        opacity: 0
        cursorVisible: false
        maximumLength: control.length
        inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
        validator: RegularExpressionValidator { regularExpression: /[0-9]*/ }
        onTextChanged: {
            if (text.length === control.length)
                control.completed(text)
        }
    }

    RowLayout {
        id: cells
        anchors.fill: parent
        spacing: Theme.spaceS

        Repeater {
            model: control.length

            Rectangle {
                id: cell
                required property int index
                readonly property bool current: input.activeFocus
                                                && index === Math.min(input.text.length,
                                                                      control.length - 1)

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radiusS
                color: Theme.surface
                border.width: cell.current || control.hasError ? 2 : 1
                border.color: control.hasError ? Theme.danger
                              : cell.current ? Theme.primary : Theme.border

                Text {
                    anchors.centerIn: parent
                    text: input.text.charAt(cell.index)
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontHeading
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    // Atingerea pe căsuțe deschide tastatura.
    TapHandler {
        onTapped: input.forceActiveFocus()
    }
}
