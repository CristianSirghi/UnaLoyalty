import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Profil: persoana (inițiale, nume, telefon), limba, despre aplicație, ieșirea din cont
// și ștergerea contului. Datele și limba le ține ProfileService (C++).
Page {
    id: page
    title: qsTr("Profile")

    background: Rectangle { color: Theme.background }

    Component { id: aboutPage; AboutPage {} }

    AppFlickable {
        anchors.fill: parent
        contentHeight: content.implicitHeight + content.anchors.topMargin + Theme.spaceXl

        ColumnLayout {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: Theme.spaceXl
                rightMargin: Theme.spaceXl
                // Pe telefon pagina începe sub bara de stare; titlul stă la aceeași
                // înălțime ca „My cards” din portofel.
                topMargin: page.SafeArea.margins.top + Theme.spaceXxl
            }
            spacing: Theme.spaceL

            Text {
                Layout.fillWidth: true
                Layout.bottomMargin: Theme.spaceS
                text: page.title
                color: Theme.textPrimary
                font.pixelSize: Theme.fontHeadingLarge
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            // ---- Persoana: cercul cu inițiale, numele, telefonul ----
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: personRow.implicitHeight + Theme.spaceXl * 2
                radius: Theme.radiusM
                color: Theme.surface

                RowLayout {
                    id: personRow
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: Theme.spaceXl
                        rightMargin: Theme.spaceXl
                    }
                    spacing: Theme.spaceL

                    Rectangle {
                        implicitWidth: 56
                        implicitHeight: 56
                        radius: width / 2
                        color: Theme.primarySubtle

                        Text {
                            anchors.centerIn: parent
                            text: ProfileService.initials
                            color: Theme.primary
                            font.pixelSize: Theme.fontHeadingSmall
                            font.weight: Font.Bold
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spaceXxs

                        Text {
                            Layout.fillWidth: true
                            text: ProfileService.name
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontSubheading
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: ProfileService.phone
                            color: Theme.textSecondary
                            font.pixelSize: Theme.fontBodySmall
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            // ---- Limba ----
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: languageColumn.implicitHeight + Theme.spaceL * 2
                radius: Theme.radiusM
                color: Theme.surface

                ColumnLayout {
                    id: languageColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: Theme.spaceXl
                        rightMargin: Theme.spaceXl
                    }
                    spacing: Theme.spaceSPlus

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Language")
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontBody
                    }
                    // Numele limbilor nu se traduc: fiecare e scris în limba lui.
                    AppSegmentedControl {
                        Layout.fillWidth: true
                        options: [
                            { label: "Română", value: "ro" },
                            { label: "Русский", value: "ru" },
                            { label: "English", value: "en" }
                        ]
                        currentValue: ProfileService.language
                        onOptionSelected: (value) => ProfileService.language = value
                    }
                }
            }

            // ---- Despre aplicație, ieșirea din cont ----
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: accountColumn.implicitHeight
                radius: Theme.radiusM
                color: Theme.surface

                ColumnLayout {
                    id: accountColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                    spacing: 0

                    ProfileRow {
                        Layout.fillWidth: true
                        text: qsTr("About the app")
                        showArrow: true
                        first: true
                        onClicked: page.StackView.view.push(aboutPage)
                    }
                    // Deocamdată nu face nimic: intrarea în cont nu există încă.
                    ProfileRow {
                        Layout.fillWidth: true
                        text: qsTr("Sign out")
                        last: true
                    }
                }
            }

            // Ștergerea contului: cerută de App Store. Deocamdată nu face nimic.
            AppButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Theme.spaceS
                variant: "danger"
                text: qsTr("Delete account")
            }
        }
    }

    AppStatusBarScrim { color: Theme.background }
}
