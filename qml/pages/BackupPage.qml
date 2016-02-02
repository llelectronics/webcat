import QtQuick 2.1
import Sailfish.Silica 1.0

Page {
    id: backupPage
    allowedOrientations: defaultAllowedOrientations

    SilicaFlickable {
        anchors.fill: parent

        Column {
            id: content
            anchors { left: parent.left; right: parent.right }

            PageHeader {
                title: qsTr("Backups")
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

            SectionHeader {
                text: qsTr("Backups are saved to home directory")
            }
        } // Column
    } // Flickable

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
            mainWindow.infoBanner.showText(qsTr("Backup saved successfully!"))
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



