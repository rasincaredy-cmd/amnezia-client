import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import QtCore

import PageEnum 1.0
import Style 1.0

import "./"
import "../Controls2"
import "../Controls2/TextTypes"
import "../Config"

PageType {
    id: root

    property bool isRestoringBackup: false

    Connections {
        target: ImportController

        function onQrDecodingFinished() {
            if (Qt.platform.os === "ios") {
                PageController.closePage()
            }
            PageController.goToPage(PageEnum.PageSetupWizardViewConfig)
        }
    }

    FlickableType {
        id: flickable

        anchors.top: parent.top

        contentHeight: Math.max(content.implicitHeight, flickable.height)

        ColumnLayout {
            id: content

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: flickable.contentHeight

            spacing: 0

            NavigationBarType {
                Layout.fillWidth: true

                title: qsTr("Connection")
                description: qsTr("Insert the key, add a configuration file or scan the QR-code")
                backButtonVisible: !PageController.isStartPageVisible() && root.stackView !== null && root.stackView.depth > 1
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                spacing: 12

                TextFieldType {
                    id: textKey

                    Layout.fillWidth: true

                    headerText: qsTr("Insert key")
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

                ButtonType {
                    id: continueButton

                    Layout.fillWidth: true

                    visible: textKey.textField.text !== ""

                    text: qsTr("Continue")

                    onClicked: {
                        if (ImportController.extractConfigFromData(textKey.textField.text)) {
                            PageController.goToPage(PageEnum.PageSetupWizardViewConfig)
                        }
                    }
                }
            }

            SmallTextType {
                Layout.fillWidth: true
                Layout.topMargin: 24
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                text: qsTr("Other connection options")
            }

            BasicCardType {
                Layout.fillWidth: true
                Layout.topMargin: 12
                Layout.rightMargin: 16
                Layout.leftMargin: 16

                text: qsTr("VPN Subscription")
                subtitle: qsTr("Import nodes from subscription URL")

                icon.source: "qrc:/images/controls/folder-search-2.svg"

                enabled: !root.isRestoringBackup

                onClicked: {
                    PageController.goToPage(PageEnum.PageSetupWizardTextKey)
                }
            }

            BasicCardType {
                Layout.fillWidth: true
                Layout.topMargin: 12
                Layout.rightMargin: 16
                Layout.leftMargin: 16

                text: qsTr("Self-hosted VPN")
                subtitle: qsTr("Configure Amnezia VPN on your own server")

                icon.source: "qrc:/images/controls/server.svg"

                enabled: !root.isRestoringBackup

                onClicked: PageController.goToPage(PageEnum.PageSetupWizardCredentials)
            }

            BasicCardType {
                Layout.fillWidth: true
                Layout.topMargin: 12
                Layout.rightMargin: 16
                Layout.leftMargin: 16

                visible: PageController.isStartPageVisible()

                text: qsTr("Restore from backup")

                icon.source: "qrc:/images/controls/archive-restore.svg"

                enabled: !root.isRestoringBackup

                onClicked: {
                    if (root.isRestoringBackup) {
                        return
                    }
                    var filePath = SystemController.getFileName(qsTr("Open backup file"),
                                                                qsTr("Backup files (*.backup)"))
                    if (filePath !== "") {
                        root.isRestoringBackup = true
                        PageController.showBusyIndicator(true)
                        Qt.callLater(function() {
                            SettingsController.restoreAppConfig(filePath)
                            PageController.showBusyIndicator(false)
                            root.isRestoringBackup = false
                        })
                    }
                }
            }

            BasicCardType {
                Layout.fillWidth: true
                Layout.topMargin: 12
                Layout.rightMargin: 16
                Layout.leftMargin: 16

                text: qsTr("File with connection settings")

                icon.source: "qrc:/images/controls/folder-search-2.svg"

                enabled: !root.isRestoringBackup

                onClicked: {
                    var nameFilter = "Config files (*.vpn *.ovpn *.conf *.json)"
                    var fileName = SystemController.getFileName(qsTr("Open config file"), nameFilter)
                    if (fileName !== "") {
                        if (ImportController.extractConfigFromFile(fileName)) {
                            PageController.goToPage(PageEnum.PageSetupWizardViewConfig)
                        }
                    }
                }
            }

            BasicCardType {
                Layout.fillWidth: true
                Layout.topMargin: 12
                Layout.rightMargin: 16
                Layout.leftMargin: 16

                visible: SettingsController.isCameraPresent()

                text: qsTr("QR code")

                icon.source: "qrc:/images/controls/scan-line.svg"

                enabled: !root.isRestoringBackup

                onClicked: {
                    ImportController.startDecodingQr()
                    if (Qt.platform.os === "ios") {
                        PageController.goToPage(PageEnum.PageSetupWizardQrReader)
                    }
                }
            }

            BasicCardType {
                Layout.fillWidth: true
                Layout.topMargin: 12
                Layout.rightMargin: 16
                Layout.leftMargin: 16

                visible: Qt.platform.os === "ios" || IsMacOsNeBuild || IsPlayBuild

                text: qsTr("Restore purchases")

                icon.source: "qrc:/images/controls/refresh-cw.svg"

                enabled: !root.isRestoringBackup

                onClicked: {
                    PageController.showBusyIndicator(true)
                    SubscriptionUiController.restoreServiceFromStore()
                    PageController.showBusyIndicator(false)
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
