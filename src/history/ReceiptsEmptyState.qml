import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import UnaLoyalty

// Ce se vede în locul bonurilor când cardul nu are încă niciunul:
// un desen simplu (un bon cu un „+”) și două rânduri de text.
ColumnLayout {
    id: root

    // Culoarea localului, pentru cercul cu „+”.
    property color accent: Theme.primary

    spacing: Theme.spaceS

    Item {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: 132
        implicitHeight: 104

        Rectangle {
            x: 18
            y: 4
            width: 96
            height: 96
            radius: 48
            color: Theme.surfaceMuted
        }

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            // Bonul
            ShapePath {
                fillColor: Theme.surface
                strokeColor: Theme.textSecondary
                strokeWidth: 2
                joinStyle: ShapePath.RoundJoin
                PathSvg { path: "M 44 22 H 80 V 80 L 74 76 L 68 80 L 62 76 L 56 80 L 50 76 L 44 80 Z" }
            }
            // Rândurile de pe bon
            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme.textSecondary
                strokeWidth: 2
                capStyle: ShapePath.RoundCap
                PathSvg { path: "M 52 36 H 72 M 52 46 H 72 M 52 56 H 64" }
            }
        }

        // Cercul cu „+”
        Rectangle {
            x: 74
            y: 56
            width: 28
            height: 28
            radius: 14
            color: root.accent

            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    strokeColor: Theme.textOnPrimary
                    strokeWidth: 2.5
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    PathSvg { path: "M 14 7 V 21 M 7 14 H 21" }
                }
            }
        }
    }

    Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Încă nu ai bonuri aici")
        color: Theme.textPrimary
        font.pixelSize: Theme.fontBody + 1
        font.weight: Font.DemiBold
        wrapMode: Text.WordWrap
    }
    Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Arată codul la casă și punctele apar după primul bon.")
        color: Theme.textSecondary
        font.pixelSize: Theme.fontBody - 1
        wrapMode: Text.WordWrap
    }
}
