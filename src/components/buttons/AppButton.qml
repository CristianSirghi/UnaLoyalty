import QtQuick
import QtQuick.Controls
import UnaLoyalty

// Butonul aplicației, cu stilul din Theme. Trei variante, aceeași formă:
//   AppButton { text: qsTr("Sign in") }                          // principal (plin)
//   AppButton { text: qsTr("Cancel"); variant: "secondary" } // contur
//   AppButton { text: qsTr("About"); variant: "text" }        // ca un link
//   AppButton { text: qsTr("Delete"); variant: "danger" }     // ca un link, roșu
//   AppButton { text: qsTr("Delete"); variant: "dangerFilled" } // plin, roșu
//   AppButton { text: qsTr("Continue"); busy: SessionService.busy } // rotiță, nu se apasă
//
// Pornește de la AbstractButton (nu de la Button): desenăm totul noi, deci arată la fel
// pe Android, iOS și Windows, indiferent de stilul Qt al platformei.
AbstractButton {
    id: control

    // "primary" | "secondary" | "text" | "danger" | "dangerFilled"
    property string variant: "primary"
    // Cât așteaptă ceva (ex. serverul): rotița în locul textului, apăsarea nu mai ajunge.
    property bool busy: false

    readonly property bool isPrimary: variant === "primary"
    readonly property bool isSecondary: variant === "secondary"
    readonly property bool isDanger: variant === "danger"
    readonly property bool isDangerFilled: variant === "dangerFilled"
    readonly property bool isFilled: isPrimary || isDangerFilled

    implicitWidth: Math.max(implicitContentWidth + leftPadding + rightPadding,
                            Theme.touchTarget)
    implicitHeight: Theme.touchTarget

    leftPadding: Theme.spaceXl
    rightPadding: Theme.spaceXl

    font.pixelSize: Theme.fontBody
    font.weight: Font.DemiBold

    opacity: enabled ? 1.0 : 0.5

    readonly property color foreground: isFilled ? Theme.textOnPrimary
                                        : isDanger ? Theme.danger : Theme.primary

    contentItem: Item {
        implicitWidth: label.implicitWidth
        implicitHeight: label.implicitHeight

        Text {
            id: label
            anchors.fill: parent
            visible: !control.busy
            text: control.text
            font: control.font
            color: control.foreground
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        // Rotița: trei sferturi de cerc care se învârt.
        AppIcon {
            anchors.centerIn: parent
            visible: control.busy
            size: 20
            path: "M 12 3 A 9 9 0 1 1 3 12"
            color: control.foreground

            RotationAnimator on rotation {
                running: control.busy && control.visible
                from: 0
                to: 360
                duration: 900
                loops: Animation.Infinite
            }
        }
    }

    background: Rectangle {
        radius: Theme.radiusS
        color: control.isPrimary ? (control.down ? Theme.primaryPressed : Theme.primary)
               : control.isDangerFilled ? (control.down ? Theme.dangerPressed : Theme.danger)
               : (control.down ? Theme.surfaceMuted : "transparent")
        border.width: control.isSecondary ? 1 : 0
        border.color: Theme.primary
    }

    // Cât e busy, apăsările se opresc aici și nu ajung la buton (enabled rămâne cum l-a
    // pus pagina, deci butonul nu se estompează).
    MouseArea {
        anchors.fill: parent
        enabled: control.busy
    }
}
