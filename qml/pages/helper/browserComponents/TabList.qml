import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: tabListRoot

    visible: false
    color: "black"
    opacity: 0.97

    signal hideTriggered();

    onVisibleChanged: {
        tabListView.currentIndex = mainWindow.tabModel.getIndexFromId(mainWindow.currentTab);
        mainWindow.currentTabIndex = tabListView.currentIndex
    }

    Component {
        id: tabDelegate
        Rectangle {
            id: tabBg
            width: parent.width
            height: mainWindow.firstPage.toolbarheight
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
                onClicked: {
                    if (tabListView.currentIndex == index) { tabListRoot.hideTriggered(); }
                    else {
                        tabListView.currentIndex = index;
                        tabListRoot.hideTriggered();
                        mainWindow.switchToTab(model.pageid);
                    }
                }
            }
        }
    }

    SilicaListView {
        id: tabListView
        width: parent.width - Theme.paddingLarge
        anchors.centerIn: parent
        //height: if (dataContainer) dataContainer.toolbarheight
        height: parent.height

        PullDownMenu {
            MenuItem {
                text: qsTr("New Tab")
                onClicked: {
                    tabListRoot.hideTriggered();
                    mainWindow.openNewTab("page"+mainWindow.salt(), "about:blank", false);
                }
            }
            MenuItem {
                text: qsTr("Close Tab")
                visible: mainWindow.tabModel.count > 1
                onClicked: mainWindow.closeTab(tabListView.currentIndex, mainWindow.tabModel.get(tabListView.currentIndex).pageid);
            }
        }

        // Tab Header
        header: Rectangle {
            width: parent.width
            height: mainWindow.firstPage.toolbarheight
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#262626" }
                GradientStop { position: 0.85; color: "#1F1F1F"}
            }
            Text {
                text: qsTr("Tabs")
                width: parent.width - 2
                font.pixelSize: mainWindow.firstPage.toolbarheight / 2.15
                font.bold: true
                color: Theme.primaryColor;
                anchors.centerIn: parent
                elide: Text.ElideRight
            }
        }

        // close tab button
//        footer: Rectangle {
//            visible: mainWindow.tabModel.count > 1
//            width: parent.width
//            height: mainWindow.firstPage.toolbarheight
//            gradient: Gradient {
//                GradientStop { position: 0.0; color: "#262626" }
//                GradientStop { position: 0.85; color: "#1F1F1F"}
//            }
//            Image {
//                id: closeTabImg
//                height: parent.height / 1.125
//                width: height
//                anchors.left: parent.left
//                source : "image://theme/icon-m-close" // This image is 64x64 and does have a big border so leave it as is
//            }
//            Text {
//                text: qsTr("Close Tab")
//                width: parent.width - 2
//                font.pixelSize: mainWindow.firstPage.toolbarheight / 2.15
//                color: Theme.primaryColor;
//                anchors.left: closeTabImg.right
//                anchors.leftMargin: Theme.paddingMedium
//                anchors.verticalCenter: parent.verticalCenter
//                elide: Text.ElideRight
//            }
//            MouseArea {
//                anchors.fill: parent;
//                onClicked: {
//                    //console.debug("Close Tab clicked")
//                    mainWindow.closeTab(tabListView.currentIndex, mainWindow.tabModel.get(tabListView.currentIndex).pageid);
//                }
//            }
//        }

        orientation: ListView.Vertical

        model: mainWindow.tabModel
        delegate: tabDelegate
        highlight:

            Rectangle {
            width: parent.width; height: mainWindow.firstPage.toolbarheight
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.highlightColor }
                GradientStop { position: 0.10; color: "#262626" }
                GradientStop { position: 0.90; color: "#1F1F1F"}
                GradientStop { position: 1.0; color: Theme.highlightColor }
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
