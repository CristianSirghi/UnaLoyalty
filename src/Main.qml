import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Doar navigarea: bara de jos (Carduri / Profil) și pagina tabului ales.
// Ce e pe fiecare pagină stă în folderul funcționalității (src/cards, src/profile).
Window {
    width: 400
    height: 800
    visible: true
    title: "UnaLoyalty"
    color: Theme.background

    // Butonul „înapoi” al telefonului închide fereastra: întâi ne întoarcem
    // o pagină în tabul deschis; aplicația se închide doar de pe prima pagină.
    onClosing: (close) => {
        if (tabs.currentIndex === 0 && cardsStack.depth > 1) {
            close.accepted = false
            cardsStack.pop()
        }
    }

    // Conținutul stă în zona sigură (fără bara de stare și bara de navigare a
    // telefonului); fundalul ferestrei rămâne pe tot ecranul.
    ColumnLayout {
        anchors {
            fill: parent
            topMargin: parent.SafeArea.margins.top
            leftMargin: parent.SafeArea.margins.left
            rightMargin: parent.SafeArea.margins.right
            bottomMargin: parent.SafeArea.margins.bottom
        }
        spacing: 0

        // StackLayout ține ambele taburi în viață: la întoarcerea pe un tab,
        // pagina e cum a lăsat-o clientul (poziția în listă, cardul deschis etc.).
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabs.currentIndex

            // Tabul Carduri are propriul șir de pagini: lista → cardul deschis.
            // Paginile deschid alte pagini prin page.StackView.view.push(...).
            StackView {
                id: cardsStack
                initialItem: CardListPage {}
            }
            ProfilePage {}
        }

        TabBar {
            id: tabs
            Layout.fillWidth: true

            TabButton { text: qsTr("Carduri") }
            TabButton { text: qsTr("Profil") }
        }
    }
}
