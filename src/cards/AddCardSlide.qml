import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import UnaLoyalty

// Ultimul „card” din portofel: locul pentru un card nou, cu contur punctat.
// Stă pe banda colorată, deci e alb pe culoare. Deocamdată nu face nimic.
AbstractButton {
    id: control

    implicitWidth: 300
    implicitHeight: 300

    Accessible.name: qsTr("Adaugă un card de la alt local")

    background: Shape {
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: Qt.rgba(1, 1, 1, 0.65)
            strokeWidth: 2
            strokeStyle: ShapePath.DashLine
            dashPattern: [3, 2]
            fillColor: Qt.rgba(1, 1, 1, control.down ? 0.22 : 0.12)

            PathRectangle {
                x: 1
                y: 1
                width: control.width - 2
                height: control.height - 2
                radius: Theme.radiusL
            }
        }
    }

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spaceM

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 52
                implicitHeight: 52
                radius: 26
                color: Qt.rgba(1, 1, 1, 0.22)

                Shape {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    preferredRendererType: Shape.CurveRenderer

                    ShapePath {
                        strokeColor: Theme.textOnPrimary
                        strokeWidth: 2
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        PathSvg { path: "M 12 5 V 19 M 5 12 H 19" }
                    }
                }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Adaugă un card")
                color: Theme.textOnPrimary
                font.pixelSize: Theme.fontBody + 1
                font.weight: Font.DemiBold
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("de la alt local UNA")
                color: Theme.textOnPrimaryMuted
                font.pixelSize: Theme.fontCaption
            }
        }
    }
}
