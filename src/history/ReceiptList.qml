pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Bonurile unui card, unul sub altul; atingerea unui bon îi deschide pagina în stackView.
// Folosită de portofel (ultimele bonuri) și de istoricul complet:
//   ReceiptList {
//       receipts: receiptsModel          // un ReceiptsModel
//       localName: "Etalonus"
//       accent: card.brandColor
//       stackView: page.StackView.view   // unde se deschide pagina bonului
//   }
ColumnLayout {
    id: list

    required property ReceiptsModel receipts
    property string localName
    property color accent: Theme.primary
    property StackView stackView

    spacing: Theme.spaceSPlus

    // Pagina unui bon; câmpurile i se dau la deschidere (push).
    Component {
        id: receiptDetails
        ReceiptDetailsPage {}
    }

    Repeater {
        model: list.receipts
        delegate: ReceiptRow {
            id: receiptRow
            Layout.fillWidth: true
            accent: list.accent
            onClicked: list.stackView.push(receiptDetails, {
                barcode: list.receipts.barcode,
                serverId: receiptRow.serverId,
                receiptId: receiptRow.receiptId,
                number: receiptRow.number,
                dateTime: receiptRow.dateTime,
                total: receiptRow.total,
                paid: receiptRow.paid,
                pointsEarned: receiptRow.pointsEarned,
                pointsSpent: receiptRow.pointsSpent,
                localName: list.localName
            })
        }
    }
}
