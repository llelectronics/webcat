import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {

    allowedOrientations: mainWindow.orient

    //property string editText
    property alias editText: editTxt.text

    onAccepted: {
        if(!editTxt.selectedText.length || (!editTxt.selectionStart && (editTxt.selectionEnd == editTxt.text.length)))
            Clipboard.text = editTxt.text
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
                acceptText: qsTr("Copy")
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
                height: flickable.height
            }
        }
    }


}

