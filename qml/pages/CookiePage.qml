import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2

Page {
    id: page
    allowedOrientations: mainWindow.orient

    RemorsePopup { id: remorse }

    Component.onCompleted: {
        _cookieManager.openDB();
        _cookieManager.getCookies();
    }

    Connections {
        target: _cookieManager
        onAddCookieToList:{
            cookieModel.addCookie(cookieTxt);
        }
    }

    ListModel {
        id: cookieModel

        function getIndex(url) {
            for (var i=0; i<count; i++) {
                if (get(i).url == url)  { // type transformation is intended here
                    return i;
                }
            }
            return 0;
        }

        function addCookie(url) {
            // Add Cookie
            append({"url": url})
        }
        function removeCookie(url) {
            // Remove Cookie from db and model
            _cookieManager.removeCookie(url);
            cookieModel.remove(getIndex(url));
        }
    }

    SortFilterProxyModel {
        id: cookieProxyModel
        filterRoleName: "url"
        filterPattern: searchField.text
        filterCaseSensitivity: Qt.CaseInsensitive
        sourceModel: cookieModel
    }




    SilicaListView {
        id: repeater1
        width: parent.width
        height: parent.height - searchField.height
        clip: true
        model: cookieProxyModel
        quickScroll: true
        header: PageHeader {
            id: topPanel
            title: qsTr("Cookies")
        }

        VerticalScrollDecorator {}

        function clearCookies() {
            remorse.execute(qsTr("Clear Cookies"), function() { mainWindow.clearCookies(); cookieModel.clear() } )
        }

        delegate: ListItem {
            id: myListItem
            property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
            property Item contextMenu

            height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height

            function remove() {
                var removal = removalComponent.createObject(myListItem)
                ListView.remove.connect(removal.deleteAnimation.start)
                removal.execute(contentItem, "Deleting " + url, function() { cookieModel.removeCookie(url); } )
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
                text: qsTr("Clear Cookies")
                onClicked: repeater1.clearCookies();
            }
        }
    }

    SearchField {
        id: searchField
        property string acceptedInput: ""
        width: parent.width
        anchors.top: repeater1.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        placeholderText: qsTr("Search..")

        EnterKey.enabled: text.trim().length > 0
        EnterKey.text: "Go!"

        Component.onCompleted: {
            acceptedInput = ""
        }
    }

}
