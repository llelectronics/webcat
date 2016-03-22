import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: rootArea
    property QtObject popoverModel: model
    property var itemSelectorIndex: parent.itemSelectorIndex
    anchors.fill: parent
    onClicked: popoverModel.reject()

    Item {
        id: container

        width:  rect.width  + (2 * rectShadow.radius);
        height: rect.height + (2 * rectShadow.radius);

        x: {
            if (popoverModel.elementRect.x + width/2 > rootArea.width) {
                rootArea.width - popoverModel.elementRect.x - 40
            } else if (popoverModel.elementRect.x - width/2 + popoverListView.contentItem.width/2 < 0) {
                30
            } else {
                popoverModel.elementRect.x - width/2 + 50
            }
        }

        y: {
            if (popoverModel.elementRect.y + popoverModel.elementRect.height + height < rootArea.height ) {
                popoverDownCaret.visible = true
                popoverUpCaret.visible = false
                popoverModel.elementRect.y + popoverModel.elementRect.height
            } else {
                popoverDownCaret.visible = false
                popoverUpCaret.visible = true
                popoverModel.elementRect.y - height
            }
        }

        Rectangle {
            id: rect
            width: 250
            height: 300 //( popoverListView.contentItem.height < 300 ) ? popoverListView.contentItem.height + 40 : 300
            radius: 5
            anchors.centerIn: parent
            antialiasing: true;
            color: "black"

            Text {
                id: popoverUpCaret
                anchors { left: parent.horizontalCenter; margins: -10; top: parent.bottom; topMargin: -22; }
                text: "\uF0D7"
                color: "gray"
                font.pixelSize: Theme.fontSizeMedium
            }
            Text {
                id: popoverDownCaret
                anchors { left: parent.horizontalCenter; margins: -10; top: parent.top; topMargin: -32; }
                text: "\uF0D8"
                color: "gray"
                font.pixelSize: Theme.fontSizeMedium
            }

            ListView {
                id: popoverListView
                anchors { fill: parent; margins: 20; topMargin: 40; bottomMargin: 40 }
                model: popoverModel.items

                delegate: Rectangle {
                    color: "transparent"
                    height: 40
                    width: parent.width

                    Text {
                        anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; }
                        text: model.text
                        color: model.selected ? Theme.highlightColor : "white"
                        font { pixelSize: Theme.fontSizeSmall }
                        elide: Text.ElideRight
                    }

                    Text { // highlight
                        visible: model.selected ? true : false
                        color: Theme.highlightColor; text: "\uF00C";
                        anchors.right : parent.right
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: model.enabled
                        onClicked: { rootArea.parent.itemSelectorIndex = model.index ; popoverModel.accept(model.index); }
                    }
                }
                Component.onCompleted: {
                    // console.debug("[PopOver.qml] Created ListView with index at:" + itemSelectorIndex)
                    positionViewAtIndex(itemSelectorIndex, ListView.Beginning);
                }
            }
        }
    }

    DropShadow {
        id: rectShadow;
        anchors.fill: source
        cached: true;
        horizontalOffset: 3;
        verticalOffset: 3;
        radius: 12.0;
        samples: 16;
        color: "#80000000";
        smooth: true;
        source: container;
    }
}
