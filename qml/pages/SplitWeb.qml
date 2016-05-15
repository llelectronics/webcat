import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: splitPage
    allowedOrientations: Orientation.LandscapeMask

    property QtObject bookmarks

    Item {
        id: column1
        width: splitPage.width / 2
        anchors.left: parent.left
        height: splitPage.height

        FirstPage {
            id: firPage
            url: "https://neptuneos.com"
            bookmarks: splitPage.bookmarks
            width: parent.width
            height: parent.height
            visible: true
            webview.parent: column1
            webview.width: column1.width
            webview.height: column1.height
            toolbar.parent: column1
            toolbar.width: column1.width
        }

    }
    Rectangle {
        id: splitter
        height: parent.height
        width: Theme.paddingSmall
        color: "black"
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Item {
        id: column2
        width: splitPage.width / 2
        anchors.right: parent.right
        height: splitPage.height

        FirstPage {
            id: secPage
            url: "http://netrunner.com"
            bookmarks: splitPage.bookmarks
            width: parent.width
            height: parent.height
            visible: true
            webview.parent: column2
            webview.width: column2.width
            webview.height: column2.height
            toolbar.parent: column2
            toolbar.width: column2.width
        }

    }

}

