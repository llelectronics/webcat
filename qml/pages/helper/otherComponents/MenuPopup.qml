import QtQuick 2.0
import Sailfish.Silica 1.0

// This component displays a list of options on top of a page
Item {
    id: item
    property int menuTop: Theme.itemSizeMedium

    property string _selectedMenu: ""
    property Item _contextMenu
    property QtObject dataContainer

    signal menuClosed;

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
            id: ctm
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

                } else if (_selectedMenu === "fmCreateIcon") {
                    var favIconPath = _fm.getRoot() + "/usr/share/harbour-webcat/qml/pages/img/fileman.png"
                    //console.debug("[FirstPage.qml] Saving FavIcon: " + savingFav)
                    mainWindow.infoBanner.parent = fPage
                    mainWindow.infoBanner.anchors.top = fPage.top
                    mainWindow.createDesktopLauncher(favIconPath ,"Webcat Fileman","about:file");
                    mainWindow.infoBanner.showText(qsTr("Created Desktop Launcher for " + "Webcat Fileman"));
                }
                menuClosed();
                _selectedMenu = "";
            }

            MenuItem {
                text: qsTr("File Manager")
                onClicked: _selectedMenu = "fm"
                IconButton {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium
                    height: parent.height
                    width: height
                    icon.source: "image://theme/icon-s-favorite"
                    onClicked: {
                        _selectedMenu = "fmCreateIcon"
                        ctm.hide()
                    }

                }
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
