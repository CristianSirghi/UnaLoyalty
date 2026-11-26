import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Un bon în „Ultimele bonuri”: o placă cu iconița, numărul și data la stânga,
// suma și punctele primite la dreapta. Câmpurile vin din rândul modelului
// (ReceiptsModel), după nume.
AbstractButton {
    id: row

    required property int serverId
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
    topPadding: Theme.spaceMPlus
    bottomPadding: Theme.spaceMPlus

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

            AppIcon {
                anchors.centerIn: parent
                size: 20
                path: "M 6 2 H 18 V 22 L 15 20 L 12 22 L 9 20 L 6 22 Z M 9 7 H 15 M 9 11 H 15 M 9 15 H 13"
                color: row.accent
            }
        }

        // Două rânduri independente: numărul cu suma, apoi data cu punctele. Așa numărul
        // împarte lățimea doar cu suma, nu și cu eticheta de puncte (care poate fi lată).
        // (Nu GridLayout: acolo coloana din dreapta ia lățimea celui mai lat element.)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spaceXxs

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceM

                Text {
                    Layout.fillWidth: true
                    text: qsTr("Receipt no. %1").arg(row.number)
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Text {
                    text: Format.money(row.total)
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.DemiBold
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceM

                Text {
                    Layout.fillWidth: true
                    text: Format.shortDateTime(row.dateTime)
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontCaption
                    elide: Text.ElideRight
                }
                Rectangle {
                    Layout.alignment: Qt.AlignRight
                    implicitWidth: chip.implicitWidth + Theme.spaceS * 2
                    implicitHeight: chip.implicitHeight + Theme.spaceXs
                    radius: height / 2
                    color: Qt.rgba(row.accent.r, row.accent.g, row.accent.b, 0.14)
                    visible: chip.text !== ""

                    Text {
                        id: chip
                        anchors.centerIn: parent
                        // Punctele primite și cele folosite, fiecare doar dacă nu e 0. „puncte”
                        // apare o dată: după primele, sau după cele folosite când sunt singure.
                        text: {
                            const parts = []
                            if (row.pointsEarned > 0)
                                parts.push(qsTr("+%1 points").arg(Format.points(row.pointsEarned)))
                            if (row.pointsSpent > 0)
                                parts.push(row.pointsEarned > 0
                                           ? qsTr("−%1").arg(Format.points(row.pointsSpent))
                                           : qsTr("−%1 points").arg(Format.points(row.pointsSpent)))
                            return parts.join("  ")
                        }
                        color: row.accent
                        font.pixelSize: Theme.fontSmall
                        font.weight: Font.DemiBold
                    }
                }
            }
        }
    }
}
