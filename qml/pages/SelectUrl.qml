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
            else urlPage.height - (tabListBg.height + Theme.paddingLarge)  //- entryURL.height - 2*65 //- bottomBar.height
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
        Rectangle {
            id: tabBg
            width: parent.width - (2* Theme.paddingSmall)
            height: Theme.itemSizeSmall //if (dataContainer) dataContainer.toolbarheight
            color: "transparent"
            Text {
                text: {
                    if (model.title !== "") return model.title
                    else return qsTr("Loading..");
                }
                width: parent.width - Theme.itemSizeMedium + Theme.paddingMedium
                font.pixelSize: Theme.fontSizeMedium //tabBg.height / 2.15
                color: Theme.primaryColor;
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
            }
            Image {
                id: closeTabImg
                height: Theme.iconSizeMedium
                width: height
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingSmall
                anchors.verticalCenter: parent.verticalCenter
                source : "image://theme/icon-m-close" // This image is 64x64 and does have a big border so leave it as is
                visible: tabModel.count > 1
            }
            MouseArea {
                anchors.fill: closeTabImg;
                onClicked: {
                    //console.debug("Close Tab clicked")
                    mainWindow.closeTab(index, tabModel.get(index).pageid);
                }
                onPressAndHold: {
                    mainWindow.closeAllTabs();
                }

                enabled: closeTabImg.visible
            }
            MouseArea {
                property int ymouse;
                anchors { top: parent.top; left: parent.left; bottom: parent.bottom; right: parent.right; rightMargin: Theme.itemSizeMedium}
                onClicked: {
                    if (tabListView.currentIndex == index) { pageStack.pop() }
                    else {
                        tabListView.currentIndex = index;
                        mainWindow.switchToTab(model.pageid);
                    }
                }
            }
        }
    }

    Rectangle {
        id: tabListBg
        height: {
            if (urlPage.orientation == Orientation.Landscape || urlPage.orientation == Orientation.LandscapeInverted) {
                urlPage.height
            }
            else {
                if (Theme.itemSizeExtraSmall + (tabModel.count * Theme.itemSizeSmall) < Screen.height / 2.25)
                    Theme.itemSizeExtraSmall + (tabModel.count * Theme.itemSizeSmall) + Theme.paddingMedium
                else
                    urlPage.height / 2.25
            }
        }
        width: {
            if (urlPage.orientation == Orientation.Landscape || urlPage.orientation == Orientation.LandscapeInverted) parent.width / 2
            else parent.width
        }
        gradient: normalBg
        anchors.bottom: if (urlPage.orientation == Orientation.Portrait || urlPage.orientation == Orientation.PortraitInverted) urlPage.bottom
        anchors.right: if (urlPage.orientation == Orientation.Landscape || urlPage.orientation == Orientation.LandscapeInverted) urlPage.right


        Rectangle {
            id: tabHead
            width: parent.width //newTabImg.width + Theme.paddingLarge
            height: Theme.itemSizeExtraSmall //if (dataContainer) dataContainer.toolbarheight
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#262626" }
                GradientStop { position: 0.85; color: "#1F1F1F"}
            }
            Image {
                anchors.fill: parent
                fillMode: Image.Tile
                source: "img/graphic-diagonal-line-texture.png"
                visible: mainWindow.privateBrowsing
                verticalAlignment: Image.AlignTop
            }
            anchors.top: {
                if (urlPage.orientation == Orientation.Portrait || urlPage.orientation == Orientation.PortraitInverted) parent.top
                else tabListView.bottom
            }

            Label {
                id: tabHeadLbl
                text: qsTr("Tabs") + mainWindow.unicodeBlackDownPointingTriangle()
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                anchors.verticalCenter: parent.verticalCenter
            }
            MouseArea {
                anchors.fill: tabHeadLbl
                onClicked: menuPopup.show();
            }

            Image {
                id: newTabImg
                height: Theme.iconSizeSmall
                width: height
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.verticalCenter: parent.verticalCenter
                source : "image://theme/icon-cover-new" // This image is 96x96 and does not have a big border so make it smaller
            }

            MouseArea {
                property int ymouse;
                height: parent.height
                width: newTabImg.width * 2
                anchors.centerIn: newTabImg
                onClicked: {
                    //console.debug("New Tab clicked")
                    mainWindow.openNewTab("page-"+mainWindow.salt(), "about:blank", false);
                }
                onPressAndHold: {
                    ymouse = mouse.y
                    tabCloseMsg.text = qsTr("Swipe up to open new window")
                    tabCloseMsg.icon = "image://theme/icon-m-tab"
                    tabCloseMsg.opacity = 1.0
                }
                onPositionChanged: {
                    if (tabCloseMsg.opacity == 1.0 && mouse.y < ymouse - 50 && mouse.y > ymouse - 120) {
                        tabCloseMsg.text = qsTr("Swipe up to open new window")
                        tabCloseMsg.icon = "image://theme/icon-m-tab"
                    }
                    else if (tabCloseMsg.opacity == 1.0 && mouse.y < ymouse - 120) {
                        tabCloseMsg.text = qsTr("Swipe up to open private window")
                        tabCloseMsg.icon = "image://theme/icon-cover-people"
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

        SilicaListView {
            id: tabListView
            width: parent.width
            height: parent.height - tabHead.height - Theme.paddingMedium
            clip: true
            anchors.top: {
                if (urlPage.orientation == Orientation.Portrait || urlPage.orientation == Orientation.PortraitInverted) tabHead.bottom
                else parent.top
            }
            anchors.topMargin: Theme.paddingSmall

            //orientation: ListView.Horizontal
            verticalLayoutDirection: {
                if (urlPage.orientation == Orientation.Landscape || urlPage.orientation == Orientation.LandscapeInverted) ListView.BottomToTop
                else ListView.TopToBottom
            }

            Image {
                anchors.fill: parent
                fillMode: Image.Tile
                source: "img/graphic-diagonal-line-texture.png"
                visible: mainWindow.privateBrowsing
                verticalAlignment: Image.AlignTop
            }

            model: tabModel
            delegate: tabDelegate
            highlight:

                Rectangle {
                width: urlPage.width; height: Theme.itemSizeSmall
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.highlightColor }
                    GradientStop { position: 0.10; color: "#262626" }
                    GradientStop { position: 0.95; color: "#1F1F1F"}
                    GradientStop { position: 0.98; color: Theme.highlightColor }
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
    } // Rectangle BG

    Component.onCompleted: {
        tabListView.currentIndex = tabModel.getIndexFromId(mainWindow.currentTab);
        mainWindow.currentTabIndex = tabListView.currentIndex
    }

    Rectangle {
        id: tabCloseMsg
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.25; color: "#262626" }
            GradientStop { position: 0.5; color: "#262626" }
            GradientStop { position: 0.75; color: "#262626" }
            GradientStop { position: 0.95; color: "transparent"}
        }
        opacity: 0
        width: parent.width
        height: Theme.fontSizeLarge + Theme.paddingLarge + Theme.iconSizeLarge
        anchors.top: parent.top
        anchors.topMargin: tabListBg.height + 2 * Theme.paddingLarge
        property alias text: tabCloseMsgTxt.text
        property alias icon: tabCloseIcon.source
        Behavior on opacity {
            NumberAnimation { target: tabCloseMsg; property: "opacity"; duration: 200; easing.type: Easing.InOutQuad }
        }
        Image {
            id: tabCloseIcon
            source: "image://theme/icon-m-close"
            width: Theme.iconSizeLarge
            height: width
            anchors.bottom: tabCloseMsgTxt.top
            anchors.bottomMargin: Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            id: tabCloseMsgTxt
            opacity: parent.opacity
            //font.pixelSize: Theme.fontSizeLarge // Too large for some translations. Stick to the default
            font.bold: true
            truncationMode: TruncationMode.Fade
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Swipe up to close tab")

        }
    }

    MenuPopup {
        id: menuPopup
        anchors.fill: parent
        menuTop: {
            if (urlPage.orientation == Orientation.Portrait || urlPage.orientation == Orientation.PortraitInverted) tabListBg.y - Theme.itemSizeMedium * 3.25  // 4 MenuItems for the moment
            else tabHead.y - Theme.itemSizeMedium * 3.25
        }
        dataContainer: dataContainer
    }
}
