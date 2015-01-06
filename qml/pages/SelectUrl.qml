import QtQuick 2.0
import Sailfish.Silica 1.0

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


    Column
    {
        //anchors.fill: parent
        width: parent.width
        height: parent.height
        spacing: Theme.paddingLarge

        SilicaListView {
            id: repeater1
            width: parent.width
            height: urlPage.height - (tabListView.height + Theme.paddingLarge)  //- entryURL.height - 2*65 //- bottomBar.height
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
                    removal.execute(contentItem, "Deleting " + title, function() { bookmarks.removeBookmark(url); } )
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
                        text: title
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingMedium
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingMedium
                        color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                        truncationMode: TruncationMode.Fade
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

                MenuItem {
                    text: qsTr("New Tab")
                    onClicked: mainWindow.openNewTab("page"+mainWindow.salt(), "about:blank", false);
                }
                MenuItem {
                    text: qsTr("Close Tab")
                    visible: tabModel.count > 1
                    onClicked: mainWindow.closeTab(tabListView.currentIndex, tabModel.get(tabListView.currentIndex).pageid);
                }
            }
        }

        Gradient {
            id: hightlight
            GradientStop { position: 0.0; color: Theme.highlightColor }
            GradientStop { position: 0.10; color: "#262626" }
            GradientStop { position: 0.85; color: "#1F1F1F"}
        }

        Gradient {
            id: normalBg
            GradientStop { position: 0.0; color: "#262626" }
            GradientStop { position: 0.85; color: "#1F1F1F"}
        }

        Component {
            id: tabDelegate
            Row {
                spacing: 10
                Rectangle {
                    id: tabBg
                    width: Screen.width / 3
                    height: dataContainer.toolbarheight
                    color: "transparent"
                    Text {
                        text: {
                            if (model.title !== "") return model.title
                            else return qsTr("Loading..");
                        }
                        width: parent.width - 2
                        font.pixelSize: tabBg.height / 2.15
                        color: Theme.primaryColor;
                        anchors.centerIn: parent
                        elide: Text.ElideRight
                    }
                    MouseArea {
                        property int ymouse;
                        anchors { top: parent.top; left: parent.left; bottom: parent.bottom; right: parent.right; rightMargin: 40}
                        onPressAndHold: {
                            if (tabModel.count > 1) {
                                ymouse = mouse.y
                                tabCloseMsg.opacity = 1.0
                            }
                        }
                        onClicked: {
                            if (tabListView.currentIndex == index) { pageStack.pop() }
                            else {
                                tabListView.currentIndex = index;
                                mainWindow.switchToTab(model.pageid);
                            }
                        }
                        onReleased: {
                            if (tabCloseMsg.opacity == 1.0 && mouse.y < ymouse - 50) {
                                //console.debug("[SelectUrl.qml] Removing Tab with index: " + index + " and currentIndex: " + tabListView.currentIndex);
                                mainWindow.closeTab(index, tabModel.get(index).pageid)
                            }
                            tabCloseMsg.opacity = 0
                        }
                    }
                }
            }
        }

        Rectangle {
            id: tabListBg
            height: dataContainer.toolbarheight
            width: parent.width
            gradient: normalBg

        SilicaListView {
            id: tabListView
            width: parent.width
            height: dataContainer.toolbarheight

            // new tab button
            header: Rectangle {
                width: newTabImg.width + Theme.paddingLarge
                height: dataContainer.toolbarheight
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#262626" }
                    GradientStop { position: 0.85; color: "#1F1F1F"}
                }
//                Text {
//                    text: "<b>+</b>"
//                    color: "white"
//                    font.pointSize: 25
//                    anchors.centerIn: parent
//                }
                Image {
                    id: newTabImg
                    height: dataContainer.toolbarheight / 1.5
                    width: height
                    anchors.centerIn: parent
                    source : "image://theme/icon-cover-new" // This image is 96x96 and does not have a big border so make it smaller
                }

                MouseArea {
                    property int ymouse;
                    anchors.fill: parent
                    onClicked: {
                        //console.debug("New Tab clicked")
                        mainWindow.openNewTab("page-"+mainWindow.salt(), "about:blank", false);
                    }
                    onPressAndHold: {
                            ymouse = mouse.y
                            tabCloseMsg.text = qsTr("Swipe up to open new window")
                            tabCloseMsg.opacity = 1.0
                    }
                    onPositionChanged: {
                        if (tabCloseMsg.opacity == 1.0 && mouse.y < ymouse - 50 && mouse.y > ymouse - 120) {
                            tabCloseMsg.text = qsTr("Swipe up to open new window")
                        }
                        else if (tabCloseMsg.opacity == 1.0 && mouse.y < ymouse - 120) {
                            tabCloseMsg.text = qsTr("Swipe up to open private window")
                        }
                    }
                    onReleased: {
                        if (tabCloseMsg.opacity == 1.0 && mouse.y < ymouse - 50 && mouse.y > ymouse - 120) {
                            mainWindow.openNewWindow("http://about:blank");
                        }
                        else if (tabCloseMsg.opacity == 1.0 && mouse.y < ymouse - 120) {
                            mainWindow.openPrivateNewWindow("http://about:blank");
                        }
                        tabCloseMsg.opacity = 0
                    }
                }
            }

            // close tab button
            footer: Rectangle {
                visible: tabModel.count > 1
                width: closeTabImg.width + Theme.paddingLarge
                height: dataContainer.toolbarheight
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#262626" }
                    GradientStop { position: 0.85; color: "#1F1F1F"}
                }
//                Text {
//                    text: "<b>x</b>"
//                    color: "white"
//                    font.pointSize: 25
//                    anchors.centerIn: parent
//                }
                Image {
                    id: closeTabImg
                    height: dataContainer.toolbarheight / 1.125
                    width: height
                    anchors.centerIn: parent
                    source : "image://theme/icon-m-close" // This image is 64x64 and does have a big border so leave it as is
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
                width: parent.width; height: dataContainer.toolbarheight
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.highlightColor }
                    GradientStop { position: 0.10; color: "#262626" }
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
    }
    Component.onCompleted: {
        tabListView.currentIndex = tabModel.getIndexFromId(mainWindow.currentTab);
        mainWindow.currentTabIndex = tabListView.currentIndex
    }

    Rectangle {
        id: tabCloseMsg
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: "#262626" }
            GradientStop { position: 0.50; color: "#262626" }
            GradientStop { position: 0.95; color: "transparent"}
        }
        opacity: 0
        width: parent.width
        height: Theme.fontSizeLarge + Theme.paddingLarge
        anchors.bottom: parent.bottom
        anchors.bottomMargin: tabListBg.height * 2
        property alias text: tabCloseMsgTxt.text
        Behavior on opacity {
            NumberAnimation { target: tabCloseMsg; property: "opacity"; duration: 200; easing.type: Easing.InOutQuad }
        }
        Label {
            id: tabCloseMsgTxt
            opacity: parent.opacity
            //font.pixelSize: Theme.fontSizeLarge // Too large for some translations. Stick to the default
            font.bold: true
            truncationMode: TruncationMode.Fade
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Swipe up to close tab")

        }
    }
}
