import QtQuick 2.0
import Sailfish.Silica 1.0
import "../db.js" as DB

// ToolBar
Rectangle {
    id: toolbar
    width: parent.width
    state: "expanded"
    z: 91

    property alias toolbarSep: toolbarSep
    property alias webTitle: webTitle
    property alias bookmarkButton: bookmarkButton
    property alias urlText: urlText
    property alias backIcon: backIcon
    property alias forIcon: forIcon
    property QtObject fPage: parent

    Image {
        anchors.fill: parent
        fillMode: Image.Tile
        source: "../../img/graphic-diagonal-line-texture.png"
        visible: mainWindow.privateBrowsing
        verticalAlignment: Image.AlignTop
    }

    //color: Theme.highlightBackgroundColor // As alternative perhaps maybe someday
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#262626" }
        GradientStop { position: 0.85; color: "#1F1F1F"}
    }
    height: fPage.toolbarheight
    anchors.bottom: fPage.bottom

    Rectangle { // grey seperation between page and toolbar
        id: toolbarSep
        height: 2
        width: parent.width
        anchors.top: parent.top
        color: "grey"
    }
    Behavior on height {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    states: [
        State {
            name: "expanded"
            PropertyChanges {
                target: toolbar
                height: fPage.toolbarheight
            }
            PropertyChanges {
                target: urlTitle
                visible: false
            }
            PropertyChanges {
                target: gotoButton
                visible: true
                enabled: true
            }
            PropertyChanges {
                target: backIcon
                visible: fPage.webview.canGoBack
                enabled: true
            }
            PropertyChanges {
                target: forIcon
                visible: fPage.webview.canGoForward
                enabled: true
            }
            PropertyChanges {
                target: urlText
                visible: true
                enabled: true
            }
            PropertyChanges {
                target: refreshButton
                visible: true
                enabled: true
            }
            PropertyChanges {
                target: bookmarkButton
                visible: fPage.readerMode ? true : false
                enabled: true
            }
            PropertyChanges {
                target: webTitle
                visible: urlText.visible
                enabled: true
            }
        },
        State {
            name: "minimized"
            PropertyChanges {
                target: toolbar
                height: Math.floor(fPage.toolbarheight / 3)
            }
            PropertyChanges {
                target: urlTitle
                visible: true
            }
            PropertyChanges {
                target: gotoButton
                visible: false
                enabled: false
            }
            PropertyChanges {
                target: backIcon
                visible: false
                enabled: false
            }
            PropertyChanges {
                target: forIcon
                visible: false
                enabled: false
            }
            PropertyChanges {
                target: urlText
                visible: false
                enabled: false
            }
            PropertyChanges {
                target: refreshButton
                visible: false
                enabled: false
            }
            PropertyChanges {
                target: bookmarkButton
                visible: false
                enabled: false
            }
            PropertyChanges {
                target: webTitle
                visible: false
                enabled: false
            }
        }
    ]

    Image {
        id: webIcon
        source: fPage.webview.icon != "" ? fPage.webview.icon : "image://theme/icon-lock-social";
        height: toolbar.height - Theme.paddingSmall
        width: height
        anchors.left: toolbar.left
        anchors.leftMargin: Theme.paddingSmall
        anchors.verticalCenter: toolbar.verticalCenter
        visible: toolbar.state == "minimized"
        asynchronous: true
        onSourceChanged: favIconSaver.requestPaint()
    }
    Canvas {
        id: favIconSaver
        visible: false
        width: Theme.iconSizeLauncher
        height: width
        onImageLoaded: requestPaint();
        onPaint: {
            //console.debug("[FirstPage.qml] favIconSaver paint called")
            var ctx = getContext("2d")
            ctx.clearRect(0,0,width,height);
            ctx.reset();
            ctx.drawImage(webIcon,0,0,width,height)
        }
    }

    Label {
        id: urlTitle
        text: fPage.webview.title + " - " + fPage.webview.url
        anchors.top: toolbar.top
        anchors.topMargin: 3
        anchors.left: webIcon.right
        anchors.leftMargin: Theme.paddingSmall
        font.bold: true
        font.pixelSize: Theme.fontSizeTiny //parent.height - 4
        visible: false
        truncationMode: TruncationMode.Fade
    }
    MouseArea {
        id: expandToolbar
        anchors.fill: toolbar
        onClicked: if (toolbar.state == "minimized") toolbar.state = "expanded"
        property int mx
        onPressed: {
            // Gesture detecting here
            mx = mouse.x
        }
        onReleased: {
            if (mx != -1 && mouse.x < mx - 150) { //Right to left swipe
                fPage.webview.goBack();
            }
            else if (mx != -1 && mouse.x > mx + 150) { // Left to right swipe
                fPage.webview.goForward();
            }
        }
        onCanceled: {
            mx = -1
        }
        onExited: {
            mx = -1
        }
    }

    IconButton {
        id: gotoButton
        icon.source: "image://theme/icon-m-tabs"
        anchors.left: toolbar.left
        anchors.leftMargin: Theme.paddingSmall
        height: fPage.toolbarheight / 1.5
        width: height
        icon.height: toolbar.height
        icon.width: icon.height
        anchors.verticalCenter: toolbar.verticalCenter

        function singleClick() {
            fPage.extraToolbar.hide()
            //pageStack.push(Qt.resolvedUrl("../../SelectUrl.qml"), { dataContainer: page, siteURL: fPage.webview.url, bookmarks: fPage.bookmarks, siteTitle: fPage.webview.title})
            if (!fPage.tabBar._tabListBg.visible) { fPage.tabBar.show(); fPage.bookmarkList.show(); }
            else { fPage.tabBar.hide(); fPage.bookmarkList.hide() }
        }

        function dblClick() {
            fPage.extraToolbar.hide()
            if (tabBar.visible && bookmarkList.visible) { tabBar.hide(); bookmarkList.hide() }
            if (prevTab != currentTab) mainWindow.switchToTab(prevTab);
            webview.visible = true
        }

        Timer {
            id:clickTimer
            interval: 200
            onTriggered: gotoButton.singleClick()
        }

        onClicked: {
            if(clickTimer.running)
            {
                gotoButton.dblClick()
                clickTimer.stop()
            }
            else
                clickTimer.restart()
        }

        Label {
            id: tabNumberLbl
            text: mainWindow.tabModel.count
            anchors.centerIn: parent
            font.pixelSize: Theme.fontSizeExtraSmall
            font.bold: true
            color: gotoButton.down ? Theme.highlightColor : Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
        }
        ProgressCircle {
            id: progressCircle
            z: 2
            anchors.centerIn: parent
            visible: urlLoading && toolbar.state == "expanded"
            height: gotoButton.height - Theme.paddingMedium
            width: height
            Timer {
                interval: 32
                repeat: true
                onTriggered: progressCircle.value = (progressCircle.value + 0.005) % 1.0
                running: urlLoading
            }
        }
    }

    IconButton {
        id:backIcon
        icon.source: "image://theme/icon-m-back"
        height: fPage.toolbarheight / 1.5
        width: height
        enabled: fPage.webview.canGoBack
        visible: fPage.webview.canGoBack
        anchors.left: gotoButton.right
        anchors.leftMargin: Theme.paddingMedium
        onClicked: {
            fPage.webview.goBack();
            forIcon.visible = true;
        }
        anchors.verticalCenter: toolbar.verticalCenter
        icon.height: toolbar.height
        icon.width: icon.height
    }

    IconButton {
        id: forIcon
        icon.source: "image://theme/icon-m-forward"
        height: fPage.toolbarheight / 1.5
        width: height
        enabled: fPage.webview.canGoForward
        visible: fPage.webview.canGoForward
        anchors.left: backIcon.visible ? backIcon.right : gotoButton.right
        anchors.leftMargin: Theme.paddingMedium
        onClicked: {
            fPage.webview.goForward();
        }
        anchors.verticalCenter: toolbar.verticalCenter
        icon.height: toolbar.height
        icon.width: icon.height
    }


    Label {
        id: webTitle
        text: fPage.webview.title

        anchors.top: toolbar.top
        anchors.topMargin: Theme.paddingSmall
        anchors.left: {
            if (forIcon.visible) return forIcon.right
            else if (backIcon.visible) return backIcon.right
            else return gotoButton.right
        }
        anchors.leftMargin: Theme.paddingMedium
        font.bold: true
        font.pixelSize: height //parent.height - 4
        visible: false
        onVisibleChanged: {
            if (visible) {
                urlText.anchors.topMargin = Theme.paddingSmall / 2
                height = Theme.fontSizeSmall / 1.337 + Theme.paddingSmall
            }
            else {
                urlText.anchors.topMargin = parent.height / 2 - urlText.font.pixelSize / 1.337
                height = 0
            }
        }

        color: urlText.color
        height: 0
        Behavior on height {
                NumberAnimation { duration: 200 }
        }
        width: urlText.width
        truncationMode: TruncationMode.Fade
        MouseArea {
            enabled: parent.visible
            anchors.fill: parent
            onClicked: {
                urlText.forceActiveFocus()
            }
        }
    }
    // Url textbox here
    TextField{
        id: urlText
        visible: true
        text: simplifyUrl(url)
        inputMethodHints: Qt.ImhUrlCharactersOnly
        placeholderText: qsTr("Enter an url")
        font.pixelSize: {
            if (webTitle.height != 0 && !focus && webTitle.text != "" && webTitle.visible) Theme.fontSizeTiny
            else Theme.fontSizeMedium
        }
        //y: parent.height / 2 - height / 4
        anchors.top: {
            if (webTitle.height != 0 && webTitle.text != "" && webTitle.visible) webTitle.bottom
            else parent.top
        }
        anchors.topMargin: parent.height / 2 - urlText.font.pixelSize / 1.337
        background: null
        color: Theme.primaryColor
        property string fullUrl: url
        anchors.left: {
            if (forIcon.visible) return forIcon.right
            else if (backIcon.visible) return backIcon.right
            else return gotoButton.right
        }
        anchors.leftMargin: Theme.paddingVerySmall
        anchors.right: refreshButton.left
        anchors.rightMargin: Theme.paddingVerySmall
        width: { //180 // minimum
            if (backIcon.visible === false && forIcon.visible === false) return parent.width - gotoButton.width - refreshButton.width
            else if (backIcon.visible === true && forIcon.visible === false) return parent.width - gotoButton.width - refreshButton.width - backIcon.width
            else if (backIcon.visible === false && forIcon.visible === true) return parent.width - gotoButton.width - refreshButton.width - forIcon.width
            else if (backIcon.visible === true && forIcon.visible === true) return parent.width - gotoButton.width - refreshButton.width - backIcon.width - backIcon.width
        }
        onFocusChanged: {
            if (focus) {
                webTitle.visible = false
                backIcon.visible = false
                forIcon.visible = false
                bookmarkButton.visible = true
                gotoButton.searchButton = true
                text = fullUrl
                color = Theme.primaryColor
                suggestionView.visible = false
                selectAll();
                anchors.topMargin = parent.height / 2 - urlText.font.pixelSize / 1.337
            }
            else {
                backIcon.visible = fPage.webview.canGoBack
                forIcon.visible = fPage.webview.canGoForward
                if (!fPage.readerMode) bookmarkButton.visible = false
                gotoButton.searchButton = false
                text = simplifyUrl(url)
                if (webTitle.text != "") {
                    webTitle.visible = urlText.visible
                }
            }
        }
        onTextChanged: {
            mainWindow.historyModel.clear();
            if (text.length > 1 && focus == true) {
                DB.searchHistory(text.toString());
            }
            else {
                fPage.suggestionView.visible = false;
            }
        }

        Keys.onEnterPressed: {
            if (fPage.suggestionView.visible) fPage.suggestionView.visible = false;
            fPage.webview.url = fixUrl(urlText.text);
            urlText.focus = false;  // Close keyboard
            fPage.webview.focus = true;
            if (bookmarkList.visible || tabBar.visible) {
                bookmarkList.hide()
                tabBar.hide()
            }
            urlTitle.visible = false
        }

        Keys.onReturnPressed: {
            if (fPage.suggestionView.visible) fPage.suggestionView.visible = false;
            fPage.webview.url = fixUrl(urlText.text);
            urlText.focus = false;
            fPage.webview.focus = true;
            if (bookmarkList.visible || tabBar.visible) {
                bookmarkList.hide()
                tabBar.hide()
            }
            urlTitle.visible = false
        }
        function simplifyUrl(url) {
            url = url.toString();
            if(url.match(/http:\/\//))
            {
                color = Theme.primaryColor
                url = url.substring(7);
            }
            if(url.match(/https:\/\//))
            {
                color = "lightgreen" // Indicator for https
                url = url.substring(8);
            }
            if(url.match(/^www\./))
            {
                url = url.substring(4);
            }
            return url;
        }
    }


    IconButton {
        id: refreshButton
        icon.source: {
            if (urlText.focus) "image://theme/icon-m-refresh"
            else fPage.webview.loading ? "image://theme/icon-m-reset" : "image://theme/icon-m-menu"
        }
        onClicked: {
            if (fPage.webview.loading) fPage.webview.stop()
            else if (icon.source == "image://theme/icon-m-refresh") fPage.webview.reload()
            else if (fPage.extraToolbar.opacity == 0 || fPage.extraToolbar.visible == false) {
                fPage.extraToolbar.quickmenu = false
                if (tabBar.visible && bookmarkList.visible) { tabBar.hide(); bookmarkList.hide() }
                fPage.extraToolbar.show()
            }
            else if (fPage.extraToolbar.opacity == 1 || fPage.extraToolbar.visible == true) {
                fPage.extraToolbar.hide()
            }
        }
        anchors.right: {
            if (urlText.focus || fPage.readerMode) bookmarkButton.left
            else parent.right
        }
        anchors.rightMargin: Theme.paddingMedium
        visible:true
        height: fPage.toolbarheight / 1.5
        width: height
        anchors.verticalCenter: toolbar.verticalCenter
        icon.height: toolbar.height
        icon.width: icon.height
    }


    IconButton {
        id: bookmarkButton
        property bool favorited: bookmarks.count > 0 && bookmarks.contains(fPage.webview.url)
        icon.source: {
            if (fPage.readerMode) fPage.nightMode ? "image://theme/icon-camera-wb-sunny" : "image://theme/icon-camera-wb-tungsten"
            else favorited ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
        }
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingSmall
        height: fPage.toolbarheight / 1.5
        width: height
        anchors.verticalCenter: toolbar.verticalCenter
        icon.height: toolbar.height
        icon.width: icon.height
        onClicked: {
            if (fPage.readerMode) {
                if (!nightMode)
                    fPage.enableNightMode();
                else
                    fPage.disableNightMode();
            }
            else {
                if (favorited) {
                    bookmarks.removeBookmark(fPage.webview.url.toString())
                } else {
                    bookmarks.addBookmark(fPage.webview.url.toString(), fPage.webview.title, userAgent)
                }
            }
        }
        onPressAndHold: {
            favIconSaver.loadImage(webIcon.source)
            //console.debug("[FirstPage.qml] favIconSaver image loaded: " + favIconSaver.isImageLoaded(webIcon.source));
            var favIconPath = _fm.getHome() + "/.local/share/applications/" + mainWindow.findHostname(fPage.webview.url) + "-" + mainWindow.findBaseName(fPage.webview.url) + ".png"
            var savingFav = favIconSaver.save(favIconPath);
            //console.debug("[FirstPage.qml] Saving FavIcon: " + savingFav)
            mainWindow.infoBanner.parent = page
            mainWindow.infoBanner.anchors.top = fPage.top
            mainWindow.createDesktopLauncher(favIconPath ,fPage.webview.title,fPage.webview.url);
            mainWindow.infoBanner.showText(qsTr("Created Desktop Launcher for " + fPage.webview.title));
        }
    }
}

