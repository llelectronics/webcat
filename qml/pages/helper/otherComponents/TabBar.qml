import QtQuick 2.0
import Sailfish.Silica 1.0
import "../otherComponents"

Item {
    id: root

    property QtObject dataContainer
    property int optimalHeight: {
        if (parent.orientation == Orientation.Landscape || parent.orientation == Orientation.LandscapeInverted) {
            parent.height
        }
        else {
            if (Theme.itemSizeExtraSmall + (tabModel.count * Theme.itemSizeSmall) < Screen.height / 2.25)
                Theme.itemSizeExtraSmall + (tabModel.count * Theme.itemSizeSmall) + Theme.paddingMedium
            else
                parent.height / 2.25
        }
    }
    property alias _tabListBg: tabListBg
    property alias _tabListView: tabListView
    property alias _tabHead: tabHead

    signal tabClicked(int idx, var pageId);
    signal newTabClicked();
    signal newWindowClicked();
    signal menuClosed();

    function refreshTabs() {
        tabListView.currentIndex = mainWindow.tabModel.getIndexFromId(mainWindow.currentTab);
        mainWindow.currentTabIndex = tabListView.currentIndex
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

    SequentialAnimation {
        id: showToolbar
        ScriptAction { script : { tabListBg.visible = true } }
        ParallelAnimation {
            NumberAnimation { target: tabListBg; property: "opacity"; to: 1; duration: 400; easing.type: Easing.InOutQuad }
            NumberAnimation { target: tabListBg; property: "height"; to: optimalHeight; duration: 300; easing.type: Easing.InOutQuad }
        }
    }

    SequentialAnimation {
        id: hideToolbar
        ParallelAnimation {
            NumberAnimation { target: tabListBg; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InOutQuad }
            NumberAnimation { target: tabListBg; property: "height"; to: 0; duration: 300; easing.type: Easing.InOutQuad }
        }
        ScriptAction { script : { tabListBg.visible = false } }
    }

    function hide() {
        if (tabListBg.opacity == 1 || tabListBg.visible == true) {
            hideToolbar.start();
            tabListBg.enabled = false;
        }
    }

    function show() {
        if (tabListBg.opacity == 0 || tabListBg.visible == false) {
            showToolbar.start();
            tabListBg.enabled = true;
            refreshTabs();
        }
    }

    function quickReShow() {
        tabListBg.visible = false
        tabListBg.opacity = 0
        tabListBg.height = 0
        tabListBg.visible = true
        tabListBg.opacity = 1
        tabListBg.height = optimalHeight
        refreshTabs();
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
                    root.tabClicked(index,model.pageid)
                }
            }
        }
    }

    Rectangle {
        id: tabListBg
        gradient: normalBg
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: parent.width
        height: parent.height

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
                source: "../../img/graphic-diagonal-line-texture.png"
                visible: mainWindow.privateBrowsing
                verticalAlignment: Image.AlignTop
            }
            anchors.top: {
                if (root.parent.orientation == Orientation.Portrait || root.parent.orientation == Orientation.PortraitInverted) parent.top
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
                    root.newTabClicked();
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
// Maybe maybe not
            IconButton {
                id: newWindowButton
                icon.source: "image://theme/icon-m-tab"
                anchors.left: newTabImg.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                icon.height: height
                icon.width: icon.height
                height: Theme.iconSizeSmall * 1.4
                width: height
                Image {
                    anchors.fill: parent
                    source: "image://theme/icon-m-add"
                }
                onClicked: {
                    root.newWindowClicked();
                }
            }

        }

        SilicaListView {
            id: tabListView
            width: parent.width
            height: parent.height - tabHead.height - Theme.paddingMedium
            clip: true
            anchors.top: {
                if (root.parent.orientation == Orientation.Portrait || root.parent.orientation == Orientation.PortraitInverted) tabHead.bottom
                else parent.top
            }
            anchors.topMargin: Theme.paddingSmall

            //orientation: ListView.Horizontal
            verticalLayoutDirection: {
                if (root.parent.orientation == Orientation.Landscape || root.parent.orientation == Orientation.LandscapeInverted) ListView.BottomToTop
                else ListView.TopToBottom
            }

            Image {
                anchors.fill: parent
                fillMode: Image.Tile
                source: "../../img/graphic-diagonal-line-texture.png"
                visible: mainWindow.privateBrowsing
                verticalAlignment: Image.AlignTop
            }

            model: tabModel
            delegate: tabDelegate
            highlight:

                Rectangle {
                width: root.width; height: Theme.itemSizeSmall
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
        parent: root.parent
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
            if (root.parent.orientation == Orientation.Portrait || root.parent.orientation == Orientation.PortraitInverted) tabListBg.y - Theme.itemSizeMedium * 3.25  // 4 MenuItems for the moment
            else tabHead.y - Theme.itemSizeMedium * 3.25
        }
        dataContainer: root.dataContainer
        onMenuClosed: root.menuClosed()
    }

}
