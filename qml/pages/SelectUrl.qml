import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: urlPage
    //anchors.fill: parent
    allowedOrientations: Orientation.All
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


    Column
    {
        //anchors.fill: parent
        width: parent.width
        height: parent.height
        spacing: Theme.paddingLarge
        //        TextField{
        //            id: entryURL
        //            text: siteURL
        //            font.pixelSize: Theme.fontSizeMedium
        //            width: parent.width
        //            placeholderText: qsTr("Enter an url")
        //            inputMethodHints: Qt.ImhUrlCharactersOnly
        //            focus: true
        //            Keys.onReturnPressed: {
        //                var valid = entryURL.text
        //                if (valid.indexOf(":")<0) {
        //                    if (valid.indexOf(".")<0 || valid.indexOf(" ")>=0) {
        //                        // Fall back to a search engine; hard-code Google
        //                        entryURL.text = "http://www.google.com/search?q="+valid
        //                    } else {
        //                        entryURL.text = "http://"+valid
        //                    }
        //                    urlPage.accept()
        //                }
        //            }
        //            onFocusChanged: if (focus === true) entryURL.selectAll()
        //        }

        SilicaListView {
            id: repeater1
            width: parent.width
            height: urlPage.height - (tabListView.height + Theme.paddingLarge)  //- entryURL.height - 2*65 //- bottomBar.height
            model: modelUrls
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
                    removal.execute(contentItem, "Deleting " + title, function() { bookmarks.removeBookmark(url); } )
                }
                BackgroundItem {
                    id: contentItem
                    Label {
                        text: title
                        anchors.verticalCenter: parent.verticalCenter
                        color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                    }
                    onClicked: {
                        siteURL = url;
                        dataContainer.url = siteURL;
                        dataContainer.agent = agent;
                        pageStack.pop();
                        dataContainer.toolbar.state = "minimized"
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
                            text: "Delete"
                            onClicked: {
                                menu.parent.remove();
                            }
                        }
                    }
                }
            }
            PullDownMenu {
                MenuItem {
                    text: qsTr("About ")+appname
                    onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
                }
                MenuItem {
                    text: qsTr("Add Bookmark")
                    onClicked: pageStack.push(Qt.resolvedUrl("AddBookmark.qml"), { bookmarks: urlPage.bookmarks });
                }
                MenuItem {
                    text: qsTr("New Tab")
                    onClicked: mainWindow.openNewTab("page"+mainWindow.salt(), "about:bookmarks");
                }
                MenuItem {
                    text: qsTr("Close Tab")
                    visible: tabModel.count > 1
                    onClicked: mainWindow.closeTab(tabListView.currentIndex, tabModel.get(tabListView.currentIndex).pageid);
                }
            }
        }

        Component {
            id: tabDelegate
            Row {
                spacing: 10
                Rectangle {
                    width: 150
                    height: 72
                    //                    gradient: Gradient {
                    //                        GradientStop { position: 0.0; color: "#262626" }
                    //                        GradientStop { position: 0.85; color: "#1F1F1F"}
                    //                    }
                    color: "transparent"
                    Text {
                        text: {
                            if (model.title !== "") return model.title
                            else return "Loading..";
                        }
                        width: parent.width - 2
                        color: Theme.primaryColor;
                        anchors.centerIn: parent
                        elide: Text.ElideRight
                    }
                    MouseArea {
                        anchors { top: parent.top; left: parent.left; bottom: parent.bottom; right: parent.right; rightMargin: 40}
                        onClicked: {
                            tabListView.currentIndex = index;
                            mainWindow.switchToTab(model.pageid);
                        }
                    }
                }
            }
        }

        SilicaListView {
            id: tabListView
            width: parent.width
            height: 72

            // new tab button
            header: Rectangle {
                width: 100
                height: 72
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#262626" }
                    GradientStop { position: 0.85; color: "#1F1F1F"}
                }
                Text {
                    text: "<b>New Tab</b>"
                    color: "white"
                    font.pointSize: 15
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        //console.debug("New Tab clicked")
                        mainWindow.openNewTab("page-"+mainWindow.salt(), "about:blank");
                    }
                }
            }

            // close tab button
            footer: Rectangle {
                visible: tabModel.count > 1
                width: 100
                height: 72
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#262626" }
                    GradientStop { position: 0.85; color: "#1F1F1F"}
                }
                Text {
                    text: "<b>Close Tab</b>"
                    color: "white"
                    font.pointSize: 15
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        //console.debug("Close Tab clicked")
                        mainWindow.closeTab(tabListView.currentIndex, tabModel.get(tabListView.currentIndex).pageid);
                    }
                }
            }

            orientation: ListView.Horizontal

            model: tabModel
            delegate: tabDelegate
            highlight:

                Rectangle {
                width: parent.width; height: 72
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#262626" }
                    GradientStop { position: 0.85; color: "#1F1F1F"}
                }
            }
            add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 200 }
                //    NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 400 }
            }

            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutBounce }
            }
            highlightMoveDuration: 2
            highlightFollowsCurrentItem: true
        }
    }
    Component.onCompleted: {
        tabListView.currentIndex = tabModel.getIndexFromId(mainWindow.currentTab);
    }

    //    Row {
    //        id: bottomBar
    //        width: parent.width
    //        height: 65
    //        anchors {
    ////            left: parent.left; leftMargin: Theme.paddingMedium
    ////            right: parent.right; rightMargin: Theme.paddingMedium
    //            bottom: parent.bottom; bottomMargin: Theme.paddingMedium
    //            //verticalCenter: parent.verticalCenter
    //        }
    //        // 5 icons, 4 spaces between
    //        //spacing: (width - (favIcon.width * 5)) / 4

    //        IconButton {
    //            id: favIcon
    //            property bool favorited: bookmarks.count > 0 && bookmarks.contains(siteURL)
    //            icon.source: favorited ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
    //            onClicked: {
    //                if (favorited) {
    //                    console.debug("Remove Bookmark");
    //                    bookmarks.removeBookmark(siteURL)
    //                } else {
    //                    console.debug("Add Bookmark " + siteURL + " " + siteTitle);
    //                    bookmarks.addBookmark(siteURL, siteTitle)
    //                }
    //            }
    //        }
    //    }
}
