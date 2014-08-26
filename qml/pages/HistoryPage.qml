import QtQuick 2.0
import Sailfish.Silica 1.0
import "helper/db.js" as DB

Page {
    anchors.fill: parent
    allowedOrientations: Orientation.All

    RemorsePopup { id: remorse }

    Component.onCompleted: {
        DB.getHistory();
    }

    SilicaListView {
        id: repeater1
        width: parent.width
        height: parent.height
        model: mainWindow.historyModel
        quickScroll: true
        header: PageHeader {
            id: topPanel
            title: qsTr("History")
        }
        VerticalScrollDecorator {}

        function clearHistory() {
            remorse.execute(qsTr("Clear History"), function() { DB.clearTable("history"); } )
        }

        delegate: ListItem {
            id: myListItem
            property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
            property Item contextMenu

            height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height

            function remove() {
                var removal = removalComponent.createObject(myListItem)
                ListView.remove.connect(removal.deleteAnimation.start)
                removal.execute(contentItem, "Deleting " + url, function() { mainWindow.historyModel.removeHistory(url); } )
            }

            BackgroundItem {
                id: contentItem
                Label {
                    text: url
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium
                    color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                    truncationMode: TruncationMode.Fade
                }
                onClicked: {
                    mainWindow.loadInNewTab(url)
                    //dataContainer.toolbar.state = "minimized"
                }
                onPressAndHold: {
                    if (!contextMenu)
                        contextMenu = contextMenuComponent.createObject(repeater1)
                    contextMenu.show(myListItem)
                }
            }
            Component {
                id: removalComponent
                RemorseItem {
                    property QtObject deleteAnimation: SequentialAnimation {
                        PropertyAction { target: myListItem; property: "ListView.delayRemove"; value: true }
                        NumberAnimation {
                            target: myListItem
                            properties: "height,opacity"; to: 0; duration: 300
                            easing.type: Easing.InOutQuad
                        }
                        PropertyAction { target: myListItem; property: "ListView.delayRemove"; value: false }
                    }
                    onCanceled: destroy();
                }
            }
            Component {
                id: contextMenuComponent
                ContextMenu {
                    id: menu
                    MenuItem {
                        text: qsTr("Delete")
                        onClicked: {
                            menu.parent.remove();
                        }
                    }
                }
            }
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("Clear History")
                onClicked: repeater1.clearHistory();
            }
            MenuItem {
                text: qsTr("Load Last Session")
                onClicked: mainWindow.loadSession("lastSession");
            }
        }
    }

}
