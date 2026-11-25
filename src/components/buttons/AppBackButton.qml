import QtQuick
import UnaLoyalty

// Butonul „înapoi” din antetul paginilor: o săgeată, zonă de apăsare rotundă.
//   AppBackButton { onClicked: page.StackView.view.pop() }
AppIconButton {
    text: qsTr("Back")
    iconPath: "M 15 6 L 9 12 L 15 18"
    iconColor: Theme.textPrimary
}
