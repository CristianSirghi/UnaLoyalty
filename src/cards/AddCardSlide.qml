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
            strokeColor: Theme.bandOutline
            strokeWidth: 2
            strokeStyle: ShapePath.DashLine
            dashPattern: [3, 2]
            fillColor: control.down ? Theme.bandOverlayStrong : Theme.bandOverlay

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
                color: Theme.bandOverlayStrong

                AppIcon {
                    anchors.centerIn: parent
                    path: "M 12 5 V 19 M 5 12 H 19"
                    color: Theme.textOnPrimary
                }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Adaugă un card")
                color: Theme.textOnPrimary
                font.pixelSize: Theme.fontBodyLarge
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
