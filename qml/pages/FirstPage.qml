/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0
import "helper/jsmime.js" as JSMIME
import "helper/db.js" as DB
import "helper/yt.js" as YT

Page {
    id: page
    allowedOrientations: Orientation.All

    // minimize toolbar when switching to landscape
    onOrientationChanged: {
        if (orientation == Orientation.Landscape && toolbar.state == "expanded") toolbar.state = "minimized"
        else if (orientation == Orientation.Portrait && toolbar.state == "minimized") toolbar.state = "expanded"
    }

    property alias url: webview.url
    property alias toolbar: toolbar
    property string agent: userAgent

    property ListModel bookmarks
    property ListModel tabModel
    property SilicaListView tabListView
    property bool loadHP
    property string pageId
    backNavigation: false
    forwardNavigation: false
    showNavigationIndicator: false
    property QtObject _ngfEffect
    property alias suggestionView: suggestionView
    property bool imageLongPressAvailability;
    property bool mediaYt;
    property bool mediaLink;
    property string ytStreamUrl;
    property bool ytUrlLoading;
    property bool readerMode: false

    Component.onCompleted: {
        _ngfEffect = Qt.createQmlObject("import org.nemomobile.ngf 1.0; NonGraphicalFeedback { event: 'pulldown_lock' }",
                           minimizeButton, 'NonGraphicalFeedback');
    }

    onMediaLinkChanged: {
        mediaDownloadRec.visible = !mediaDownloadRec.visible
    }

    function loadUrl(requestUrl) {
        var valid = requestUrl
        if (valid.indexOf(":")<0) {
            if (valid.indexOf(".")<0 || valid.indexOf(" ")>=0) {
                url = mainWindow.searchEngine.replace("%s",valid)
            } else {
                url = "http://"+valid
            }
        }
    }
    // Todo: Need to merge fixUrl with loadUrl if latter is even necessary anymore
    function fixUrl(nonFixedUrl) {
        var valid = nonFixedUrl
        if (valid.indexOf(":")<0) {
            if (valid.indexOf(".")<0 || valid.indexOf(" ")>=0) {
                return url = mainWindow.searchEngine.replace("%s",valid)
            } else {
                return "http://"+valid;
            }
        }
        else return valid;
    }

    function showContextMenu(hrefUrl) {
        contextMenu.visible = true;
        contextUrl.text = hrefUrl;
    }

    function toggleReaderMode() {
        if (readerMode) {
            webview.reload();
        } else {
            // FIXME: dirty hack to load js from local file
            var xhr = new XMLHttpRequest;
            xhr.open("GET", "./helper/readability.js");
            xhr.onreadystatechange = function() {
                if (xhr.readyState == XMLHttpRequest.DONE) {
                    var read = new Object({'type':'readability', 'content': xhr.responseText });
                    webview.experimental.postMessage( JSON.stringify(read) );
                }
            }
            xhr.send();
        }
        readerMode = !readerMode;
    }

    ProgressCircle {
        id: progressCircle
        z: 2
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        visible: urlLoading
        width: 32
        height: 32
        Timer {
            interval: 32
            repeat: true
            onTriggered: progressCircle.value = (progressCircle.value + 0.005) % 1.0
            running: urlLoading
        }
    }

    Item{
        id: popup
        anchors.centerIn: parent
        z: 3
        width: 400
        height: 400
        visible: false
        Rectangle {
            anchors.fill: parent
            border.width: 2
            opacity: 0.98
            border.color: "red"
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#262626" }
                GradientStop { position: 0.85; color: "#1F1F1F"}
            }
            Label {
                anchors.fill: parent
                color: "white" //Theme.fontColorHighlight
                text: errorText
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: popup.visible = false
        }
    }


    SilicaWebView {
        id: webview
        url: siteURL

        width: page.width
        height: page.height - 20 // minimized toolbar size. We don't want to set the toolbar.height here otherwise it would make webview resizing which is painfully slow

        // We don't want pageStackNavigation to interfere
        overridePageStackNavigation: true
        header: PageHeader {height: 0}

        onUrlChanged: {
            // There seems to be a bug where back and forward navigation is not shown even if webview.canGoBack or ~Forward
            backIcon.visible = true
            forIcon.visible = webview.canGoForward
            if ((/^rtsp:/).test(url) || (/^rtmp:/).test(url) || (/^mms:/).test(url)) {
                console.debug("Remote link clicked. Open with external viewer")
                Qt.openUrlExternally(url);
            }
            if (JSMIME.getMimesByPath(url.toString()).toString().match("^audio") || JSMIME.getMimesByPath(url.toString()).toString().match("^video")) {
                // Audio or Video link clicked. Download should start now
                console.debug("Video or Audio Link clicked... download should start now")
            }
            if (YT.checkYoutube(url.toString())) {
                mediaYt = true;
                ytUrlLoading = true
                mediaLink = true;
                mediaDownloadRec.visible = true
            }
            else {
                mediaYt = false;
                mediaLink = false;
                ytUrlLoading = false
                mediaDownloadRec.visible = false
            }

            // Add to url history
            DB.addHistory(url);
        }

        // Settings loaded from mainWindow
        experimental.userAgent: page.agent
        experimental.preferences.minimumFontSize: mainWindow.minimumFontSize
        experimental.preferences.defaultFontSize: mainWindow.defaultFontSize
        experimental.preferences.defaultFixedFontSize: mainWindow.defaultFixedFontSize
        experimental.preferences.dnsPrefetchEnabled: mainWindow.dnsPrefetch
        experimental.preferences.autoLoadImages: mainWindow.loadImages
        experimental.preferences.offlineWebApplicationCacheEnabled: mainWindow.offlineWebApplicationCache
        experimental.preferences.privateBrowsingEnabled: mainWindow.privateBrowsing


        // Scale the websites like g+ and others a little bit for better reading
        experimental.deviceWidth: page.width / 1.25
        experimental.deviceHeight: page.height
        experimental.itemSelector: PopOver {}
        experimental.preferences.fullScreenEnabled: true
        experimental.preferences.developerExtrasEnabled: true

        // This userScript makes longpress detection and other things working
        experimental.userScripts: [Qt.resolvedUrl("helper/userscript.js")]
        experimental.preferences.navigatorQtObjectEnabled: true

        experimental.certificateVerificationDialog: Item {
            Component.onCompleted: {
                var dialog = pageStack.push(Qt.resolvedUrl("ConfirmDialog.qml"),
                                            {"label":  "Accept certificate from " + url + " ?"})
                dialog.accepted.connect(function() {
                    model.accept();
                })
                dialog.rejected.connect(function() {
                    model.reject();
                    webview.stop();
                })
            }
       }

        experimental.authenticationDialog: Item {
            Component.onCompleted: {
                var dialog = pageStack.push(Qt.resolvedUrl("AuthenticationDialog.qml"),
                                            {"hostname":  model.hostname, "realm": model.realm})
                dialog.accepted.connect(function() {
                    model.accept(dialog.username, dialog.password)
                })
                dialog.rejected.connect(function() {
                    model.reject()
                })
            }
       }

        experimental.onDownloadRequested: {
            // Call downloadmanager here with the url
            console.debug("Download requested: " + url);
            pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": url});
        }

        experimental.onMessageReceived: {
            console.log('onMessageReceived: ' + message.data );
            var data = null
            try {
                data = JSON.parse(message.data)
            } catch (error) {
                console.log('onMessageReceived: ' + message.data );
                return
            }
            switch (data.type) {
            case 'link': {
                //console.debug("Link clicked with target" + data.target);
                if (data.target === '_blank') { // open link in new tab
                    openNewTab('page-'+salt(), fixUrl(data.href), false);
                }
                else if (data.target && data.target != "_parent") openNewTab('page-'+salt(), fixUrl(data.href), false);
                break;
            }
            case 'longpress': {
                if (data.img) {
                    imageLongPressAvailability = true;
                    showContextMenu(data.img);
                }
                else if (data.href && data.href != "CANT FIND LINK") {
                    imageLongPressAvailability = false;
                    showContextMenu(data.href);
                }
                if ('text' in data) {
                    selection.mimedata = data.text;
                    selection.show(data.left, data.top, data.width, data.height)
                }
            }
            case 'selectionadjusted' : {
                if ('text' in data) {
                    //console.debug("[firstPage.qml] Copy text in adjusted selection")
                    selection.mimedata = data.text;
                    selection.copy();
                }
            }


            case 'input': {
                // Seems not to work reliably as only input hide on keyboard hide is received
                if (toolbar.state == "expanded" && data.state == "show" && ! urlText.focus == true) toolbar.state = "minimized"
            }
            }
        }

        onLoadingChanged:
        {
            if (loadRequest.status == WebView.LoadStartedStatus)
            {
                urlLoading = true;
                contextMenu.visible = false;
                mediaLink = false;
                readerMode = false;
            }
            else if (loadRequest.status == WebView.LoadFailedStatus)
            {
                urlLoading = false;
                errorText = "Load failed\n"+loadRequest.errorString
                // Don't show error on rtsp, rtmp or mms links as they are opened externally
                if (! (/^rtsp:/).test(url) || (/^rtmp:/).test(url) || (/^mms:/).test(url)) {
                    console.debug("Load failed rtsp,rtmp or mms not detected and no valid http or https");
                    if (! (/handled by the media engine/).test(errorText)) {
                        console.debug("Load failed audio or video file not detected and no valid http or https");
                        popup.visible = true
                    }
                    else if ((/handled by the media engine/).test(errorText)) {
                        //TODO: Enable Downloadmanager here
                        mediaLink = true;
                    }
                }
            }
            else
            {
                urlLoading = false;
                if (url == "about:bookmarks" && loadHP === true) pageStack.push(Qt.resolvedUrl("SelectUrl.qml"), { dataContainer: page, siteURL: webview.url, bookmarks: page.bookmarks, siteTitle: webview.title})
                if (mainWindow.currentTabBg != "") mainWindow.tabModel.setProperty(mainWindow.tabModel.getIndexFromId(mainWindow.currentTabBg), "title", webview.title);
                else mainWindow.tabModel.setProperty(mainWindow.tabModel.getIndexFromId(mainWindow.currentTab), "title", webview.title);
                //console.debug(tabModel.get(0).title);
            }
        }
        onNavigationRequested: {
            // detect URL scheme prefix, most likely an external link
            var schemaRE = /^\w+:/;
            if (schemaRE.test(request.url)) {
                request.action = WebView.AcceptRequest;
            } else {
                if (!(/^rtsp:/).test(request.url) || !(/^rtmp:/).test(request.url) || !(/^mms:/).test(request.url)) {
                    request.action = WebView.IgnoreRequest;
                    popup.visible = true
                    // delegate request.url here
                }
            }
        }

        Selection {
            id: selection

            anchors.fill: parent
            visible: false

            property var mimedata: null

            function createData() {
                if (mimedata === null) {
                    hiddenTxtBox.text = ""
                }
            }

            function clearData() {
                if (mimedata !== null) {
                    delete mimedata
                    mimedata = null
                    hiddenTxtBox.text = ""
                }
            }

            function actionTriggered() {
                selection.visible = false
            }

            function show(x, y, width, height) {
                var scale = webview.experimental.test.contentsScale * webview.experimental.test.devicePixelRatio
                rect.x = x * scale + webview.contentX
                rect.y = y * scale + webview.contentY
                rect.width = width * scale
                rect.height = height * scale
                //console.debug("x:"+x+" y:"+y+" width:"+width+" height:"+height)
                visible = true
                //__showPopover()
            }

            onTextClicked: {
                pageStack.push(Qt.resolvedUrl("SelectionEditPage.qml"), { editText: hiddenTxtBox.text })
            }

            onResized: {
                //console.debug("[firstPage.qml] Resized selection. postMessage to userscript.js")
                var message = new Object
                message.type = 'adjustselection'
                var rect = selection.rect
                var scale = webview.experimental.test.contentsScale * webview.experimental.test.devicePixelRatio
                message.left = Math.round((rect.x - webview.contentX) / scale)
                message.right = Math.round((rect.x + rect.width - webview.contentX) / scale)
                message.top = Math.round((rect.y - webview.contentY) / scale)
                message.bottom = Math.round((rect.y + rect.height - webview.contentY) / scale)
                //console.debug("[firstPage.qml] PostMessage: " + JSON.stringify(message))
                webview.experimental.postMessage(JSON.stringify(message))
                //webview.experimental.postMessage( JSON.stringify(read) );
            }

            function copy() {
                hiddenTxtBox.text = mimedata;
                //console.debug("Marked text: " + mimedata);
                hiddenTxtBox.selectAll();
                hiddenTxtBox.copy();
            }
        }

        MouseArea {
            id: contextOverlay;
            anchors.fill: parent;
            enabled: contextMenu.visible
            onClicked: contextMenu.visible = false
        }
        VerticalScrollDecorator {
            color: Theme.highlightColor // Otherwise we might end up with white decorator on white background
            width: Theme.paddingSmall // We want to see it properly
            flickable: webview
        }

    } // WebView
    FancyScroller {
        flickable: webview

        onUpScrolling: if (toolbar.state === "minimized") toolbar.state = "expanded"
        onDownScrolling: if (toolbar.state === "expanded") toolbar.state = "minimized"
    }

    // ToolBar
    Rectangle {
        id: toolbar
        width: page.width
        state: "expanded"
        //color: Theme.highlightBackgroundColor // As alternative perhaps maybe someday
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#262626" }
            GradientStop { position: 0.85; color: "#1F1F1F"}
        }
        height: 72
        anchors.bottom: page.bottom
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
                    height: 72
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
                    visible: webview.canGoBack
                    enabled: true
                }
                PropertyChanges {
                    target: forIcon
                    visible: webview.canGoForward
                    enabled: true
                }
                PropertyChanges {
                    target: urlText
                    visible: true
                    enabled: true
                }
                PropertyChanges {
                    target: refreshButton
                    visible: false
                    enabled: true
                }
                PropertyChanges {
                    target: bookmarkButton
                    visible: true
                    enabled: true
                }
            },
            State {
                name: "minimized"
                PropertyChanges {
                    target: toolbar
                    height: 22
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
            }
        ]

        Label {
            id: urlTitle
            text: webview.title + " - " + webview.url
            anchors.top: toolbar.top
            anchors.topMargin: 3
            anchors.left: toolbar.left
            anchors.leftMargin: Theme.paddingSmall
            font.bold: true
            font.pixelSize: parent.height - 4
            visible: false
        }
        MouseArea {
            id: expandToolbar
            enabled: toolbar.state == "minimized"
            anchors.fill: toolbar
            onClicked: toolbar.state = "expanded"
            property int mx
            onPressed: {
                // Gesture detecting here
                mx = mouse.x
            }
            onReleased: {
                if (mx != -1 && mouse.x < mx - 150) { //Right to left swipe
                    webview.goBack();
                }
                else if (mx != -1 && mouse.x > mx + 150) { // Left to right swipe
                    webview.goForward();
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
            onClicked: pageStack.push(Qt.resolvedUrl("SelectUrl.qml"), { dataContainer: page, siteURL: webview.url, bookmarks: page.bookmarks, siteTitle: webview.title})
            property int mx
            onPressAndHold: {
                //if (toolbar.state == "expanded") toolbar.state = "minimized"
                //TODO show extraToolbar
                if (extraToolbar.opacity == 0) {
                    extraToolbar.visible = true
                    extraToolbar.opacity = 1
                    minimizeButton.highlighted = true
                    mx = mouse.x
                }
            }
            onPositionChanged: {
                if (extraToolbar.opacity == 1) {
                    //console.debug("X Position: " + mouse.x)
                    if (mouse.x > newTabButton.x && mouse.x < newWindowButton.x) { minimizeButton.highlighted = false; newTabButton.highlighted = true; newWindowButton.highlighted = false; reloadThisButton.highlighted = false; orientationLockButton.highlighted = false; readerModeButton.highlighted = false }
                    else if (mouse.x < newTabButton.x) {minimizeButton.highlighted = true; newTabButton.highlighted = false; newWindowButton.highlighted = false; reloadThisButton.highlighted = false; orientationLockButton.highlighted = false; readerModeButton.highlighted = false }
                    else if (mouse.x > newWindowButton.x && mouse.x < reloadThisButton.x) { minimizeButton.highlighted = false; newTabButton.highlighted = false; newWindowButton.highlighted = true; reloadThisButton.highlighted = false; orientationLockButton.highlighted = false; readerModeButton.highlighted = false }
                    else if (mouse.x > reloadThisButton.x && mouse.x < orientationLockButton.x) { minimizeButton.highlighted = false; newTabButton.highlighted = false; newWindowButton.highlighted = false; reloadThisButton.highlighted = true; orientationLockButton.highlighted = false; readerModeButton.highlighted = false }
                    else if (mouse.x > orientationLockButton.x && mouse.x < orientationLockButton.x + orientationLockButton.width + Theme.paddingMedium) { minimizeButton.highlighted = false; newTabButton.highlighted = false; newWindowButton.highlighted = false; reloadThisButton.highlighted = false; orientationLockButton.highlighted = true; readerModeButton.highlighted = false }
                    else if (mouse.x > readerModeButton.x && mouse.x < readerModeButton.x + readerModeButton.width + Theme.paddingMedium) { minimizeButton.highlighted = false; newTabButton.highlighted = false; newWindowButton.highlighted = false; reloadThisButton.highlighted = false; orientationLockButton.highlighted = false; readerModeButton.highlighted = true }
                    else if (mouse.x > readerModeButton.x + readerModeButton.width + Theme.paddingMedium) { minimizeButton.highlighted = false; newTabButton.highlighted = false; newWindowButton.highlighted = false; reloadThisButton.highlighted = false; orientationLockButton.highlighted = false; readerModeButton.highlighted = false }
                }
            }

            onReleased: {
                if (extraToolbar.opacity == 1 && minimizeButton.highlighted == true) { minimizeButton.clicked(undefined); extraToolbar.opacity = 0 }
                else if (extraToolbar.opacity == 1 && newTabButton.highlighted == true) { newTabButton.clicked(undefined); extraToolbar.opacity = 0 }
                else if (extraToolbar.opacity == 1 && newWindowButton.highlighted == true) { newWindowButton.clicked(undefined); extraToolbar.opacity = 0 }
                else if (extraToolbar.opacity == 1 && reloadThisButton.highlighted == true) { reloadThisButton.clicked(undefined); extraToolbar.opacity = 0 }
                else if (extraToolbar.opacity == 1 && orientationLockButton.highlighted == true) { orientationLockButton.clicked(undefined); extraToolbar.opacity = 0 }
                else if (extraToolbar.opacity == 1 && readerModeButton.highlighted == true) { readerModeButton.clicked(undefined); extraToolbar.opacity = 0 }
                else if (extraToolbar.opacity == 1) extraToolbar.opacity = 0
                extraToolbar.visible = false;
            }

            Label {
                text: tabModel.count
                x: (parent.width - contentWidth) / 2 - 5
                y: (parent.height - contentHeight) / 2 - 5
                font.pixelSize: Theme.fontSizeExtraSmall
                font.bold: true
                color: gotoButton.down ? Theme.highlightColor : Theme.highlightDimmerColor
                horizontalAlignment: Text.AlignHCenter
            }
        }

        IconButton {
            id:backIcon
            icon.source: "image://theme/icon-m-back"
            enabled: webview.canGoBack
            visible: webview.canGoBack
            anchors.left: gotoButton.right
            anchors.leftMargin: Theme.paddingSmall
            onClicked: {
                webview.goBack();
                forIcon.visible = true;
            }
        }

        IconButton {
            id: forIcon
            icon.source: "image://theme/icon-m-forward"
            enabled: webview.canGoForward
            visible: webview.canGoForward
            anchors.left: backIcon.visible ? backIcon.right : gotoButton.right
            anchors.leftMargin: Theme.paddingSmall
            onClicked: {
                webview.goForward();
            }
        }

        // Url textbox here
        TextField{
            id: urlText
            visible: true
            text: url
            inputMethodHints: Qt.ImhUrlCharactersOnly
            placeholderText: qsTr("Enter an url")
            font.pixelSize: Theme.fontSizeMedium
            y: parent.height / 2 - height / 4
            anchors.left: {
                if (forIcon.visible) return forIcon.right
                else if (backIcon.visible) return backIcon.right
                else return gotoButton.right
            }
            anchors.leftMargin: Theme.paddingVerySmall
            width: { //180 // minimum
                if (backIcon.visible === false && forIcon.visible === false) return parent.width - gotoButton.width - bookmarkButton.width
                else if (backIcon.visible === true && forIcon.visible === false) return parent.width - gotoButton.width - bookmarkButton.width - backIcon.width
                else if (backIcon.visible === false && forIcon.visible === true) return parent.width - gotoButton.width - bookmarkButton.width - forIcon.width
                else if (backIcon.visible === true && forIcon.visible === true) return parent.width - gotoButton.width - bookmarkButton.width - backIcon.width - backIcon.width
            }
            onFocusChanged: {
                if (focus) {
                    backIcon.visible = false
                    forIcon.visible = false
                    bookmarkButton.visible = false
                    refreshButton.visible = true
                    selectAll();
                }
                else {
                    backIcon.visible = webview.canGoBack
                    forIcon.visible = webview.canGoForward
                    bookmarkButton.visible = true
                    refreshButton.visible = false
                }
            }
            onTextChanged: {
                mainWindow.historyModel.clear();
                if (text.length > 1 && focus == true) {
                    DB.searchHistory(text.toString());
                }
                else {
                    page.suggestionView.visible = false;
                }
            }

            Keys.onEnterPressed: {
                urlText.focus = false;  // Close keyboard
                webview.url = fixUrl(urlText.text);
            }

            Keys.onReturnPressed: {
                urlText.focus = false;
                webview.url = fixUrl(urlText.text);
            }

        }


        IconButton {
            id: refreshButton
            icon.source: webview.loading ? "image://theme/icon-m-reset" : "image://theme/icon-m-refresh"
            onClicked: webview.loading ? webview.stop() : webview.reload()
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingSmall
            visible:false
        }


        IconButton {
            id: bookmarkButton
            property bool favorited: bookmarks.count > 0 && bookmarks.contains(webview.url)
            icon.source: favorited ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingSmall
            onClicked: {
                if (favorited) {
                    bookmarks.removeBookmark(webview.url.toString())
                } else {
                    bookmarks.addBookmark(webview.url.toString(), webview.title, userAgent)
                }
            }
        }
    }

    // Extra Toolbar
    Rectangle {
        id: extraToolbar
        width: page.width
        //color: Theme.highlightBackgroundColor // As alternative perhaps maybe someday
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#262626" }
            GradientStop { position: 0.85; color: "#1F1F1F"}
        }
        height: 96
        opacity: 0
        visible: false
        anchors.bottom: toolbar.top
        anchors.bottomMargin: -2
        Rectangle { // grey seperation between page and toolbar
            id: toolbarExtraSep
            height: 2
            width: parent.width
            anchors.top: parent.top
            color: "grey"
        }
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        Label {
            id: actionLbl
            anchors.top: parent.top
            anchors.topMargin: 3
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
            font.pixelSize: parent.height - (minimizeButton.height + 10)
            text: {
                if (minimizeButton.highlighted) { _ngfEffect.play(); return qsTr("Minimize") }
                else if (newTabButton.highlighted) { _ngfEffect.play(); return qsTr("New Tab") }
                else if (newWindowButton.highlighted) { _ngfEffect.play(); return qsTr("New Window") }
                else if (reloadThisButton.highlighted) { _ngfEffect.play(); return qsTr("Reload") }
                else if (orientationLockButton.highlighted) { _ngfEffect.play(); return qsTr("Lock Orientation") }
                else if (readerModeButton.highlighted) { _ngfEffect.play(); return qsTr("Reader Mode") }
                else if (extraToolbar.opacity == 1) { _ngfEffect.play(); return qsTr("Close menu") }
                else return "Extra Toolbar"
            }
        }

        IconButton {
            id: minimizeButton
            icon.source: "image://theme/icon-cover-next-song"
            rotation: 90
            anchors.left: extraToolbar.left
            anchors.leftMargin: Theme.paddingSmall
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            icon.height: 48
            icon.width: 48
            width: 64
            height: 64
            onClicked: if (toolbar.state == "expanded") toolbar.state = "minimized"
        }

        IconButton {
            id: newTabButton
            icon.source: "image://theme/icon-cover-new"
            anchors.left: minimizeButton.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            icon.height: 48
            icon.width: 48
            width: 64
            height: 64
            onClicked: mainWindow.loadInNewTab("about:bookmarks");
        }

        IconButton {
            id: newWindowButton
            icon.source: "image://theme/icon-m-tab"
            anchors.left: newTabButton.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            icon.height: 64
            icon.width: 64
            width: 64
            height: 64
            Image {
                anchors.fill: parent
                source: "image://theme/icon-m-add"
            }
            onClicked: mainWindow.openNewWindow("about:bookmarks");
        }


        IconButton {
            id: reloadThisButton
            icon.source: "image://theme/icon-m-refresh"
            anchors.left: newWindowButton.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            icon.height: 64
            icon.width: 64
            width: 64
            height: 64
            onClicked: webview.reload();
        }

        IconButton {
            id: orientationLockButton
            icon.source: "image://theme/icon-m-backup"
            anchors.left: reloadThisButton.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            icon.height: 64
            icon.width: 64
            width: 64
            height: 64
            Image {
                source: "image://theme/icon-m-reset"
                anchors.fill: parent
                visible: page.allowedOrientations !== Orientation.All
            }
            onClicked: {
                if (page.allowedOrientations === Orientation.All) page.allowedOrientations = page.orientation
                else page.allowedOrientations = Orientation.All
            }
        }

        IconButton {
            id: readerModeButton
            icon.source: "image://theme/icon-m-message"
            anchors.left: orientationLockButton.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            icon.height: 64
            icon.width: 64
            width: 64
            height: 64
            onClicked: {
                toggleReaderMode()
            }
        }

    }


    // On Loading show cancel loading button
    Rectangle {
        id: loadingRec
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.65; color: Theme.highlightBackgroundColor}
        }
        anchors.bottom: toolbar.top
        width: parent.width
        height: 48
        visible: webview.loading
        IconButton {
            id: cancelButton
            icon.source: "image://theme/icon-m-close"
            onClicked:  webview.stop()
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingSmall
            anchors.verticalCenter: parent.verticalCenter

        }
    }

    // On Media Loaded show download button
    Rectangle {
        id: mediaDownloadRec
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#262626" }
            GradientStop { position: 0.85; color: "#1F1F1F"}
        }
        anchors.bottom: {
            if (loadingRec.visible == true) return loadingRec.top
            else return toolbar.top
        }
        //anchors.bottomMargin: Theme.paddingSmall // This looks ugly
        width: parent.width
        height: 72
        visible: false
        onVisibleChanged: {
            if (visible && mediaYt) {
                YT.getYoutubeDirectStream(url.toString())
            }
        }
        ProgressCircle {
            id: progressCircleYt
            z: 2
            anchors.centerIn: parent
            visible: ytUrlLoading
            width: 32
            height: 32
            Timer {
                interval: 32
                repeat: true
                onTriggered: progressCircleYt.value = (progressCircleYt.value + 0.005) % 1.0
                running: ytUrlLoading
            }
        }

        IconButton {
            icon.source: "image://theme/icon-m-device-download"
            onClicked:  {
                if (mediaYt) pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": ytStreamUrl});
                else pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": url});
            }
            visible: ! progressCircleYt.visible
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingSmall
            anchors.verticalCenter: parent.verticalCenter
        }
        IconButton {
            icon.source: "image://theme/icon-m-play"
            onClicked:  {
                if (mainWindow.vPlayerExists && mediaYt) mainWindow.openWithvPlayer(ytStreamUrl); //mainWindow.openWithvPlayer(url); // perhaps make this configurable
                else Qt.openUrlExternally(url);
            }
            visible: ! progressCircleYt.visible
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall
            anchors.verticalCenter: parent.verticalCenter
        }


    }

    // Long press contextmenu for link
    Rectangle {
        id: contextMenu
        visible: false
        anchors.bottom: toolbar.top
        anchors.bottomMargin: -toolbarSep.height
        width: parent.width;
        height: {
            if (visible == true) return contextUrl.height + contextButtons.height + Theme.paddingMedium
            else return 0
        }
        Behavior on height {
            NumberAnimation { target: contextMenu; property: "height"; duration: 350; easing.type: Easing.InOutQuad }
        }
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#262626" }
            GradientStop { position: 0.85; color: "#1F1F1F"}
        }
        opacity: 0.98
        TextField {
            id: contextUrl
            color: "white"
            readOnly: true
            anchors {
                top: parent.top; left: parent.left; right: parent.right;
                margins: 20; topMargin: 10
            }
        }

        Column {
            id: contextButtons
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            // Not really necessary as you can just click on the link
            //            Button {
            //                text: "Open"
            //                width: widestBtn.width
            //                onClicked: { webview.url = fixUrl(contextUrl.text); contextMenu.visible = false }
            //            }
            Button {
                width: widestBtn.width
                text: "Open in New Window"
                onClicked: { mainWindow.openNewWindow(fixUrl(contextUrl.text)); contextMenu.visible = false }
            }
            Button {
                text: "Open in New Tab"
                width: widestBtn.width
                onClicked: { mainWindow.openNewTab("page"+salt(), fixUrl(contextUrl.text), true); contextMenu.visible = false }
            }
            Button {
                id: widestBtn
                text: "Open in Private New Window"
                onClicked: { mainWindow.openPrivateNewWindow(fixUrl(contextUrl.text)); contextMenu.visible = false }
            }
            Button {
                text: "Copy Link"
                width: widestBtn.width
                onClicked: { contextUrl.selectAll(); contextUrl.copy(); contextMenu.visible = false }
            }
            Button {
                text: "Save Image"
                width: widestBtn.width
                visible: imageLongPressAvailability
                onClicked: { pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": contextUrl.text}); contextMenu.visible = false }
            }
            Button {
                text: "Save Link"
                width: widestBtn.width
                onClicked: { pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": fixUrl(contextUrl.text)}); contextMenu.visible = false }
            }
        }
    }
    MouseArea {
        id: suggestionsOverlay;
        anchors.fill: parent;
        enabled: suggestionView.visible
        onClicked: suggestionView.visible = false
    }
    Suggestions {
        id: suggestionView
        model: mainWindow.historyModel
//        anchors.top: parent.top
//        anchors.topMargin: Theme.paddingLarge
        anchors.bottom: toolbar.top
        anchors.bottomMargin: - 3
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 60
        height: //parent.height / 2
        {
            var max = parent.height / 2
            if (80 * mainWindow.historyModel.count <= max) return 80 * mainWindow.historyModel.count
            else return parent.height / 2
        }
        visible: false
        onSelected: { webview.url = url ; visible = false }
    }
    TextArea {
        id: hiddenTxtBox
        visible: false
    }
}


