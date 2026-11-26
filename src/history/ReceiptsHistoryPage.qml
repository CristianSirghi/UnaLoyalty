pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Istoricul complet al unui card („Toate” de lângă „Ultimele bonuri”): toate bonurile,
// cele mai noi primele. Se deschide cu push, cu câmpurile de mai jos.
Page {
    id: page

    required property string barcode     // codul cardului
    required property string localName   // localul cardului
    required property color accent       // culoarea localului

    title: qsTr("All receipts")

    background: Rectangle { color: Theme.background }

    // Toate bonurile cardului, de pe server (fără limită).
    // (id-ul nu e „receipts”: ReceiptList are o proprietate cu numele ăsta.)
    ReceiptsModel {
        id: allReceipts
        barcode: page.barcode
    }

    AppFlickable {
        anchors.fill: parent
        contentHeight: content.implicitHeight + Theme.spaceXl

        ColumnLayout {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: Theme.spaceXl
                rightMargin: Theme.spaceXl
                // Pe telefon pagina începe sub bara de stare.
                topMargin: page.SafeArea.margins.top + Theme.spaceL
            }
            spacing: Theme.spaceL

            // Antet: înapoi + titlul, iar dedesubt localul
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceXxs

                AppPageHeader {
                    Layout.fillWidth: true
                    title: page.title
                    onBackClicked: page.StackView.view.pop()
                }
                Text {
                    Layout.fillWidth: true
                    text: page.localName
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontBodySmall
                    elide: Text.ElideRight
                }
            }

            ReceiptList {
                Layout.fillWidth: true
                receipts: allReceipts
                localName: page.localName
                accent: page.accent
                stackView: page.StackView.view
            }

            ReceiptsEmptyState {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spaceXl
                Layout.rightMargin: Theme.spaceXl
                Layout.topMargin: Theme.spaceXl
                // Nu cât încă se încarcă: altfel ar apărea o clipă „fără bonuri”.
                visible: allReceipts.count === 0 && !allReceipts.loading
                accent: page.accent
            }
        }
    }

    // Pe telefon: conținutul derulat trece pe sub fâșia asta, nu pe sub ora din bara de stare.
    AppStatusBarScrim {
        color: Theme.background
    }
}
