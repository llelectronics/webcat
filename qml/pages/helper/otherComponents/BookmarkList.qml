import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: bg
    property ListModel bookmarks

    signal bookmarkClicked(string url, string agent)
    signal openClicked()

    SequentialAnimation {
        id: showAnim
        ScriptAction { script : { bg.visible = true } }
        ParallelAnimation {
            NumberAnimation { target: bg; property: "opacity"; to: 1; duration: 400; easing.type: Easing.InOutQuad }
            NumberAnimation { target: bg; property: "y"; to: 0; duration: 300; easing.type: Easing.InOutQuad }
        }
        ScriptAction { script : { webview.visible = false } }
    }

    SequentialAnimation {
        id: hideAnim
        ScriptAction { script : { webview.visible = true } }
        ParallelAnimation {
            NumberAnimation { target: bg; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InOutQuad }
            NumberAnimation { target: bg; property: "y"; to: -height; duration: 300; easing.type: Easing.InOutQuad }
        }
        ScriptAction { script : { bg.visible = false } }
    }

    function hide() {
        if (bg.opacity == 1 || bg.visible == true) {
            hideAnim.start();
            bg.enabled = false;
        }
    }

    function show() {
        if (bg.opacity == 0 || bg.visible == false) {
            showAnim.start();
            bg.enabled = true;
        }
    }

    function quickReShow() {
        bg.visible = false
        bg.opacity = 0
        bg.y = -height
        bg.visible = true
        bg.opacity = 1
        bg.y = 0
    }


    SilicaListView {
        id: repeater1

        anchors.fill: parent

        model: modelUrls
        quickScroll: true
        clip: true

        header: PageHeader {
            id: topPanel
            title: qsTr("Bookmarks")
        }
        VerticalScrollDecorator {}
        delegate: ListItem {
            id: myListItem
            property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
            property Item contextMenu
            z: bg.z + 1

            height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height

            function remove() {
                var removal = removalComponent.createObject(myListItem)
                ListView.remove.connect(removal.deleteAnimation.start)
                removal.execute(contentItem, "Deleting " + title, function() { bookmarks.removeBookmark(url,title); } )
            }
            function openNewTab() {
                mainWindow.openNewTab("page"+mainWindow.salt(),url,true);
                openClicked();
            }
            function openNewWindow() {
                mainWindow.openNewWindow(url);
                openClicked();
            }
            function editBookmark() {
                pageStack.push(Qt.resolvedUrl("../../AddBookmark.qml"), { bookmarks: bookmarks, editBookmark: true, uAgent: agent, bookmarkUrl: url, bookmarkTitle: title, oldTitle: title });
            }

            BackgroundItem {
                id: contentItem
                Label {
                    id: btitle
                    text: title
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.top: parent.top
                    anchors.topMargin: Theme.paddingMedium
                    color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                    truncationMode: TruncationMode.Fade
                }
                Label {
                    id: desc
                    text: url
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor
                    anchors.top: btitle.bottom
                    anchors.topMargin: -Theme.paddingMedium
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium
                    truncationMode: TruncationMode.Fade
                    visible: contextMenu ? contextMenu.active : false
                }

                onClicked: {
                    bookmarkClicked(url, agent)
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
                        text: qsTr("Open in new Tab")
                        onClicked: {
                            menu.parent.openNewTab();
                        }
                    }
                    MenuItem {
                        text: qsTr("Open in new Window")
                        onClicked: {
                            menu.parent.openNewWindow();
                        }
                    }
                    MenuItem {
                        text: qsTr("Edit")
                        onClicked: {
                            menu.parent.editBookmark();
                        }
                    }
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
            //                MenuItem {
            //                    text: qsTr("About ")+appname
            //                    onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
            //                }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("../../SettingsPage.qml"));
            }
            //                MenuItem {
            //                    text: qsTr("Download Manager")
            //                    onClicked: pageStack.push(Qt.resolvedUrl("DownloadManager.qml"));
            //                }
//            MenuItem {
//                text: qsTr("Split WebView")
//                onClicked: pageStack.push(Qt.resolvedUrl("../../SplitWeb.qml"), {bookmarks: bookmarks} );
//            }
            MenuItem {
                text: qsTr("Add Bookmark")
                onClicked: pageStack.push(Qt.resolvedUrl("../../AddBookmark.qml"), { bookmarks: bookmarks });
            }
            //                MenuItem {
            //                    text: qsTr("New Private Window")
            //                    onClicked: mainWindow.openPrivateNewWindow("http://about:blank");
            //                }
            //                MenuItem {
            //                    text: qsTr("New Window")
            //                    onClicked: mainWindow.openNewWindow("http://about:blank");
            //                }
            //                MenuItem {
            //                    text: qsTr("Load Last Session")
            //                    onClicked: mainWindow.loadSession("lastSession");
            //                }
            MenuItem {
                text: qsTr("History")
                onClicked: pageStack.push(Qt.resolvedUrl("../../HistoryPage.qml"));
            }

            //                MenuItem {
            //                    text: qsTr("New Tab")
            //                    onClicked: mainWindow.openNewTab("page"+mainWindow.salt(), "about:blank", false);
            //                }
            //                MenuItem {
            //                    text: qsTr("Close Tab")
            //                    visible: tabModel.count > 1
            //                    onClicked: mainWindow.closeTab(tabListView.currentIndex, tabModel.get(tabListView.currentIndex).pageid);
            //                }
        }
    }
}
