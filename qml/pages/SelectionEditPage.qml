import QtQuick 2.0
import Sailfish.Silica 1.0
Page {

    allowedOrientations: Orientation.All

    //property string editText
    property alias editText: editTxt.text

    Button {
        id: cpButton
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Copy")
        onClicked: {
            editTxt.selectAll();
            editTxt.copy();
            editTxt.deselect();
        }
    }

    TextArea {
        id: editTxt
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: 72
        background: null
        height: parent.height - (cpButton.height + Theme.paddingMedium * 2 + 72)
        text: editText
    }



}

