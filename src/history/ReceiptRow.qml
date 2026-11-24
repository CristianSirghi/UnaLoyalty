import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import UnaLoyalty

// Un bon în „Ultimele bonuri”: o placă cu iconița, numărul și data la stânga,
// suma și punctele primite la dreapta. Câmpurile vin din rândul modelului
// (ReceiptsModel), după nume.
AbstractButton {
    id: row

    required property int receiptId
    required property string number
    required property date dateTime
    required property real total
    required property real pointsEarned
    required property real pointsSpent

    // Culoarea localului: iconița și eticheta cu puncte.
    property color accent: Theme.primary

    implicitWidth: content.implicitWidth + leftPadding + rightPadding
    implicitHeight: content.implicitHeight + topPadding + bottomPadding
    leftPadding: Theme.spaceL
    rightPadding: Theme.spaceL
    topPadding: 14
    bottomPadding: 14

    background: Rectangle {
        radius: Theme.radiusM
        color: row.down ? Theme.surfaceMuted : Theme.surface
    }

    contentItem: RowLayout {
        id: content
        spacing: Theme.spaceM

        // Iconița de bon
        Rectangle {
            implicitWidth: 42
            implicitHeight: 42
            radius: 21
            color: Theme.surfaceMuted

            Shape {
                anchors.centerIn: parent
                width: 24
                height: 24
                scale: 20 / 24
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    strokeColor: row.accent
                    strokeWidth: 2
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin
                    PathSvg { path: "M 6 2 H 18 V 22 L 15 20 L 12 22 L 9 20 L 6 22 Z M 9 7 H 15 M 9 11 H 15 M 9 15 H 13" }
                }
            }
        }

        // Numărul și data (fillWidth și pe texte: altfel coloana nu se lățește)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: qsTr("Bon nr. %1").arg(row.number)
                color: Theme.textPrimary
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: Format.dateTime(row.dateTime)
                color: Theme.textSecondary
                font.pixelSize: Theme.fontCaption
            }
        }

        // Suma și punctele
        ColumnLayout {
            spacing: Theme.spaceXs

            Text {
                Layout.alignment: Qt.AlignRight
                text: Format.money(row.total)
                color: Theme.textPrimary
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
            }
            Rectangle {
                Layout.alignment: Qt.AlignRight
                implicitWidth: chip.implicitWidth + Theme.spaceS * 2
                implicitHeight: chip.implicitHeight + 4
                radius: height / 2
                color: Qt.rgba(row.accent.r, row.accent.g, row.accent.b, 0.14)

                Text {
                    id: chip
                    anchors.centerIn: parent
                    // Punctele primite; dacă s-a plătit și cu puncte, apar și cele folosite.
                    text: {
                        let t = qsTr("+%1 puncte").arg(Format.points(row.pointsEarned))
                        if (row.pointsSpent > 0)
                            t += "  " + qsTr("−%1").arg(Format.points(row.pointsSpent))
                        return t
                    }
                    color: row.accent
                    font.pixelSize: Theme.fontSmall
                    font.weight: Font.DemiBold
                }
            }
        }
    }
}
