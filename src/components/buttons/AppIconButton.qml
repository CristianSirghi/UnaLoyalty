import QtQuick
import QtQuick.Controls
import UnaLoyalty

// Buton rotund doar cu iconiță (înapoi, mărire, închidere), cu zona de apăsare de
// Theme.touchTarget. `text` nu se vede: e numele citit de cititorul de ecran.
//   AppIconButton {
//       text: qsTr("Închide")
//       iconPath: "M 6 6 L 18 18 M 18 6 L 6 18"
//       iconSize: 20
//       color: Theme.cardSurfaceMuted          // fondul (implicit transparent)
//       pressedColor: Theme.cardSurfacePressed // fondul cât e apăsat
//   }
// `iconPath`, nu `icon`: AbstractButton are deja o proprietate `icon`.
AbstractButton {
    id: control

    property string iconPath
    property real iconSize: 24
    property color iconColor: Theme.textPrimary
    property color color: "transparent"
    property color pressedColor: Theme.surfaceMuted

    implicitWidth: Theme.touchTarget
    implicitHeight: Theme.touchTarget

    background: Rectangle {
        radius: width / 2
        color: control.down ? control.pressedColor : control.color
    }

    contentItem: Item {
        AppIcon {
            anchors.centerIn: parent
            size: control.iconSize
            path: control.iconPath
            color: control.iconColor
        }
    }
}
