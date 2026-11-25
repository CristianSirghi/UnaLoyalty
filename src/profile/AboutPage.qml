import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Despre aplicație: numele și versiunea. Se deschide din Profil.
// Versiunea vine din CMakeLists.txt (project(... VERSION ...)), prin main.cpp.
Page {
    id: page
    title: qsTr("About the app")

    background: Rectangle { color: Theme.background }

    ColumnLayout {
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

        AppPageHeader {
            Layout.fillWidth: true
            title: page.title
            onBackClicked: page.StackView.view.pop()
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: appColumn.implicitHeight + Theme.spaceXl * 2
            radius: Theme.radiusM
            color: Theme.surface

            ColumnLayout {
                id: appColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: Theme.spaceXl
                    rightMargin: Theme.spaceXl
                }
                spacing: Theme.spaceXxs

                Text {
                    Layout.fillWidth: true
                    // Numele aplicației nu se traduce.
                    text: Qt.application.name
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontSubheading
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: qsTr("Version %1").arg(Qt.application.version)
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontBodySmall
                    elide: Text.ElideRight
                }
            }
        }
    }
}
