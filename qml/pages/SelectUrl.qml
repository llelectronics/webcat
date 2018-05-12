import QtQuick 2.0
import Sailfish.Silica 1.0
import "helper/otherComponents"

Page
{
    id: urlPage
    //anchors.fill: parent
    allowedOrientations: mainWindow.orient
    showNavigationIndicator: true
    forwardNavigation: false

    // Needs to be set as dialog behaves buggy somehow
    //width: urlPage.orientation == Orientation.Portrait ? screen.Width : screen.Height
    //height: urlPage.orientation == Orientation.Portrait ? screen.Height : screen.Width

    property string siteURL
    property string siteTitle
    property QtObject dataContainer
    property ListModel bookmarks

    //property ListModel tabModel


    SilicaListView {
        id: repeater1
        width: {
            if (urlPage.orientation == Orientation.Landscape || urlPage.orientation == Orientation.LandscapeInverted) urlPage.width / 2
            else urlPage.width
        }
        height: {
            if (urlPage.orientation == Orientation.Landscape || urlPage.orientation == Orientation.LandscapeInverted) urlPage.height
            else urlPage.height - (tabBar.height + Theme.paddingLarge)  //- entryURL.height - 2*65 //- bottomBar.height
        }
        model: modelUrls
        quickScroll: true
        header: PageHeader {
            id: topPanel
            title: qsTr("Bookmarks")
        }
        VerticalScrollDecorator {}
        delegate: ListItem {
            id: myListItem
            property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
            property Item contextMenu

            height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height

            function remove() {
                var removal = removalComponent.createObject(myListItem)
                ListView.remove.connect(removal.deleteAnimation.start)
                removal.execute(contentItem, "Deleting " + title, function() { bookmarks.removeBookmark(url,title); } )
            }
            function openNewTab() {
                mainWindow.openNewTab("page"+mainWindow.salt(),url,true);
            }
            function openNewWindow() {
                mainWindow.openNewWindow(url);
            }
            function editBookmark() {
                pageStack.push(Qt.resolvedUrl("AddBookmark.qml"), { bookmarks: urlPage.bookmarks, editBookmark: true, uAgent: agent, bookmarkUrl: url, bookmarkTitle: title, oldTitle: title });
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
                    siteURL = url;
                    dataContainer.url = siteURL;
                    dataContainer.agent = agent;
                    pageStack.pop();
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
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));
            }
            //                MenuItem {
            //                    text: qsTr("Download Manager")
            //                    onClicked: pageStack.push(Qt.resolvedUrl("DownloadManager.qml"));
            //                }
            MenuItem {
                text: qsTr("Split WebView")
                onClicked: pageStack.push(Qt.resolvedUrl("SplitWeb.qml"), {bookmarks: urlPage.bookmarks} );
            }
            MenuItem {
                text: qsTr("Add Bookmark")
                onClicked: pageStack.push(Qt.resolvedUrl("AddBookmark.qml"), { bookmarks: urlPage.bookmarks });
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
                onClicked: pageStack.push(Qt.resolvedUrl("HistoryPage.qml"));
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
    TabBar {
        id: tabBar

        dataContainer: parent.dataContainer

        height: {
            if (parent.orientation == Orientation.Landscape || parent.orientation == Orientation.LandscapeInverted) {
                parent.height
            }
            else {
                if (Theme.itemSizeExtraSmall + (tabModel.count * Theme.itemSizeSmall) < Screen.height / 2.25)
                    Theme.itemSizeExtraSmall + (tabModel.count * Theme.itemSizeSmall) + Theme.paddingMedium
                else
                    parent.height / 2.25
            }
        }
        width: {
            if (parent.orientation == Orientation.Landscape || parent.orientation == Orientation.LandscapeInverted) parent.width / 2
            else parent.width
        }

        anchors.bottom: parent.bottom
        anchors.right: if (parent.orientation == Orientation.Landscape || parent.orientation == Orientation.LandscapeInverted) parent.right
        anchors.left: if (parent.orientation == Orientation.Portrait || parent.orientation == Orientation.PortraitInverted) parent.left
        onTabClicked: {
            if (_tabListView.currentIndex == idx) { pageStack.pop() }
            else {
                _tabListView.currentIndex = idx;
                mainWindow.switchToTab(pageId);
            }
        }
        onNewWindowClicked: {
            mainWindow.openNewWindow("about:blank");
        }
        onNewTabClicked: {
            mainWindow.openNewTab("page-"+mainWindow.salt(), "about:blank", false);
        }
    }
}
