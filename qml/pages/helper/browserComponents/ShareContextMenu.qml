import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.webcat.DBus.TransferEngine 1.0
import "."

ContextMenu {
    id: shareContextMenu
    visible: false
    property alias shareContextList: listview

    height: 0

    property var content

    function share(urltitle, shareurl) {
        if(!shareContextMenu.content)
            shareContextMenu.content = new Object;

        shareContextMenu.content.linkTitle = urltitle;
        shareContextMenu.content.status = shareurl;

        shareContextMenu.contextLbl.text = qsTr("Share") + ":\n" + shareurl;
        shareContextMenu.visible = true;
        shareContextMenu.height = Theme.itemSizeSmall * Math.min(5, listview.count+1) + Theme.itemSizeMedium
    }

    Column {
        width: parent.width
        anchors { left: parent.left; top: typeof(contextLbl) !== "undefined" ? contextLbl.bottom : parent.top ; right: parent.right; bottom: parent.bottom }
        anchors.topMargin: -10
        ListItem {
            id: sailfishBrowserItem
            contentWidth: parent.width
            contentHeight: Theme.itemSizeSmall

            Label {
                id: extBrowserLbl
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeMedium
                text: "Sailfish-Browser"
            }

            onClicked: {
                //console.debug("Call browser with url: " + shareContextMenu.parent.webview.url)
                contextMenu.visible = false;
                shareContextMenu.visible = false;
                mainWindow.runExternally("sailfish-browser " + shareContextMenu.parent.webview.url);
            }
        }

        SilicaListView
        {
            id: listview
            width: parent.width
            height: shareContextMenu.height - sailfishBrowserItem.height * 2
            clip: true
            model: TransferMethodModel {
                id: transfermethodmodel
                filter: "text/x-url"
                transferEngine: mainWindow.transferEngine
            }

            delegate: ListItem {
                contentWidth: parent.width
                contentHeight: Theme.itemSizeSmall

                Label {
                    id: lbltext
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontSizeMedium
                    text: methodId + (userName.length ? " (" + userName + ")" : "")
                }

                onClicked: {
                    shareContextMenu.content.type = transfermethodmodel.filter; // Set Filter before open a new page
                    contextMenu.visible = false;

                    pageStack.push(Qt.resolvedUrl(shareUIPath), { "methodId": methodId, "accountId": accountId, "content": shareContextMenu.content } );
                }
            }

            VerticalScrollDecorator { flickable: listview }
        }
    }
}
