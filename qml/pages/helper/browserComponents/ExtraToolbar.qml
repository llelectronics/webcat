import QtQuick 2.0
import Sailfish.Silica 1.0


// Extra Toolbar
Rectangle {
    id: extraToolbar
    width: parent.width

    property bool quickmenu
    property QtObject fPage: parent
    property alias minimizeButton: minimizeButton
    property alias nightModeButton: nightModeButton
    property alias orientationLockButton: orientationLockButton
    property alias readerModeButton: readerModeButton
    property alias searchModeButton: searchModeButton
    property alias shareButton: shareButton


    Image {
        anchors.fill: parent
        fillMode: Image.Tile
        source: "../../img/graphic-diagonal-line-texture.png"
        visible: mainWindow.privateBrowsing
        verticalAlignment: Image.AlignTop
    }

    //color: Theme.highlightBackgroundColor // As alternative perhaps maybe someday
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#353535" }
        GradientStop { position: 0.85; color: "#262626"}
    }

    height: 0
    z: 92
    opacity: 0
    visible: false
    anchors.bottom: fPage.toolbar.top
    anchors.bottomMargin: -2
    Rectangle { // grey seperation between page and toolbar
        id: toolbarExtraSep
        height: 2
        width: parent.width
        anchors.top: parent.top
        color: "grey"
    }
    SequentialAnimation {
        id: showToolbar
        ScriptAction { script : { extraToolbar.visible = true } }
        ParallelAnimation {
            NumberAnimation { target: extraToolbar; property: "opacity"; to: 1; duration: 400; easing.type: Easing.InOutQuad }
            NumberAnimation { target: extraToolbar; property: "height"; to: extratoolbarheight; duration: 300; easing.type: Easing.InOutQuad }
        }
    }

    SequentialAnimation {
        id: hideToolbar
        ParallelAnimation {
            NumberAnimation { target: extraToolbar; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InOutQuad }
            NumberAnimation { target: extraToolbar; property: "height"; to: 0; duration: 300; easing.type: Easing.InOutQuad }
        }
        ScriptAction { script : { extraToolbar.visible = false } }
    }

    function hide() {
        if (extraToolbar.opacity == 1 || extraToolbar.visible == true) {
            hideToolbar.start();
            extraToolbar.enabled = false;
            extraToolbar.quickmenu = false;
        }
    }

    function show() {
        if (extraToolbar.opacity == 0 || extraToolbar.visible == false) {
            showToolbar.start();
            extraToolbar.enabled = true;
        }
    }

    Label {
        id: actionLbl
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        font.pixelSize: Theme.fontSizeSmall
        text: {
            if (minimizeButton.highlighted) { return qsTr("Minimize") }
            else if (nightModeButton.highlighted) { if (fPage.nightMode) return qsTr("Day Mode"); else return qsTr("Night Mode") }
            else if (orientationLockButton.highlighted) { return qsTr("Lock Orientation") }
            else if (readerModeButton.highlighted) { return qsTr("Reader Mode") }
            else if (searchModeButton.highlighted) { return qsTr("Search") }
            else if (shareButton.highlighted) { return qsTr("Share") }
            else if (extraToolbar.opacity == 1 && extraToolbar.quickmenu) { return qsTr("Close menu") }
            else return "Extra Toolbar"
        }
    }

    IconButton {
        id: minimizeButton
        icon.source: "image://theme/icon-m-page-down"
        anchors.left: extraToolbar.left
        anchors.leftMargin: Theme.paddingSmall
        anchors.top: actionLbl.bottom
        anchors.topMargin: Theme.paddingSmall / 8
        icon.height: height
        icon.width: icon.height
        height: Theme.iconSizeMedium
        width: height
        onClicked: {
            if (fPage.toolbar.state == "expanded") fPage.toolbar.state = "minimized"
            highlighted = false;
            extraToolbar.hide();
        }
    }

    IconButton {
        id: newTabButton
        icon.source: "image://theme/icon-cover-new"
        anchors.left: minimizeButton.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.bottom: parent.bottom
        anchors.bottomMargin: actionLbl.height / 3
        icon.height: height
        icon.width: icon.height
        height: Theme.iconSizeMedium
        width: height
        visible: false
        onClicked: {
            mainWindow.loadInNewTab("about:bookmarks");
            highlighted = false;
            extraToolbar.hide();
        }
    }

    IconButton {
        id: nightModeButton
        icon.source: fPage.nightMode ? "image://theme/icon-camera-wb-sunny" : "image://theme/icon-camera-wb-tungsten"
        anchors.left: minimizeButton.right
        anchors.leftMargin: Theme.paddingSmall
        anchors.top: actionLbl.bottom
        anchors.topMargin: Theme.paddingSmall / 8
        icon.height: height
        icon.width: icon.height
        height: Theme.iconSizeMedium
        width: height
        onClicked: {
            if (!nightMode)
                fPage.enableNightMode()
            else
                fPage.disableNightMode()

            highlighted = false;
            extraToolbar.hide();
        }
    }


    IconButton {
        id: closeTabButton
        icon.source: "image://theme/icon-m-close"
        anchors.left: nightModeButton.right
        anchors.leftMargin: Theme.paddingSmall
        anchors.bottom: parent.bottom
        anchors.bottomMargin: actionLbl.height / 3
        icon.height: height
        icon.width: icon.height
        height: Theme.iconSizeMedium
        width: height
        visible: false
        onClicked: {
            if (enabled) {
                mainWindow.closeTab(mainWindow.tabModel.getIndexFromId(mainWindow.currentTab),pageId)
            }
            highlighted = false;
            extraToolbar.hide();
        }
        enabled: mainWindow.tabModel.count > 1
    }

    IconButton {
        id: orientationLockButton
        icon.source: "image://theme/icon-m-rotate"
        anchors.left: nightModeButton.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.top: actionLbl.bottom
        anchors.topMargin: Theme.paddingSmall / 8
        icon.height: height
        icon.width: icon.height
        height: Theme.iconSizeMedium
        width: height
        Image {
            source: "image://theme/icon-m-reset"
            anchors.fill: parent
            visible: fPage.allowedOrientations !== Orientation.All
        }
        onClicked: {
            if (fPage.allowedOrientations === Orientation.All) { fPage.allowedOrientations = fPage.orientation; mainWindow.orient = fPage.orientation }
            else { fPage.allowedOrientations = Orientation.All; mainWindow.orient = Orientation.All; }
            highlighted = false;
            extraToolbar.hide();
        }
    }

    IconButton {
        id: readerModeButton
        icon.source: "image://theme/icon-m-message"
        anchors.left: orientationLockButton.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.top: actionLbl.bottom
        anchors.topMargin: Theme.paddingSmall / 8
        icon.height: height
        icon.width: icon.height
        height: Theme.iconSizeMedium
        width: height
        onClicked: {
            fPage.toggleReaderMode()
            highlighted = false
            extraToolbar.hide();
        }
    }

    IconButton {
        id: searchModeButton
        icon.source: "image://theme/icon-m-search"
        anchors.left: readerModeButton.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.top: actionLbl.bottom
        anchors.topMargin: Theme.paddingSmall / 8
        icon.height: height
        icon.width: icon.height
        height: Theme.iconSizeMedium
        width: height
        onClicked: {
            searchMode = !searchMode
            highlighted = false
            searchText.forceActiveFocus();
            extraToolbar.hide();
        }
    }

    IconButton {
        id: shareButton
        icon.source: "image://theme/icon-m-share"
        anchors.left: searchModeButton.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.top: actionLbl.bottom
        anchors.topMargin: Theme.paddingSmall / 8
        icon.height: height
        icon.width: icon.height
        height: Theme.iconSizeMedium
        width: height
        visible: mainWindow.transferEngine.count > 0
        onClicked: {
            // Open Share Context Menu
            //console.debug("Open Share context menu here")
            shareContextMenu.share(fPage.webview.title, fPage.webview.url);
            highlighted = false;
            extraToolbar.hide();
        }
    }

}

