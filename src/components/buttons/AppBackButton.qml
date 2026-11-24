import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import UnaLoyalty

// Butonul „înapoi” din antetul paginilor: o săgeată, zonă de apăsare rotundă.
//   AppBackButton { onClicked: page.StackView.view.pop() }
AbstractButton {
    id: control

    implicitWidth: Theme.touchTarget
    implicitHeight: Theme.touchTarget

    Accessible.name: qsTr("Înapoi")

    background: Rectangle {
        radius: width / 2
        color: control.down ? Theme.surfaceMuted : "transparent"
    }

    contentItem: Item {
        // Săgeata, desenată pe o zonă de 24×24 în mijlocul butonului.
        Shape {
            anchors.centerIn: parent
            width: 24
            height: 24
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: Theme.textPrimary
                strokeWidth: 2
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                PathSvg { path: "M 15 6 L 9 12 L 15 18" }
            }
        }
    }
}
