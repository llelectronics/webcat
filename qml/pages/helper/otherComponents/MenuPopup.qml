import QtQuick 2.0
import Sailfish.Silica 1.0
import "../browserComponents"

// This component displays a list of options on top of a page
Item {
    id: item
    property int menuTop: Theme.itemSizeMedium

    property string _selectedMenu: ""
    property Item _contextMenu
    property QtObject dataContainer


   property var menuItems: [
        {
            txt: qsTr("File Manager"),
            cmd: "fm",
            extraCmd: "fmCreateIcon"
        },
        {
            txt: qsTr("Backup Manager"),
            cmd: "bm",
            extraCmd: ""
        },
        {
            txt: qsTr("Video Player"),
            cmd: "vp",
            extraCmd: ""
        },
        {
            txt: qsTr("Download Manager"),
            cmd: "dm",
            extraCmd: ""
        }
    ]

    signal menuClosed;

    function show()
    {
        if (!_contextMenu)
            _contextMenu = contextMenuComponent.createObject(rect);
        _selectedMenu = "";

        _contextMenu.height = (menuItems.length * Theme.itemSizeSmall)
        _contextMenu.y = menuTop
    }

    function close()
    {
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
        if (_contextMenu) {
            _contextMenu.height = 0;
            _contextMenu.destroy();
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: {
            if (_contextMenu) return true
            else return false
        }
        onClicked: {
            close();
        }
    }

    Column {
        anchors.fill: parent

        // bg rectangle for context menu so it covers underlying items
        Rectangle {
            id: rect
            color: isLightTheme ? "white" : "black"
            width: parent.width
            //height: _contextMenu ? _contextMenu.height : 0
        }
    }

    Component {
        id: contextMenuComponent

        LinkContextMenu {
            width: parent.width

            SilicaListView
            {
                id: listview
                width: parent.width
                height: count * Theme.itemSizeSmall
                clip: true
                model: menuItems

                delegate: BackgroundItem {
                    property var item: model.modelData ? model.modelData : model
                    contentWidth: parent.width
                    contentHeight: Theme.itemSizeSmall

                    Label {
                        id: lbltext
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: Theme.fontSizeMedium
                        text: item.txt
                    }
                    IconButton {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingMedium
                        height: parent.height
                        width: height
                        visible: item.extraCmd != ""
                        icon.source: "image://theme/icon-s-favorite"
                        onClicked: {
                            _selectedMenu = item.extraCmd
                            close()
                        }

                    }

                    onClicked: {
                        _selectedMenu = item.cmd
                        close()
                    }
                }

                VerticalScrollDecorator { flickable: listview }
            }
        }

    }

}
