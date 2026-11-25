pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Câteva opțiuni lipite, una aleasă: o pastilă albă alunecă sub opțiunea aleasă.
// Componenta doar afișează și anunță ce a apăsat clientul; ce înseamnă alegerea
// decide pagina:
//   AppSegmentedControl {
//       options: [{ label: "Română", value: "ro" }, { label: "English", value: "en" }]
//       currentValue: ProfileService.language
//       onOptionSelected: (value) => ProfileService.language = value
//   }
// Opțiunile au lățimi egale, oricât de lung e textul.
Rectangle {
    id: control

    property var options: []
    property var currentValue

    signal optionSelected(var value)

    readonly property int currentIndex: {
        for (let i = 0; i < options.length; ++i) {
            if (options[i].value === currentValue)
                return i
        }
        return -1
    }
    readonly property real segmentWidth: options.length > 0
                                         ? (width - Theme.spaceXs * 2) / options.length : 0

    implicitWidth: 240
    implicitHeight: Theme.touchTarget + Theme.spaceXs
    radius: Theme.radiusS
    color: Theme.surfaceMuted

    // Pastila de sub opțiunea aleasă
    Rectangle {
        id: indicator
        x: Theme.spaceXs + control.currentIndex * control.segmentWidth
        y: Theme.spaceXs
        width: control.segmentWidth
        height: control.height - Theme.spaceXs * 2
        radius: control.radius - Theme.spaceXs
        color: Theme.surface
        visible: control.currentIndex >= 0

        Behavior on x {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
    }

    RowLayout {
        anchors {
            fill: parent
            margins: Theme.spaceXs
        }
        spacing: 0

        Repeater {
            model: control.options

            delegate: AbstractButton {
                id: segment

                required property var modelData
                required property int index
                readonly property bool selected: index === control.currentIndex

                Layout.fillWidth: true
                Layout.fillHeight: true
                // Greutate egală: altfel fillWidth împarte după lungimea textului.
                Layout.preferredWidth: 1

                text: modelData.label
                font.pixelSize: Theme.fontBodySmall
                font.weight: Font.DemiBold

                onClicked: {
                    if (!selected)
                        control.optionSelected(modelData.value)
                }

                contentItem: Text {
                    text: segment.text
                    font: segment.font
                    color: segment.selected ? Theme.primary : Theme.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight

                    Behavior on color { ColorAnimation { duration: 180 } }
                }

                // Opțiunea apăsată (încă nealeasă) se întunecă puțin
                background: Rectangle {
                    radius: indicator.radius
                    color: segment.down && !segment.selected ? Theme.border : "transparent"
                }
            }
        }
    }
}
