import QtQuick 2.1
import Sailfish.Silica 1.0

Page {
    id: backupPage
    allowedOrientations: defaultAllowedOrientations

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            anchors { left: parent.left; right: parent.right }
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Backups")
            }
            Column {
                anchors { left: parent.left; right: parent.right }
                SectionHeader {
                    text: qsTr("Backups are saved to Documents directory")
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.None
                }

                Button {
                    id: createBackupButton
                    text: qsTr("Create Backup")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        busy.running = true;
                        _myClass.backupConfig();
                    }
                }

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium
                    width: parent.width - (2 * Theme.paddingMedium)
                    wrapMode: Text.Wrap
                    height: text.length ? (implicitHeight + Theme.paddingMedium) : 0
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    text: qsTr("The Backup includes all cookies, bookmarks, history and settings for Webcat.")
                }
            }
            Column {
                anchors { left: parent.left; right: parent.right }
                SectionHeader {
                    text: qsTr("Backups overwrite current configurations")
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.None
                }

                Button {
                    id: restoreBackupButton
                    text: qsTr("Restore Backup")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        var openDialog = pageStack.push(Qt.resolvedUrl("OpenDialog.qml"),
                                                        {"dataContainer":  flick, "selectMode": true, "filter" : [ "*.tar.gz", "*.gz" ]})
                        openDialog.fileOpen.connect(function(file) {
                            remorse.execute(qsTr("Restoring Backup"), function() {
                                busy.running = true;
                                _myClass.checkBackup(file);
                            } )
                        })
                    }
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium
                    width: parent.width - (2 * Theme.paddingMedium)
                    wrapMode: Text.Wrap
                    height: text.length ? (implicitHeight + Theme.paddingMedium) : 0
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    text: qsTr("Restoring overwrites all cookies, bookmarks, history and settings for Webcat from the backup file.
Please restart for changes to take effect.")
                }
            }

        } // Column
    } // Flickable

    RemorsePopup {
        id: remorse
    }

    Rectangle {
        color: "black"
        opacity: 0.60
        anchors.fill: parent
        visible: {
            if (busy.running) return true;
            else if (errTxt.visible) return true;
            else return false;
        }
    }

    BusyIndicator {
        id: busy
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: false
        visible: running
    }
    MouseArea {
        z: 99
        id: blockInput
        anchors.fill: parent
        visible: busy.running
        enabled: busy.running
    }

    TextArea {
        id: errTxt
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingLarge * 2
        height: parent.height - (dismissBtn.height * 2 + Theme.paddingLarge * 2)
        width: parent.width
        //font.pointSize: Theme.fontSizeSmall
        color: Theme.primaryColor
        visible: false
        background: null
        wrapMode: TextEdit.WordWrap
    }
    Button {
        id: dismissBtn
        anchors.top: errTxt.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        visible: errTxt.visible
        text: qsTr("Dismiss")
        onClicked: {
            if (errTxt.visible) errTxt.visible = false;
        }
    }
    Connections {
        target: _myClass
        onBackupComplete: {
            busy.running = false
            mainWindow.infoBanner.parent = backupPage
            mainWindow.infoBanner.anchors.top = backupPage.top
            mainWindow.infoBanner.showText(qsTr("Backup saved successfully!"))
        }
        onRestoreComplete: {
            busy.running = false
            mainWindow.infoBanner.parent = backupPage
            mainWindow.infoBanner.anchors.top = backupPage.top
            mainWindow.infoBanner.showText(qsTr("Backup restored! Please restart Webcat"))
        }
        onError: {
            busy.running = false
            if (message != "") {
                errTxt.text = message
                errTxt.visible = true
            }
        }
    }
}



