import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import PageEnum 1.0
import Style 1.0

import "./"
import "../Controls2"
import "../Controls2/TextTypes"
import "../Config"

PageType {
    id: root

    FlickableType {
        id: flickable

        anchors.top: parent.top
        anchors.bottom: bottomBar.top

        contentHeight: content.implicitHeight + 16

        ColumnLayout {
            id: content

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            spacing: 0

            NavigationBarType {
                Layout.fillWidth: true

                title: qsTr("VPN Subscription")
                description: qsTr("Insert your subscription link (https://... or sub://...) to import nodes")
            }

            TextFieldType {
                id: textKey

                Layout.fillWidth: true
                Layout.rightMargin: 16
                Layout.leftMargin: 16

                headerText: qsTr("Subscription link or key")
                textField.placeholderText: "https://..."
                buttonText: textField.text === "" ? qsTr("Insert") : ""
                trailingIconSource: textField.text === "" ? "" : "qrc:/images/controls/close.svg"

                clickedFunc: function() {
                    textField.text = ""
                    textField.paste()
                }

                onTrailingClicked: {
                    textField.clear()
                    textField.forceActiveFocus()
                }
            }
        }
    }

    BottomBarType {
        id: bottomBar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        ButtonType {
            id: continueButton

            Layout.fillWidth: true

            enabled: textKey.textField.text.trim() !== ""
            text: qsTr("Continue")

            onClicked: {
                if (textKey.textField.text.trim() === "") {
                    return
                }
                PageController.showBusyIndicator(true)
                if (ImportController.extractConfigFromData(textKey.textField.text.trim())) {
                    PageController.showBusyIndicator(false)
                    PageController.goToPage(PageEnum.PageSetupWizardViewConfig)
                } else {
                    PageController.showBusyIndicator(false)
                }
            }
        }
    }
}
