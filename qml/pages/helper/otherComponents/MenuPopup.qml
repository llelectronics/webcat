import QtQuick 2.0
import Sailfish.Silica 1.0

// This component displays a list of options on top of a page
Item {
    id: item
    property int menuTop: Theme.itemSizeMedium

    property string _selectedMenu: ""
    property Item _contextMenu
    property QtObject dataContainer

    function show()
    {
        if (!_contextMenu)
            _contextMenu = contextMenuComponent.createObject(rect);
        _selectedMenu = "";

        _contextMenu.show(rect);
    }

    Column {
        anchors.fill: parent

        Item {
            id: spacer
            width: parent.width
            height: menuTop
        }
        // bg rectangle for context menu so it covers underlying items
        Rectangle {
            id: rect
            color: "black"
            width: parent.width
            height: _contextMenu ? _contextMenu.height : 0
        }
    }

    Component {
        id: contextMenuComponent
        ContextMenu {

            // delayed action so that menu has already closed when page transition happens
            onClosed: {
                if (_selectedMenu === "fm") {
                    pageStack.push(Qt.resolvedUrl("../../OpenDialog.qml"), { dataContainer: dataContainer });

                } else if (_selectedMenu === "bm") {
                    pageStack.push(Qt.resolvedUrl("../../BackupPage.qml"));

                } else if (_selectedMenu === "vp") {
                    pageStack.push(Qt.resolvedUrl("../../VideoPlayer.qml"), { dataContainer: dataContainer});

                } else if (_selectedMenu === "dm") {
                   pageStack.push(Qt.resolvedUrl("../../DownloadManager.qml"));

                }
                _selectedMenu = "";
            }

            MenuItem {
                text: qsTr("File Manager")
                onClicked: _selectedMenu = "fm"
            }
            MenuItem {
                text: qsTr("Backup Manager")
                onClicked: _selectedMenu = "bm"
            }
            MenuItem {
                text: qsTr("Video Player")
                onClicked: _selectedMenu = "vp"
            }
            MenuItem {
                text: qsTr("Download Manager")
                onClicked: _selectedMenu = "dm"
            }
        }
    }

}
