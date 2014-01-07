import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: urlPage
    //anchors.fill: parent
    allowedOrientations: Orientation.All
    showNavigationIndicator: false
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
            delegate: ListItem {
                Label { text: title ; anchors.verticalCenter: parent.verticalCenter}
                onClicked: { siteURL = url; dataContainer.url = siteURL; pageStack.pop(); dataContainer.toolbar.state = "minimized" }
            }
            PullDownMenu {
                MenuItem {
                    text: qsTr("About ")+appname
                    onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
                MenuItem {
                    text: qsTr("New Tab")
                    onClicked: { mainWindow.openNewTab("page"+mainWindow.salt(), "about:blank"); }
                }
                MenuItem {
                    text: qsTr("Close Tab")
                    visible: tabModel.count > 1
                    onClicked: { mainWindow.closeTab(tabListView.currentIndex, tabModel.get(tabListView.currentIndex).pageid); }
                }
                // Add Bookmark MenuItem for manually adding bookmark here
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
        tabListView.currentIndex = tabModel.getIndex(siteTitle);
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
