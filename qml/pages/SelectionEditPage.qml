import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {

    allowedOrientations: mainWindow.orient

    //property string editText
    property var editText
    property var htmlText
    property bool showHtml: false
    property bool editInput: false

    property QtObject dataContainer

    onAccepted: {
        if (!editInput) {
        if(!editTxt.selectedText.length || (!editTxt.selectionStart && (editTxt.selectionEnd == editTxt.text.length)))
            // Avoid lipstick clipboard not updating bug
            _myClass.copy2clipboard(editTxt.text);
        }
        else {
            var message = new Object
            message.type = 'setInput'
            message.elem = dataContainer.inputElem
            message.text = editTxt.text
            dataContainer.webview.experimental.postMessage(JSON.stringify(message))
        }
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width

            DialogHeader {
                id: header
                acceptText: editInput ? qsTr("Accept") : qsTr("Copy")
            }

            //    Button {
            //        id: cpButton
            //        anchors.bottom: parent.bottom
            //        anchors.bottomMargin: Theme.paddingMedium
            //        anchors.horizontalCenter: parent.horizontalCenter
            //        text: qsTr("Copy")
            //        onClicked: {
            //            editTxt.selectAll();
            //            editTxt.copy();
            //            editTxt.deselect();
            //        }
            //    }

            TextArea {
                id: editTxt
                width: parent.width
//                anchors.top: parent.top
//                anchors.topMargin: 72
                background: null
                height: flickable.height - toggleHtml.height - Theme.paddingMedium
                text: editText
            }
            Button {
                id: toggleHtml
                width: parent.width - 2 * Theme.paddingLarge
                height: Theme.itemSizeMedium
                visible: !editInput
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    if (!showHtml) qsTr("Show HTML")
                    else qsTr("Hide HTML")
                }
                onClicked: {
                    if (!showHtml) { editTxt.text = htmlText; showHtml = true }
                    else { editTxt.text = editText; showHtml = false }
                }
            }
        }
    }


}

