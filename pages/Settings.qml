// Copyright (c) 2014-2018, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import "../version.js" as Version


import "../components"
import moneroComponents.Clipboard 1.0

Rectangle {
    property bool viewOnly: false
    id: page

    color: "transparent"

    Clipboard { id: clipboard }

    function initSettings() {
        //runs on every page load
    }

    ColumnLayout {
        id: mainLayout
        anchors.margins: 17 * scaleRatio
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 10 * scaleRatio

        //! Manage wallet
        RowLayout {
            Label {
                id: manageWalletLabel
                Layout.fillWidth: true
                text: qsTr("Manage wallet") + translationManager.emptyString
                Layout.topMargin: 10 * scaleRatio
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Style.dividerColor
            opacity: Style.dividerOpacity
        }

        GridLayout {
            columns: (isMobile)? 1 : 4
            StandardButton {
                id: closeWalletButton
                text: qsTr("Close wallet") + translationManager.emptyString
                visible: true
                onClicked: {
                    console.log("closing wallet button clicked")
                    appWindow.showWizard();
                }
            }

            StandardButton {
                enabled: !viewOnly
                id: createViewOnlyWalletButton
                text: qsTr("Create view only wallet") + translationManager.emptyString
                visible: true
                onClicked: {
                    wizard.openCreateViewOnlyWalletPage();
                }
            }

/*          Rescan cache - Disabled until we know it's needed

            StandardButton {
                id: rescanWalletbutton
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                text: qsTr("Rescan wallet cache") + translationManager.emptyString
                onClicked: {
                    // Show confirmation dialog
                    confirmationDialog.title = qsTr("Rescan wallet cache") + translationManager.emptyString;
                    confirmationDialog.text  = qsTr("Are you sure you want to rebuild the wallet cache?\n"
                                                    + "The following information will be deleted\n"
                                                    + "- Recipient addresses\n"
                                                    + "- Tx keys\n"
                                                    + "- Tx descriptions\n\n"
                                                    + "The old wallet cache file will be renamed and can be restored later.\n"
                                                    );
                    confirmationDialog.icon = StandardIcon.Question
                    confirmationDialog.cancelText = qsTr("Cancel")
                    confirmationDialog.onAcceptedCallback = function() {
                        walletManager.closeWallet();
                        walletManager.clearWalletCache(persistentSettings.wallet_path);
                        walletManager.openWalletAsync(persistentSettings.wallet_path, appWindow.walletPassword,
                                                          persistentSettings.nettype);
                    }

                    confirmationDialog.onRejectedCallback = null;

                    confirmationDialog.open()

                }
            }
*/
            StandardButton {
                id: rescanSpentButton
                enabled: !persistentSettings.useRemoteNode
                text: qsTr("Rescan wallet balance") + translationManager.emptyString
                onClicked: {
                    if (!currentWallet.rescanSpent()) {
                        console.error("Error: ", currentWallet.errorString);
                        informationPopup.title = qsTr("Error") + translationManager.emptyString;
                        informationPopup.text  = qsTr("Error: ") + currentWallet.errorString
                        informationPopup.icon  = StandardIcon.Critical
                        informationPopup.onCloseCallback = null
                        informationPopup.open();
                    } else {
                        informationPopup.title = qsTr("Information") + translationManager.emptyString
                        informationPopup.text  = qsTr("Successfully rescanned spent outputs.") + translationManager.emptyString
                        informationPopup.icon  = StandardIcon.Information
                        informationPopup.onCloseCallback = null
                        informationPopup.open();
                    }
                }
            }

            StandardButton {
                id: changePasswordButton
                text: qsTr("Change password") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                onClicked: {
                    passwordDialog.onAcceptedCallback = function() {
                        if(appWindow.walletPassword === passwordDialog.password){
                            newPasswordDialog.open()
                        } else {
                            informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                            informationPopup.text = qsTr("Wrong password");
                            informationPopup.open()
                            informationPopup.onCloseCallback = function() {
                                changePasswordDialog.open()
                            }
                            passwordDialog.open()
                        }
                    }
                    passwordDialog.onRejectedCallback = null;
                    passwordDialog.open()
                }
            }
        }

        RowLayout {

            StandardButton {
                id: remoteDisconnect
                enabled: persistentSettings.useRemoteNode
                Layout.fillWidth: false
                text: qsTr("Local Node") + translationManager.emptyString
                onClicked: {
                    appWindow.disconnectRemoteNode();
                }
            }

            StandardButton {
                id: remoteConnect
                enabled: !persistentSettings.useRemoteNode
                Layout.fillWidth: false
                text: qsTr("Remote Node") + translationManager.emptyString
                onClicked: {
                    appWindow.connectRemoteNode();
                }
            }
        }

        //! Manage daemon
        RowLayout {
            visible: !isMobile
            Layout.topMargin: 20
            Label {
                id: manageDaemonLabel
                text: qsTr("Manage Daemon") + translationManager.emptyString
            }

            CheckBox {
                id: daemonAdvanced
                Layout.leftMargin: 15
                text: qsTr("Show advanced") + translationManager.emptyString
            }
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Style.dividerColor
            opacity: Style.dividerOpacity
        }

        GridLayout {
            visible: !isMobile && !persistentSettings.useRemoteNode
            id: daemonStatusRow
            columns: (isMobile) ?  2 : 4
            StandardButton {
                visible: !appWindow.daemonRunning
                id: startDaemonButton
                text: qsTr("Start Local Node") + translationManager.emptyString
                onClicked: {
                    // Update bootstrap daemon address
                    persistentSettings.bootstrapNodeAddress = bootstrapNodeEdit.daemonAddrText ? bootstrapNodeEdit.getAddress() : "";

                    // Set current daemon address to local
                    appWindow.currentDaemonAddress = appWindow.localDaemonAddress
                    appWindow.startDaemon(daemonFlags.text)
                }
            }

            StandardButton {
                visible: appWindow.daemonRunning
                id: stopDaemonButton
                text: qsTr("Stop Local Node") + translationManager.emptyString
                onClicked: {
                    appWindow.stopDaemon()
                }
            }

            StandardButton {
                visible: true
                id: daemonStatusButton
                text: qsTr("Show status") + translationManager.emptyString
                onClicked: {
                    daemonManager.sendCommand("status",currentWallet.nettype);
                    daemonConsolePopup.open();
                }
            }
        }

        ColumnLayout {
            id: blockchainFolderRow
            visible: !isMobile && !persistentSettings.useRemoteNode
            Label {
                id: blockchainFolderLabel
                text: qsTr("Blockchain location") + translationManager.emptyString
            }
            LineEdit {
                id: blockchainFolder
                Layout.preferredWidth:  200
                Layout.fillWidth: true
                labelText: qsTr("Blockchain location") + translationManager.emptyString
                text: persistentSettings.blockchainDataDir
                placeholderText: qsTr("(optional)") + translationManager.emptyString

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mouse.accepted = false
                        if(persistentSettings.blockchainDataDir != "")
                            blockchainFileDialog.folder = "file://" + persistentSettings.blockchainDataDir
                        blockchainFileDialog.open()
                        blockchainFolder.focus = true
                    }
                }

            }
        }


        RowLayout {
            visible: daemonAdvanced.checked && !isMobile && !persistentSettings.useRemoteNode
            id: daemonFlagsRow
            Label {
                id: daemonFlagsLabel
                text: qsTr("Local daemon startup flags") + translationManager.emptyString
            }
            LineEdit {
                id: daemonFlags
                Layout.preferredWidth:  200
                Layout.fillWidth: true
                text: appWindow.persistentSettings.daemonFlags;
                placeholderText: qsTr("(optional)") + translationManager.emptyString
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: (daemonAdvanced.checked || isMobile) && persistentSettings.useRemoteNode
            Label {
                id: daemonLoginLabel
                Layout.fillWidth: true
                text: qsTr("Node login (optional)") + translationManager.emptyString
            }

        }

        ColumnLayout {
            visible: (daemonAdvanced.checked || isMobile) && persistentSettings.useRemoteNode
            LineEdit {
                id: daemonUsername
                Layout.preferredWidth:  100 * scaleRatio
                Layout.fillWidth: true
                text: persistentSettings.daemonUsername
                placeholderText: qsTr("Username") + translationManager.emptyString
            }


            LineEdit {
                id: daemonPassword
                Layout.preferredWidth: 100 * scaleRatio
                Layout.fillWidth: true
                text: persistentSettings.daemonPassword
                placeholderText: qsTr("Password") + translationManager.emptyString
                echoMode: TextInput.Password
            }
        }

        RowLayout {
            visible: !isMobile && !persistentSettings.useRemoteNode
            ColumnLayout {
                Label {
                    color: "#4A4949"
                    text: qsTr("Bootstrap node (leave blank if not wanted)") + translationManager.emptyString
                }
                RemoteNodeEdit {
                    id: bootstrapNodeEdit
                    Layout.minimumWidth: 100 * scaleRatio
                    daemonAddrText: persistentSettings.bootstrapNodeAddress.split(":")[0].trim()
                    daemonPortText: (persistentSettings.bootstrapNodeAddress.split(":")[1].trim() == "") ? "18081" : persistentSettings.bootstrapNodeAddress.split(":")[1]
                    onEditingFinished: {
                        persistentSettings.bootstrapNodeAddress = daemonAddrText ? bootstrapNodeEdit.getAddress() : "";
                        console.log("setting bootstrap node to " + persistentSettings.bootstrapNodeAddress)
                    }
                }
            }
        }

        RowLayout {
            visible: persistentSettings.useRemoteNode
            ColumnLayout {
                Label {
                    text: qsTr("Remote node") + translationManager.emptyString
                }
                RemoteNodeEdit {
                    id: remoteNodeEdit
                    Layout.minimumWidth: 100 * scaleRatio
                    property var rna: persistentSettings.remoteNodeAddress
                    daemonAddrText: rna.search(":") != -1 ? rna.split(":")[0].trim() : ""
                    daemonPortText: rna.search(":") != -1 ? (rna.split(":")[1].trim() == "") ? "18081" : rna.split(":")[1] : ""
                    onEditingFinished: {
                        persistentSettings.remoteNodeAddress = remoteNodeEdit.getAddress();
                        console.log("setting remote node to " + persistentSettings.remoteNodeAddress)
                    }
                }

                StandardButton {
                    id: remoteNodeSave
                    text: qsTr("Connect") + translationManager.emptyString
                    onClicked: {
                        // Update daemon login
                        persistentSettings.remoteNodeAddress = remoteNodeEdit.getAddress();
                        persistentSettings.daemonUsername = daemonUsername.text;
                        persistentSettings.daemonPassword = daemonPassword.text;
                        persistentSettings.useRemoteNode = true

                        currentWallet.setDaemonLogin(persistentSettings.daemonUsername, persistentSettings.daemonPassword);

                        appWindow.connectRemoteNode()
                    }
                }
            }
        }

        RowLayout {
            visible: !isMobile
            Label {
                text: qsTr("Layout settings") + translationManager.emptyString
                anchors.topMargin: 30 * scaleRatio
                Layout.topMargin: 30 * scaleRatio
            }
        }
        Rectangle {
            visible: !isMobile
            Layout.fillWidth: true
            height: 1
            color: Style.dividerColor
            opacity: Style.dividerOpacity
        }

        RowLayout {
            CheckBox {
                visible: !isMobile
                id: customDecorationsCheckBox
                checked: persistentSettings.customDecorations
                onClicked: appWindow.setCustomWindowDecorations(checked)
                text: qsTr("Custom decorations") + translationManager.emptyString
            }
        }

        // Log level

        RowLayout {
            Label {
                text: qsTr("Log level") + translationManager.emptyString
                anchors.topMargin: 30 * scaleRatio
                Layout.topMargin: 30 * scaleRatio
            }
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Style.dividerColor
            opacity: Style.dividerOpacity
        }
        ColumnLayout {
            ComboBox {
                id: logLevel
                model: [0,1,2,3,4,"custom"]
                currentIndex : appWindow.persistentSettings.logLevel;
                onCurrentIndexChanged: {
                    if (currentIndex == 5) {
                        console.log("log categories changed: ", logCategories.text);
                        walletManager.setLogCategories(logCategories.text);
                    }
                    else {
                        console.log("log level changed: ",currentIndex);
                        walletManager.setLogLevel(currentIndex);
                    }
                    appWindow.persistentSettings.logLevel = currentIndex;
                }
            }

            LineEdit {
                id: logCategories
                Layout.fillWidth: true
                text: appWindow.persistentSettings.logCategories
                placeholderText: qsTr("(e.g. *:WARNING,net.p2p:DEBUG)") + translationManager.emptyString
                enabled: logLevel.currentIndex == 5
                onEditingFinished: {
                    if(enabled) {
                        console.log("log categories changed: ", text);
                        walletManager.setLogCategories(text);
                        appWindow.persistentSettings.logCategories = text;
                    }
                }
            }
        }

        // Version
        RowLayout {
            Label {
                text: qsTr("Debug info") + translationManager.emptyString
                fontSize: 16
                anchors.topMargin: 30 * scaleRatio
                Layout.topMargin: 30 * scaleRatio
            }
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Style.dividerColor
            opacity: Style.dividerOpacity
        }
        TextBlock {
            Layout.topMargin: 8
            Layout.fillWidth: true
            text: qsTr("GUI version: ") + Version.GUI_VERSION + translationManager.emptyString
        }
        TextBlock {
            id: guiMoneroVersion
            Layout.fillWidth: true
            text: qsTr("Embedded Monero version: ") + Version.GUI_MONERO_VERSION + translationManager.emptyString
        }
        TextBlock {
            id: restoreHeightText
            Layout.fillWidth: true
            textFormat: Text.RichText
            property var txt: "<style type='text/css'>a {text-decoration: none; color: #FF6C3C}</style>" + qsTr("Wallet creation height: ") + (currentWallet ? currentWallet.walletCreationHeight : "") + translationManager.emptyString
            property var linkTxt: qsTr(" <a href='#'>(Click to change)</a>") + translationManager.emptyString
            text: (typeof currentWallet == "undefined") ? "" : txt + linkTxt

            onLinkActivated: {
                restoreHeightRow.visible = true;
            }

        }

        RowLayout {
            id: restoreHeightRow
            visible: false
            LineEdit {
                id: restoreHeight
                Layout.preferredWidth: 80
                Layout.fillWidth: true
                text: currentWallet ? currentWallet.walletCreationHeight : "0"
                validator: IntValidator {
                    bottom:0
                }
            }

            StandardButton {
                id: restoreHeightSave
                Layout.fillWidth: false
                Layout.leftMargin: 30
                text: qsTr("Save") + translationManager.emptyString

                onClicked: {
                    currentWallet.walletCreationHeight = restoreHeight.text
                    // Restore height is saved in .keys file. Set password to trigger rewrite.
                    currentWallet.setPassword(appWindow.walletPassword)
                    restoreHeightRow.visible = false

                    // Show confirmation dialog
                    confirmationDialog.title = qsTr("Rescan wallet cache") + translationManager.emptyString;
                    confirmationDialog.text  = qsTr("Are you sure you want to rebuild the wallet cache?\n"
                                                    + "The following information will be deleted\n"
                                                    + "- Recipient addresses\n"
                                                    + "- Tx keys\n"
                                                    + "- Tx descriptions\n\n"
                                                    + "The old wallet cache file will be renamed and can be restored later.\n"
                                                    );
                    confirmationDialog.icon = StandardIcon.Question
                    confirmationDialog.cancelText = qsTr("Cancel")
                    confirmationDialog.onAcceptedCallback = function() {
                        walletManager.closeWallet();
                        walletManager.clearWalletCache(persistentSettings.wallet_path);
                        walletManager.openWalletAsync(persistentSettings.wallet_path, appWindow.walletPassword,
                                                          persistentSettings.nettype);
                    }

                    confirmationDialog.onRejectedCallback = null;

                    confirmationDialog.open()

                }
            }
        }



        TextBlock {
            Layout.fillWidth: true
            text:  (!currentWallet) ? "" : qsTr("Wallet log path: ") + currentWallet.walletLogPath + translationManager.emptyString
        }
        TextBlock {
            Layout.fillWidth: true
            text: qsTr("Wallet Name: ") + walletName + translationManager.emptyString
        }
        TextBlock {
            Layout.fillWidth: true
            text:  (!currentWallet) ? "" : qsTr("Daemon log path: ") + currentWallet.daemonLogPath + translationManager.emptyString
        }
    }

    // Daemon console
    DaemonConsole {
        id: daemonConsolePopup
        height:500
        width:800
        title: qsTr("Daemon log") + translationManager.emptyString
        onAccepted: {
            close();
        }
    }

    // Choose blockchain folder
    FileDialog {
        id: blockchainFileDialog
        title: qsTr("Please choose a folder") + translationManager.emptyString;
        selectFolder: true
        folder: "file://" + persistentSettings.blockchainDataDir

        onAccepted: {
            var dataDir = walletManager.urlToLocalPath(blockchainFileDialog.fileUrl)
            var validator = daemonManager.validateDataDir(dataDir);
            if(!validator.valid) {

                confirmationDialog.title = qsTr("Warning") + translationManager.emptyString;
                confirmationDialog.text = "";
                if(validator.readOnly) {
                    confirmationDialog.text  += qsTr("Error: Filesystem is read only") + "\n\n"                  
                }
                
                if(validator.storageAvailable < 20) {
                    confirmationDialog.text  += qsTr("Warning: There's only %1 GB available on the device. Blockchain requires ~%2 GB of data.").arg(validator.storageAvailable).arg(15) + "\n\n"     
                } else {
                    confirmationDialog.text  += qsTr("Note: There's %1 GB available on the device. Blockchain requires ~%2 GB of data.").arg(validator.storageAvailable).arg(15) + "\n\n"
                }
                
                if(!validator.lmdbExists) {
                    confirmationDialog.text  += qsTr("Note: lmdb folder not found. A new folder will be created.") + "\n\n" 
                }

                confirmationDialog.icon = StandardIcon.Question
                confirmationDialog.cancelText = qsTr("Cancel")

                // Continue
                confirmationDialog.onAcceptedCallback = function() {
                    persistentSettings.blockchainDataDir = dataDir
                }

                // Cancel
                confirmationDialog.onRejectedCallback = function() {
                };

                confirmationDialog.open()
            } else {
                persistentSettings.blockchainDataDir = dataDir
            }

            delete validator;


        }
        onRejected: {
            console.log("data dir selection canceled")
        }

    }

    // fires on every page load
    function onPageCompleted() {
        console.log("Settings page loaded");
        initSettings();


        if(typeof daemonManager != "undefined")
            appWindow.daemonRunning =  daemonManager.running(persistentSettings.nettype)
    }

    // fires only once
    Component.onCompleted: {
        if(typeof daemonManager != "undefined")
            daemonManager.daemonConsoleUpdated.connect(onDaemonConsoleUpdated)
    }

    function onDaemonConsoleUpdated(message){
        // Update daemon console
        daemonConsolePopup.textArea.append(message)
    }




}




