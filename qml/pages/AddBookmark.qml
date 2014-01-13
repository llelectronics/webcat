import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: addBookmarkPage

    allowedOrientations: Orientation.All

    acceptDestinationAction: PageStackAction.Pop

    property string uAgentTitle : "Default Jolla Webkit"
    property string uAgent: "Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"

    property ListModel bookmarks

    // Easy fix only for when http:// or https:// is missing
    function fixUrl(nonFixedUrl) {
        var valid = nonFixedUrl
        if (valid.indexOf(":")<0) {
                return "http://"+valid;
        } else return valid
    }

    function addBookmark() {
        console.debug("Creating new bookmark" + bookmarkUrl.text.toString() + bookmarkTitle.text + agentString.text);
        bookmarks.addBookmark(bookmarkUrl.text.toString(), bookmarkTitle.text, agentString.text);
    }

    Flickable {
        width:parent.width
        height: parent.height
        contentHeight: col.height + head.height

        DialogHeader {
            id: head
            acceptText: qsTr("Add Bookmark")
        }

        Column {
            id: col
            anchors.top: head.bottom
            anchors.topMargin: 25
            width: parent.width
            spacing: 25
            function enterPress() {
                if (bookmarkTitle.focus == true) bookmarkUrl.focus = true
                else if (bookmarkUrl.focus == true) { bookmarkUrl.text = fixUrl(bookmarkUrl.text);}
            }

        TextField {
            id: bookmarkTitle
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 20
            placeholderText: "Title of the bookmark"
            focus: true
        }
        TextField {
            id: bookmarkUrl
            width: parent.width - 20
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: "URL of bookmark"
            inputMethodHints: Qt.ImhUrlCharactersOnly
        }
        ValueButton {
            anchors.horizontalCenter: parent.horizontalCenter
            id: userAgentCombo
            label: "User Agent:"
            value: uAgentTitle
            onClicked: pageStack.push(Qt.resolvedUrl("UserAgentDialog.qml"), {dataContainer: addBookmarkPage});
        }
        TextField {
            id: agentString
            anchors.horizontalCenter: parent.horizontalCenter
            readOnly: true
            width: parent.width - 20
            text: uAgent
        }
        Keys.onEnterPressed: enterPress();
        Keys.onReturnPressed: enterPress();
        }
    }

}
