import QtQuick
import QtQuick.Controls
import UnaLoyalty

// Butonul aplicației, cu stilul din Theme. Trei variante, aceeași formă:
//   AppButton { text: qsTr("Sign in") }                          // principal (plin)
//   AppButton { text: qsTr("Cancel"); variant: "secondary" } // contur
//   AppButton { text: qsTr("About"); variant: "text" }        // ca un link
//
// Pornește de la AbstractButton (nu de la Button): desenăm totul noi, deci arată la fel
// pe Android, iOS și Windows, indiferent de stilul Qt al platformei.
AbstractButton {
    id: control

    // "primary" | "secondary" | "text"
    property string variant: "primary"

    readonly property bool isPrimary: variant === "primary"
    readonly property bool isSecondary: variant === "secondary"

    implicitWidth: Math.max(implicitContentWidth + leftPadding + rightPadding,
                            Theme.touchTarget)
    implicitHeight: Theme.touchTarget

    leftPadding: Theme.spaceXl
    rightPadding: Theme.spaceXl

    font.pixelSize: Theme.fontBody
    font.weight: Font.DemiBold

    opacity: enabled ? 1.0 : 0.5

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.isPrimary ? Theme.textOnPrimary : Theme.primary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: Theme.radiusS
        color: control.isPrimary
               ? (control.down ? Theme.primaryPressed : Theme.primary)
               : (control.down ? Theme.surfaceMuted : "transparent")
        border.width: control.isSecondary ? 1 : 0
        border.color: Theme.primary
    }
}
