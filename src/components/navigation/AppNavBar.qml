pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import UnaLoyalty

// Bara de jos a aplicației: un buton pe tab, cu iconiță și text.
//   AppNavBar {
//       tabs: [ { label: qsTr("Carduri"), icon: "M 2 5 H 22 ..." }, ... ]
//   }
// `icon` e un contur SVG pe o zonă de 24×24, desenat cu linie (ca iconițele din schemă).
// Pe telefon, bara se lungește sub bara de navigare a sistemului (SafeArea), ca
// butoanele să nu stea sub ea.
Item {
    id: bar

    property int currentIndex: 0
    property var tabs: []

    readonly property real bottomInset: bar.SafeArea.margins.bottom

    implicitHeight: 64 + bottomInset

    Rectangle {
        anchors.fill: parent
        color: Theme.surface

        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 1
            color: Theme.border
        }
    }

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 64
        spacing: 0

        Repeater {
            model: bar.tabs

            delegate: AbstractButton {
                id: tab

                required property var modelData
                required property int index

                readonly property bool current: index === bar.currentIndex
                readonly property color tint: current ? Theme.primary : Theme.textSecondary

                Layout.fillWidth: true
                Layout.fillHeight: true

                Accessible.role: Accessible.PageTab
                Accessible.name: modelData.label
                onClicked: bar.currentIndex = index

                background: Rectangle {
                    color: tab.down ? Theme.surfaceMuted : "transparent"
                }

                contentItem: Item {
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spaceXs

                        Shape {
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 24
                            implicitHeight: 24
                            preferredRendererType: Shape.CurveRenderer

                            ShapePath {
                                strokeColor: tab.tint
                                strokeWidth: 2
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap
                                joinStyle: ShapePath.RoundJoin
                                PathSvg { path: tab.modelData.icon }
                            }
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: tab.modelData.label
                            color: tab.tint
                            font.pixelSize: Theme.fontSmall
                            font.weight: tab.current ? Font.DemiBold : Font.Medium
                        }
                    }
                }
            }
        }
    }
}
