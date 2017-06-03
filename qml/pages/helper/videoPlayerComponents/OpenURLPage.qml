import QtQuick 2.0
import Sailfish.Silica 1.0
import "../yt.js" as YT

Dialog {
    id: openUrlPage
    allowedOrientations: Orientation.All
    property QtObject dataContainer
    property string streamUrl

    DialogHeader {
        acceptText: qsTr("Load URL")
    }

    onAccepted: loadUrl()
    onCanceled: pageStack.pop()

    function loadUrl() {
        if (mainWindow.isUrl(urlField.text.toString()) === true) {
            dataContainer.streamUrl = urlField.text.toString();
            dataContainer.originalUrl = mainWindow.findBasename(urlField.text.toString());
            if (dataContainer != null) {
                pageStack.pop();
            }
        }
        else if (dataContainer != null) {
            dataContainer.streamUrl = urlField.text;
            dataContainer.originalUrl = "";
            dataContainer.streamTitle = "";
            pageStack.pop();
        }
    }



    Keys.onEnterPressed: loadUrl();
    Keys.onReturnPressed: loadUrl();



    Item {
        id: column
        width:parent.width
        height: isLandscape ? parent.height - Theme.paddingLarge * 4 : parent.height - Theme.paddingLarge * 6
        anchors.top: parent.top
        anchors.topMargin: isLandscape ? Theme.paddingLarge * 4 : Theme.paddingLarge * 6

        TextField {
            id: urlField
            placeholderText: qsTr("Type in URL here")
            label: qsTr("URL to media file/stream")
            width: Screen.width - 20
            anchors.horizontalCenter: parent.horizontalCenter
            focus: true
            Component.onCompleted: {
                // console.debug("StreamUrl :" + streamUrl) // DEBUG
                if (streamUrl !== "") {
                    text = streamUrl;
                    selectAll();
                }
            }
        }

    }
}
