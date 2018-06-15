/*
  Copyright (C) 2015 Leszek Lesner
  Contact: Leszek Lesner <leszek.lesner@web.de>
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
import "helper/db.js" as DB
import "helper/yt.js" as YT
import "helper/browserComponents"
import "helper/otherComponents"

Page {
    id: page
    allowedOrientations: mainWindow.orient

    // minimize toolbar when switching to landscape & trigger hide and show tabBar and bookmarkList
    onOrientationChanged: {
        if (orientation == Orientation.Landscape && toolbar.state == "expanded") toolbar.state = "minimized"
        else if (orientation == Orientation.Portrait && toolbar.state == "minimized") toolbar.state = "expanded"
        // Trigger hide and show to workaround visual glitches
        if (tabBar.visible && bookmarkList.visible) {
            delayShowBT.start();
        }
    }

    property alias url: webview.url
    property alias toolbar: toolbar
    property alias extraToolbar: extraToolbar
    property alias menuPopup: menuPopup
    property alias tabBar: tabBar
    property alias bookmarkList: bookmarkList
    property string agent: userAgent

    property ListModel bookmarks

    property SilicaListView tabListView
    property bool loadHP
    property string pageId
    backNavigation: false
    forwardNavigation: false
    showNavigationIndicator: false
    property QtObject _ngfEffect
    property alias suggestionView: suggestionView
    property bool imageLongPressAvailability;
    property bool mediaYt: false
    property bool mediaYtEmbeded : false
    property bool mediaLink;
    property bool inputSelected: false
    property string inputValue;
    property var inputElem;
    property string ytStreamUrl;
    property bool ytUrlLoading;
    property bool readerMode: false
    property bool nightMode: false
    property bool searchMode: false
    property int toolbarheight: Theme.itemSizeSmall //Screen.height / 13
    property int extratoolbarheight: Theme.itemSizeSmall + (Theme.itemSizeSmall / 3)//Screen.height / 10
    property alias webview: webview
    property alias mediaDownloadRec: mediaDownloadRec
    property alias vPlayerLoader: vPlayerLoader
    property string yt720p: mediaList.count > 0 && mediaYt && mediaList.get(0).yt720p ? mediaList.get(0).yt720p : ""
    property string yt480p: mediaList.count > 0 && mediaYt && mediaList.get(0).yt480p ? mediaList.get(0).yt480p : ""
    property string yt360p: mediaList.count > 0 && mediaYt && mediaList.get(0).yt360p ? mediaList.get(0).yt360p : ""
    property string yt240p: mediaList.count > 0 && mediaYt && mediaList.get(0).yt240p ? mediaList.get(0).yt240p : ""
    property string mediaTitle;
    property int counter;
    property alias mediaList: mediaList
    property bool inputFocus: false
    property variant crashUrl: []
    property alias ytQualChooser: ytQualChooser
    property bool emptyPage: true

// DEBUG
//    onYt720pChanged: {
//        console.debug("Changed yt720p to:" + yt720p)
//    }
//    onYt480pChanged: {
//        console.debug("Changed yt480p to:" + yt480p)
//    }
//    onYt360pChanged: {
//        console.debug("Changed yt360p to:" + yt360p)
//    }
//    onYt240pChanged: {
//        console.debug("Changed yt240p to:" + yt240p)
//    }

    Component.onCompleted: {
        _ngfEffect = Qt.createQmlObject("import org.nemomobile.ngf 1.0; NonGraphicalFeedback { event: 'pulldown_lock' }",
                           extraToolbar.minimizeButton, 'NonGraphicalFeedback');
    }

    onMediaLinkChanged: {
        //console.debug("[firstPage.qml] MediaLink change (Change visibility of mediaDownloadRec): " + mediaLink)
        if (mediaLink == true) mediaDownloadRec.visible = true
        else mediaDownloadRec.visible = false
    }

    function loadUrl(requestUrl) {
        var valid = requestUrl
        if (valid.charAt(0) === '?') {
          url = mainWindow.searchEngine.replace("%s",encodeURIComponent(valid.slice(1)))
        } else if (valid.indexOf(":")<0) {
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
                return url = mainWindow.searchEngine.replace("%s",encodeURIComponent(valid))
            } else {
                return "http://"+valid;
            }
        }
        else return valid;
    }

    function showContextMenu(hrefUrl) {
        contextMenu.visible = true;
        contextMenu.contextLbl.text = hrefUrl;
        //contextMenu.height = contextMenu.contextLbl.height + contextMenu.contextButtons.height + Theme.paddingMedium
        if (arguments.length == 2) {
            contextMenu.imageLbl.text = arguments[1];
        }
    }

    function toggleReaderMode() {
        if (readerMode) {
            toolbar.bookmarkButton.visible = false
            webview.reload();
        } else {
            toolbar.bookmarkButton.visible = true
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

    function enableNightMode() {
        fPage.webview.experimental.userStyleSheets.push(Qt.resolvedUrl("helper/nightmode.css"));
        nightMode = true;
    }

    function disableNightMode() {
        fPage.webview.experimental.userStyleSheets.pop();
        nightMode = false;
    }

    function workaroundRefresh() {
        //console.log("Application Active change. Try workaround rendering bug by changing height of webview")
        var tempHeight = webview.height
        var curOrient = page.orientation
        webview.height += 1
        webview.height = tempHeight
        mainWindow.update();
        if (curOrient === Orientation.PortraitMask)  page.orientation = Orientation.Landscape
        else  page.orientation = Orientation.Portrait
        page.orientation = curOrient
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

    ListModel {
        id: mediaList

        function contains(url) {
            for (var i=0; i<count; i++) {
                if (get(i).url == url)  { // type transformation is intended here
                    return true;
                }
            }
            return false;
        }

        // Bugfix for Qt 5.6 (Somehow the definitions at the top aren't updated on changed in the ListModel anymore)
        // Ideally this should not interfere with prior releases
        onDataChanged:  {
            // Assume sets only come from youtube
            yt720p = mediaList.count > 0 && mediaYt && mediaList.get(0).yt720p ? mediaList.get(0).yt720p : ""
            yt480p = mediaList.count > 0 && mediaYt && mediaList.get(0).yt480p ? mediaList.get(0).yt480p : ""
            yt360p = mediaList.count > 0 && mediaYt && mediaList.get(0).yt360p ? mediaList.get(0).yt360p : ""
            yt240p = mediaList.count > 0 && mediaYt && mediaList.get(0).yt240p ? mediaList.get(0).yt240p : ""
            mediaDownloadRec.mediaDownloadRecTitle.text = mediaList.count > 0 && mediaYt && mediaList.get(0).mediaTitle ? mediaList.get(0).mediaTitle : ""
            //console.debug("MediaTitle = " + mediaList.get(0).mediaTitle)
        }
        onRowsInserted: {
            mediaDownloadRec.mediaDownloadRecTitle.text = mediaList.get(0).mediaTitle
            //console.debug("MediaTitle = " + mediaList.get(0).mediaTitle)
        }


        // Example data
//        ListElement {
//            mediaTitle: "foobar"
//            url: "http://youtube.com/watch?v=2314frwdrf3"
//            yt720p: "http://r8---sn-4g57knde.googlevideo.com/videoplayback?ip=85.212.83.237&fexp=905657%2C907263%2C924623%2C927622%2C936110%2C9406406%2C9406558%2C941440%2C943917%2C947225%2C947240%2C948124%2C952302%2C952605%2C952612%2C952901%2C955301%2C957201%2C958603%2C959701&initcwndbps=2706250&sver=3&nh=IgpwcjAyLmZyYTA1KgkxMjcuMC4wLjE&source=youtube&sparams=dur%2Cid%2Cinitcwndbps%2Cip%2Cipbits%2Citag%2Cmm%2Cms%2Cmv%2Cnh%2Cpl%2Csource%2Cupn%2Cexpire&mv=m&ms=au&mt=1424780611&mm=31&ipbits=0&dur=293.747&id=o-AHf8c-JE9WXGPYnTeqHw-"
//            yt480p: ""
//            yt360p: ""
//            yt240p: ""
//        }
    }

    SilicaWebView {
        id: webview
        url: ""
        objectName: "SWebView"

        focus: true

        property variant itemSelectorIndex: -1
        property var mediaDownloadRecVisible

        smooth: false
        maximumFlickVelocity: Theme.maximumFlickVelocity / 2

        anchors.fill: parent
        anchors.bottomMargin: toolbarheight / 3
        quickScroll: true

        onAtYEndChanged: {
            if (atYEnd) {
                if (!emptyPage && !loading) {
                    toolbar.state = "minimized"
                }
                if (mediaDownloadRec.visible && !atYBeginning) {
                    mediaDownloadRecVisible = true
                    mediaDownloadRec.visible = false
                }
                if (extraToolbar.visible)
                    extraToolbar.hide();
            }
            else {
               if (mediaDownloadRecVisible) {
                   mediaDownloadRec.visible = true
                   mediaDownloadRecVisible = false
               }
            }
        }

        // We don't want pageStackNavigation to interfere
        overridePageStackNavigation: true
        header: PageHeader {height: 0}

        function checkYoutubeURL(yurl) {
            if (YT.checkYoutube(yurl.toString()) && mediaYtEmbeded == false) {
                mediaYt = true;
                ytUrlLoading = true
                mediaLink = true;
                mediaDownloadRec.mediaUrl = yurl.toString()
            }
        }

        function checkYoutubeEmbeded(yurl) {
            if (YT.checkYoutube(yurl.toString())) {
                mediaYtEmbeded = true;
                mediaYt = true;
                ytUrlLoading = true
                mediaLink = true;
                mediaDownloadRec.mediaUrl = yurl.toString()
            }
        }

        onUrlChanged: {
            // There seems to be a bug where back and forward navigation is not shown even if webview.canGoBack or ~Forward
            toolbar.backIcon.visible = true
            toolbar.forIcon.visible = webview.canGoForward

            toolbar.webTitle.visible = false
            toolbar.urlText.text = toolbar.urlText.simplifyUrl(url)
            toolbar.urlText.fullUrl = url

            // reset everything on url change
            mediaDownloadRec.mediaUrl = "";
            mediaYtEmbeded = false;
            mediaYt = false;
            mediaLink = false;
            page.mediaTitle = "";
            // For mediaList
            counter = -1;
            itemSelectorIndex = -1;
            mediaList.clear();

            inputFocus = false;
            inputSelected = false;
            // Remove selection if still visible
            if (selection.visible) selection.visible = false

            if (url.toString().indexOf("about:") != -1) {
                emptyPage = true
            }
            else {
                emptyPage = false

                checkYoutubeURL(url);

                // Add to url history
                DB.addHistory(url.toString());
            }
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
        // experimental.autoCorrect: true  // Nice if it would work like expected though having cursor constantly on the left instead of right. So not using for now

        Component.onCompleted: {
            console.log ("Check now for experimental features only available in certain QtWebkit versions...")
            // Check for Features only supported in certain QtWebkit versions here and enable them if available
            if (typeof(experimental.preferences.javascriptCanOpenWindows) !== "undefined") {
                experimental.preferences.javascriptCanOpenWindows = true
                console.log("Hurray you are using a QtWebkit version that supports experimental.preferences.javascriptCanOpenWindows \\o/ Enabling it.")
            }
            if (typeof(experimental.preferences.mediaSourceEnabled) !== "undefined") {
                experimental.preferences.mediaSourceEnabled  = true
                console.log("Hurray you are using a QtWebkit version that supports experimental.preferences.mediaSourceEnabled \\o/ Enabling it.")
            }
            if (typeof(experimental.preferences.mediaPlaybackRequiresUserGestureEnabled) !== "undefined") {
                experimental.preferences.mediaPlaybackRequiresUserGestureEnabled = true
                console.log("Hurray you are using a QtWebkit version that supports experimental.preferences.mediaPlaybackRequiresUserGestureEnabled \\o/ Enabling it.")
            }
        }

        // Some speed improvement things that might work or not
//        layer.enabled: true
//        layer.format: ShaderEffectSource.RGBA
//        layer.mipmap: true
//        layer.smooth: true
//        layer.sourceRect: webview.width + "x" + webview.height
//        layer.textureSize: webview.width + "x" + webview.height

        property variant devicePixelRatio: {//1.5
            if (Screen.width <= 540) return 1.5;
            else if (Screen.width > 540 && Screen.width <= 768) return 2.0;
            else if (Screen.width > 768) return 3.0;
        }
        experimental.customLayoutWidth: page.width / devicePixelRatio
        experimental.deviceWidth: page.width / devicePixelRatio
        experimental.overview: true

        // Helps rendering websites that are only optimized for desktop
        experimental.preferredMinimumContentsWidth: 980

        property int curZ

        experimental.onEnterFullScreenRequested: {
            console.debug("Full Screen requested")
            webview.anchors.fill = page
            curZ = vPlayerLoader.z - 1
            webview.z = 99
        }

        experimental.onExitFullScreenRequested: {
            console.debug("Exit of Full Screen requested")
            webview.anchors.fill = undefined
            webview.z = curZ
        }

        experimental.filePicker: Item {
            Component.onCompleted: {
                var openDialog = pageStack.push(Qt.resolvedUrl("OpenDialog.qml"),
                                            {"dataContainer":  webview, "selectMode": true})
                openDialog.fileOpen.connect(function(file) {
                    model.accept(file);
                })
            }
       }
        experimental.itemSelector: PopOver {}
        experimental.preferences.fullScreenEnabled: true
        experimental.preferences.developerExtrasEnabled: true
        experimental.userStyleSheets: Qt.resolvedUrl("helper/adblock.css")
        experimental.userScripts: [
            Qt.resolvedUrl("helper/devicePixelRatioHack.js"),
            // Polyfills, Thx Dax89 for notifying me about those
            //Qt.resolvedUrl("helper/es6-collections.min.js"), // ES6 Harmony Collections: https://github.com/WebReflection/es6-collections
            //Qt.resolvedUrl("helper/canvg.min.js"),           // SVG Support: https://github.com/gabelerner/canvg
            // Media Detection
            Qt.resolvedUrl("helper/mediaDetect.js"),
            // This userScript makes longpress detection and other things working
            Qt.resolvedUrl("helper/userscript.js")
        ]
        experimental.preferences.navigatorQtObjectEnabled: true

        experimental.certificateVerificationDialog: Item {
            Component.onCompleted: {
                var dialog = pageStack.push(Qt.resolvedUrl("ConfirmDialog.qml"),
                                            {"title": qsTr("Unknown certificate"), "label":  qsTr("Accept certificate from ") + url + " ?", allowedOrientations: mainWindow.firstPage.allowedOrientations})
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
                                            {"hostname":  model.hostname, "realm": model.realm, allowedOrientations: mainWindow.firstPage.allowedOrientations})
                dialog.accepted.connect(function() {
                    model.accept(dialog.username, dialog.password)
                })
                dialog.rejected.connect(function() {
                    model.reject()
                })
            }
       }

        experimental.onProcessDidCrash: {
            // Crash of Webkit
            crashUrl[crashUrl.length] = url
            console.debug("[CrashUrl.length]: " + crashUrl.length)
            if (crashUrl.length == 3) {
                if (crashUrl[0] == crashUrl[1] == crashUrl[2]) {
                    mainWindow.infoBanner.parent = page
                    mainWindow.infoBanner.anchors.top = page.top
                    mainWindow.infoBanner.showText(qsTr("Webkit engine crashed too often!"))
                    crashUrl = []
                }
            }
            else {
                mainWindow.infoBanner.parent = page
                mainWindow.infoBanner.anchors.top = page.top
                mainWindow.infoBanner.showText(qsTr("Webkit engine crashed! Restarting..."))
                webview.reload();
            }
        }

        experimental.onDownloadRequested: {
            //console.debug("Download requested: " + downloadItem.url);
            var mime = _fm.getMime(downloadItem.url.toString());
            //console.debug("[firstPage] Download requested detected mimetype: " + mime);
            var mimeinfo = mime.toString().split("/");

            if(mimeinfo[0] === "video")
            {
                if (mainWindow.vPlayerExternal) {
                    mainWindow.infoBanner.parent = page
                    mainWindow.infoBanner.anchors.top = page.top
                    mainWindow.infoBanner.showText(qsTr("Opening..."))
                    mainWindow.openWithvPlayer(downloadItem.url,"");
                }
                else vPlayerLoader.setSource("VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: downloadItem.url })
                return;
            }
            // Call downloadmanager here with the url

            pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": downloadItem.url, "dataContainer": webview, "downloadName": downloadItem.suggestedFilename});
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
//            case 'error': {
//                console.debug("[FirstPage.qml] Javascript error: " + data.msg + " in line: " + data.line + " on url:" + data.url + " with StackTrace: " + data.strace)
//            }
            case 'longpress': {
                // DEBUG //
//                if (data.nodeName) {
//                    console.debug("Long pressed on node: " + data.nodeName)
//                }
                if (data.html) {
                    //console.debug("Nodes Outer HTML: " + data.html)
                    hiddenHtmlBox.text = ""
                    selection.htmldata = data.html
                    hiddenHtmlBox.text = selection.htmldata.toString()
                }
                // DEBUG END //
                if (data.img) {
//                    console.debug("[FirstPage.qml] Contextmenu Image detected")
                    imageLongPressAvailability = true;
                    if ((!data.href) || (data.href == "CANT FIND LINK")) showContextMenu("",data.img);
                    else console.debug("Image found but data.href was set to: " + data.href + " so don't show contextMenu");
                }
                if (data.video) {
//                    console.debug("HTML5 Video Tag found with src:" + data.video)
                    mediaLink = true;
                    mediaDownloadRec.mediaUrl = data.video
                    mediaDownloadRec.visible = true
                }
                if (data.href && data.href != "CANT FIND LINK") {
                    if (!data.img)  {
//                        console.debug("[FirstPage.qml] Contextmenu Link detected")
                        imageLongPressAvailability = false;
                        showContextMenu(data.href);
                    } else if (data.img) {
//                        console.debug("[FirstPage.qml] Contextmenu Link + Image detected")
                        showContextMenu(data.href,data.img);
                    }
                }
                if ('text' in data) {
                    selection.mimedata = data.text;
                    selection.show(data.left, data.top, data.width, data.height)
                    if (data.input) {
                        console.debug("Text Input field long pressed")
                        inputSelected = true
                        inputValue = data.input
                        inputElem = data.id
                    }
                    else {
                        inputSelected = false
                    }
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
                if (data.input && inputSelected && data.input !=  " ") {
                    //console.debug("data.input is set so I guess its time to start the selectioneditpage. Data.Input = " + data.input )
                    inputValue = data.input
                    pageStack.push(Qt.resolvedUrl("SelectionEditPage.qml"), { editText: inputValue.toString(), editInput: true, dataContainer: page })
                }
                //console.debug("[FirstPage.qml] INPUT Box data: " + data.state)
                if (data.state == "show") inputFocus = true;
                else if (data.state == "hide") { inputFocus = false; inputSelected = false } // somehow sometimes an undefined is received so don't react on it
                if (toolbar.state == "expanded" && data.state == "show" && ! toolbar.urlText.focus == true) toolbar.state = "minimized"
            }
            case 'search': {
                if (data.errorMsg != undefined && data.errorMsg != "") {
                    errorText = data.errorMsg;
                    popup.visible = true;
                }
            }
            case 'iframe': {
                if (data.isrc != undefined && data.isrc != "") {
                    checkYoutubeEmbeded(data.isrc);
                }
            }
            case 'video': {
                if (data.video) {
                    //console.debug("HTML5 Video Tag found with src:" + data.video)
                    mediaLink = true;
                    mediaDownloadRec.mediaUrl = data.video
                    mediaDownloadRec.visible = true
                }
                if (data.play && mediaDownloadRec.mediaUrl.length != 0 && mediaList.count == 1) {
                    mediaPlayBtn.clicked("");
                }
            }
            }
        }

        onLoadingChanged:
        {
            if (loadRequest.status == WebView.LoadStartedStatus)
            {
                //console.debug("[firstPage.qml] Load Started")
                urlLoading = true;
                contextMenu.visible = false;
                readerMode = false;
                searchMode = false;
                toolbar.webTitle.visible = false;
                toolbar.bookmarkButton.visible = false;
            }
            else if (loadRequest.status == WebView.LoadFailedStatus)
            {
                urlLoading = false;
                errorText = "Load failed\n"+loadRequest.errorString
                // Don't show error on rtsp, rtmp or mms links as they are opened externally
                if (! ((/^rtsp:/).test(url.toString()) || (/^rtmp:/).test(url.toString()) || (/^mms:/).test(url.toString()) || (/^magnet:/).test(url.toString()) )) {
                    console.debug("Load failed rtsp,rtmp or mms not detected and no valid http or https");
                    console.debug("[FirstPage.qml] Error text:" + errorText + " test(errorText): " + (/Path is a directory/).test(errorText));
                    if (! ((/handled by the media engine/).test(errorText) || (/Path is a directory/).test(errorText))) {
                        console.debug("Load failed audio or video file not detected and no valid http or https");
                        popup.visible = true
                    }
                    else if ((/handled by the media engine/).test(errorText)) {
                        mediaLink = true;
                        mediaDownloadRec.mediaUrl = url
                    }
                    else if ((/Path is a directory/).test(errorText)) {
                        pageStack.push(Qt.resolvedUrl("OpenDialog.qml"), {dataContainer: webview, path: url});
                    }
                }
            }
            else
            {
                urlLoading = false;
                if (url == "about:bookmarks" && loadHP === true) { bookmarkList.show(); tabBar.show() }
                else if (url == "about:") pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
                else if (url == "about:config") pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));
                else if (url == "about:file") pageStack.push(Qt.resolvedUrl("OpenDialog.qml"), { dataContainer: webview });
                else if (url == "about:backup") pageStack.push(Qt.resolvedUrl("BackupPage.qml"));
                else if (url == "about:download") pageStack.push(Qt.resolvedUrl("DownloadManager.qml"));
                else if (url == "about:video") pageStack.push(Qt.resolvedUrl("VideoPlayer.qml"), { dataContainer: webview });
                mainWindow.tabModel.setProperty(mainWindow.tabModel.getIndexFromId(pageId), "title", webview.title);
                //console.debug(tabModel.get(0).title);
                // Update url for tabModel
                //console.debug("[FirstPage.qml] pageId: " + pageId);
                if (pageId != "" || pageId != undefined) mainWindow.tabModel.updateUrl(pageId,url)
                if (title.length != 0 && title != "" && toolbar.state == "expanded") {
                    toolbar.webTitle.visible = true;
                }
            }
        }
        onNavigationRequested: {
            // detect URL scheme prefix, most likely an external link
            var schemaRE = /^\w+:/;
            if ((/^rtsp:/).test(request.url) || (/^rtmp:/).test(request.url) || (/^mms:/).test(request.url)) {
                request.action = WebView.IgnoreRequest;
                if (mediaYt == true) {  // Hack to detect if rstp link on youtube was requested
                    mediaPlayBtn.clicked(""); // Don't load the crappy rtsp stream but the detected working H264 Stream
                }
                else if (mainWindow.vPlayerExternal) mainWindow.openWithvPlayer(request.url);
                else vPlayerLoader.setSource("VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: request.url})
            }
            else if ((/^magnet:/).test(request.url)) {
                mainWindow.infoBanner.parent = page
                mainWindow.infoBanner.anchors.top = page.top
                mainWindow.infoBanner.showText(qsTr("Opening..."));
                mainWindow.openExternally(request.url)
            }
            else if ((/tagesschau.de/).test(request.url)) {
                experimental.customLayoutWidth = page.width
            }
            else if (schemaRE.test(request.url)) {
                request.action = WebView.AcceptRequest;
                experimental.customLayoutWidth = page.width / devicePixelRatio
            } /*else {
                if (! ((/^rtsp:/).test(request.url.toString()) || (/^rtmp:/).test(request.url.toString()) || (/^mms:/).test(request.url.toString()) || (/^file:/).test(request.url.toString()))) {
                    request.action = WebView.IgnoreRequest;
                    //popup.visible = true
                    // delegate request.url here
                }
            }*/
        }

        Selection {
            id: selection

            anchors.fill: parent
            visible: false

            property var mimedata: null
            property var htmldata: null

            function createData() {
                if (mimedata === null) {
                    hiddenTxtBox.text = ""
                    hiddenHtmlBox.text = ""
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
                if (!inputSelected) pageStack.push(Qt.resolvedUrl("SelectionEditPage.qml"), { editText: hiddenTxtBox.text, htmlText: hiddenHtmlBox.text })
                else {
                    var message = new Object
                    message.type = 'getInput'
                    message.elem = inputElem
                    webview.experimental.postMessage(JSON.stringify(message))
                }
                actionTriggered();
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
            }

            function copy() {
                hiddenTxtBox.text = mimedata.toString();
                //console.debug("Marked text: " + mimedata);
                _myClass.copy2clipboard(hiddenTxtBox.text)
            }
        }

        MouseArea {
            id: contextOverlay;
            anchors.fill: parent;
            enabled: contextMenu.visible || shareContextMenu.visible || contextMenu.height != 0 || shareContextMenu.height != 0 || (ytQualChooser.status == Loader.Ready && ytQualChooser.item.height != 0)
            onClicked: {
                contextMenu.height = 0;
                shareContextMenu.height = 0;
                if (ytQualChooser.status == Loader.Ready) ytQualChooser.item.height = 0;
            }
        }
        VerticalScrollDecorator {
            color: Theme.highlightColor // Otherwise we might end up with white decorator on white background
            width: Theme.paddingSmall // We want to see it properly
            flickable: webview
        }
        HorizontalScrollDecorator {  // Yeah necessary for larger images and other large sites or zoomed in sites
            parent: page
            color: Theme.highlightColor // Otherwise we might end up with white decorator on white background
            height: Theme.paddingSmall // We want to see it properly
            flickable: webview
            y: toolbar.y - height
        }
        Keys.onPressed: {
            if (toolbar.urlText.focus == false && inputFocus == false) {
                if (event.key == Qt.Key_T) webview.scrollToTop()
                else if (event.key == Qt.Key_B) webview.scrollToBottom()
                else if (event.key == Qt.Key_K) toolbar.gotoButton.clicked(undefined)
                else if (event.key == Qt.Key_S) extraToolbar.searchModeButton.clicked(undefined)
                else if (event.key == Qt.Key_R) extraToolbar.readerModeButton.clicked(undefined)
                else if (event.key == Qt.Key_L) webview.reload()
                else if (event.key == Qt.Key_U) { toolbar.state = "expanded" ; toolbar.urlText.selectAll(); toolbar.urlText.forceActiveFocus() }
                else if (event.key == Qt.Key_W && event.modifiers == Qt.ShiftModifier) mainWindow.openNewWindow("about:bookmarks")
                else if (event.key == Qt.Key_W) mainWindow.loadInNewTab("about:bookmarks");
                else if (event.key == Qt.Key_P) webview.goBack()
                else if (event.key == Qt.Key_N) webview.goForward()
                else if (searchBar.visible == true && (event.key == Qt.Key_Enter || event.key == Qt.Key_Return)) searchIcon.clicked(undefined)
            }
        }


    } // WebView
    FancyScroller {
        flickable: webview

        onUpScrolling: if (toolbar.state === "minimized") toolbar.state = "expanded"
        onDownScrolling: if (toolbar.state === "expanded") toolbar.state = "minimized"
        activateFastScroll: page.orientation == Orientation.Landscape || page.orientation == Orientation.LandscapeInverted
    }

    BookmarkList {
        id: bookmarkList
        y: -height
        x: 0
        z: mediaDownloadRec.z + 1
        visible: false
        opacity: 0
        color: "black"
        anchors.left: parent.left
        anchors.bottom: {
            if (parent.orientation == Orientation.Landscape || parent.orientation == Orientation.LandscapeInverted) toolbar.top
            else tabBar.top
        }

        width: {
            if (parent.orientation == Orientation.Landscape || parent.orientation == Orientation.LandscapeInverted) parent.width / 2
            else parent.width
        }
        height: {
            if (parent.orientation == Orientation.Landscape || parent.orientation == Orientation.LandscapeInverted) parent.height - toolbar.height
            else parent.height - (tabBar.height + toolbar.height)  //- entryURL.height - 2*65 //- bottomBar.height
        }
        bookmarks: bookmarks
        onBookmarkClicked: {
            siteURL = url;
            parent.url = siteURL;
            parent.agent = agent;
            hide();
            if (tabBar.visible) tabBar.hide();
        }
        onOpenClicked: {
            delayShowBT.start();
        }
    }

    Timer {
        id: delayShowBT
        interval: 400; running: false; repeat: false
        onTriggered: { bookmarkList.quickReShow(); tabBar.quickReShow(); }
    }

    Toolbar {
        id: toolbar
    }

    Rectangle {
        id: loadingRec
        anchors.bottom: toolbar.top
        height: toolbarheight / 13.37  // :P
        color: Theme.highlightColor
        property int minimumValue: 0
        property int maximumValue: 100
        property int value: webview.loadProgress
        width: (value / (maximumValue - minimumValue)) * parent.width
        visible: value == 100 ? false : true
    }

    ShareContextMenu {
        id: shareContextMenu
        anchors.bottom: toolbar.top
        anchors.bottomMargin: -toolbar.toolbarSep.height
        width: page.width;
    }

    // Extra Toolbar
    ExtraToolbar {
        id: extraToolbar
    }

    MenuPopup {
        id: menuPopup
        anchors.fill: parent
        menuTop: extraToolbar.y - 4 * Theme.itemSizeSmall
        dataContainer: page
        z: mediaDownloadRec.z + 1
    }

    // TabBar
    TabBar {
        id: tabBar
        z: bookmarkList.z + 1
        height: {
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
        width: {
            if (parent.orientation == Orientation.Landscape || parent.orientation == Orientation.LandscapeInverted) parent.width / 2
            else parent.width
        }

        anchors.bottom: toolbar.top
        anchors.left: {
            if (parent.orientation == Orientation.Portrait || parent.orientation == Orientation.PortraitInverted) parent.left
            else bookmarkList.right
        }


        dataContainer: page
        _tabListBg.visible: false
        _tabListBg.opacity: 0
        _tabListBg.height: 0

        onTabClicked: {
            if (_tabListView.currentIndex != idx) {
                mainWindow.switchToTab(pageId);
                _tabListView.currentIndex = idx;
            }
            hide();
            if (bookmarkList.visible) bookmarkList.hide();
        }
        onNewWindowClicked: {
            hide();
            if (bookmarkList.visible) bookmarkList.hide();
            mainWindow.openNewWindow("about:blank");
        }
        onNewTabClicked: {
            hide();
            if (bookmarkList.visible) bookmarkList.hide();
            mainWindow.openNewTab("page-"+mainWindow.salt(), "about:blank", false);
        }
        onMenuClosed: {
            hide();
            if (bookmarkList.visible) bookmarkList.hide();
        }
    }

    TabList {
        id: tabListOverlay
        visible: extraToolbar.visible && extraToolbar.quickmenu && mainWindow.tabModel.count > 1
        anchors.top: parent.top
        height: parent.height + Theme.paddingLarge - extratoolbarheight - toolbarheight
        width: parent.width
        property variant curTab
        property variant curIndex
        property variant tabCount

        onHideTriggered: {
            console.debug("[FirstPage.qml] tabListOverlay hide triggered")
            extraToolbar.hide()
        }
    }

    // On Media Loaded show download button
    MediaDownloadRec {
        id: mediaDownloadRec
        dataContainer: page
        z:90
    }

    Loader {
        id: vPlayerLoader
        width: page.width
        anchors.top: page.top
        anchors.left: page.left
        anchors.right: page.right
        height: if (page.orientation == Orientation.Portrait || page.orientation == Orientation.PortraitInverted) page.height / 3.1337
        anchors.bottom: {
            if (page.orientation == Orientation.Portrait || page.orientation == Orientation.PortraitInverted) undefined
            else mediaDownloadRec.visible ? mediaDownloadRec.top : toolbar.top
        }
        //source: "VideoPlayer.qml"
        z:80
        onLoaded: {
            if (page.orientation == Orientation.Portrait || page.orientation == Orientation.PortraitInverted) webview.visible = true
            else webview.visible = false
        }
    }

    Connections {
        target: vPlayerLoader.item
        onSwitchFullscreen: {
            if (vPlayerLoader.item.fullscreen === true) {
                vPlayerLoader.anchors.bottom = undefined
                vPlayerLoader.anchors.fill = page
                vPlayerLoader.z = 99 //Above everything else
                webview.visible = false
            }
            else {
                if (toolbar.state == "expanded") toolbar.state = "minimized"
                vPlayerLoader.anchors.fill = undefined
                vPlayerLoader.anchors.top = page.top
                vPlayerLoader.anchors.left = page.left
                vPlayerLoader.anchors.right = page.right
                if (page.orientation == Orientation.Landscape || page.orientation == Orientation.LandscapeInverted)
                    vPlayerLoader.anchors.bottom = mediaDownloadRec.visible ? mediaDownloadRec.top : toolbar.top
                else {
                    vPlayerLoader.anchors.bottom = undefined
                    vPlayerLoader.height = page.height / 3.1337
                    if (!webview.visible) webview.visible = true
                }
                vPlayerLoader.z = 80
            }
        }
        onClosePlayer: {
            vPlayerLoader.anchors.fill = undefined
            vPlayerLoader.anchors.top = page.top
            vPlayerLoader.anchors.left = page.left
            vPlayerLoader.anchors.right = page.right
            vPlayerLoader.anchors.bottom = toolbar.top
            if (page.orientation == Orientation.Landscape || page.orientation == Orientation.LandscapeInverted)
                vPlayerLoader.anchors.bottom = mediaDownloadRec.visible ? mediaDownloadRec.top : toolbar.top
            else {
                vPlayerLoader.anchors.bottom = undefined
                vPlayerLoader.height = page.height / 3.1337
            }
            vPlayerLoader.z = 80
            vPlayerLoader.setSource(""); 
            if (!webview.visible) webview.visible = true
        }
        onSwipeDown: {
            if (page.orientation == Orientation.Portrait || page.orientation == Orientation.PortraitInverted) {
                vPlayerLoader.anchors.bottom = mediaDownloadRec.visible ? mediaDownloadRec.top : toolbar.top
                vPlayerLoader.anchors.top = undefined
                vPlayerLoader.height = page.height / 3.1337
            }
        }
        onSwipeUp: {
            if (page.orientation == Orientation.Portrait || page.orientation == Orientation.PortraitInverted) {
                vPlayerLoader.anchors.top = page.top
                vPlayerLoader.anchors.bottom = undefined
                vPlayerLoader.height = page.height / 3.1337
            }
        }
    }

    Loader {
        id: ytQualChooser
        anchors.bottom: mediaDownloadRec.top
        anchors.bottomMargin: -toolbar.toolbarSep.height
        width: parent.width;
        z: 90
    }

    Connections {
        target: ytQualChooser.item
        onPlayStream: {
            if (vPlayerLoader.status == Loader.Ready) {
                vPlayerLoader.setSource("");  // Changing the source only seems not to work for some obscure reason
            }
            vPlayerLoader.setSource("VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: url, streamTitle: mediaDownloadRec.mediaDownloadRecTitle.text})
            ytQualChooser.item.height = 0
            ytQualChooser.source = ""
        }
    }

    // On Media Loaded show download button
    Rectangle {
        id: searchBar
        z:searchMode && mediaDownloadRec.visible ? mediaDownloadRec.z + 1 : 85
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
        height: toolbarheight
        visible: searchMode

        function search() {
            searchText.focus = false;  // Close keyboard
            var message = new Object
            message.type = 'search'
            message.searchTerm = searchText.text
            webview.experimental.postMessage(JSON.stringify(message))
        }

        // Close button
        IconButton {
            id: closeSearchButton
            icon.source: "image://theme/icon-m-close"
            onClicked:  {
                searchMode = false;
            }
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingSmall
            anchors.verticalCenter: parent.verticalCenter
            height: toolbarheight / 1.5
            width: height
            icon.height: height
            icon.width: width
        }

        TextField {
            id: searchText
            inputMethodHints: Qt.ImhNoAutoUppercase
            //text: placeholderText
            placeholderText: qsTr("Enter searchterm")
            font.pixelSize: Theme.fontSizeMedium
            y: parent.height / 2 - height / 4
            anchors.left: {
                searchIcon.right
            }
            anchors.leftMargin: Theme.paddingVerySmall
            width: parent.width - closeSearchButton.width - searchIcon.width
            onFocusChanged: {
                if (focus) {
                    selectAll();
                }
            }

            Keys.onEnterPressed: {
                searchBar.search();
                webview.forceActiveFocus();
            }

            Keys.onReturnPressed: {
               searchBar.search();
               webview.forceActiveFocus();
            }

        }

        IconButton {
            id: searchIcon
            icon.source: "image://theme/icon-m-search"
            onClicked:  {
                searchBar.search();
            }
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall
            anchors.verticalCenter: parent.verticalCenter
            height: toolbarheight / 1.5
            width: height
            icon.height: height
            icon.width: width
        }


    }

    // Long press contextmenu for link
    LinkContextMenu {
        id: contextMenu
        visible: false
        anchors.bottom: toolbar.top
        anchors.bottomMargin: -toolbar.toolbarSep.height
        width: parent.width;
        z:90
        onVisibleChanged: {
            if (visible == false) height = 0
            else height = contextMenu.contextLbl.height + contextButtons.height + Theme.paddingMedium
        }

        property alias contextButtons: contextButtons

        Column {
            id: contextButtons
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.paddingMedium
            onHeightChanged: {
                parent.height = contextMenu.contextLbl.height + height + Theme.paddingMedium
            }

            // Not really necessary as you can just click on the link
            //            Button {
            //                text: "Open"
            //                width: widestBtn.width
            //                onClicked: { webview.url = fixUrl(contextLbl.text); contextMenu.visible = false }
            //            }
            Button {
                width: widestBtn.width
                text: qsTr("Open in New Window")
                onClicked: { mainWindow.openNewWindow(fixUrl(contextMenu.contextLbl.text)); contextMenu.visible = false; if (selection.visible) selection.visible = false }
                visible: contextMenu.contextLbl.text != ""
            }
            Button {
                text: qsTr("Open in New Tab")
                width: widestBtn.width
                onClicked: { mainWindow.openNewTab("page"+salt(), fixUrl(contextMenu.contextLbl.text), true); contextMenu.visible = false; if (selection.visible) selection.visible = false}
                visible: contextMenu.contextLbl.text != ""
            }
            Button {
                id: widestBtn
                text: qsTr("Open in Private New Window")
                onClicked: { mainWindow.openPrivateNewWindow(fixUrl(contextMenu.contextLbl.text)); contextMenu.visible = false; if (selection.visible) selection.visible = false }
                visible: contextMenu.contextLbl.text != ""
            }
            Button {
                text: qsTr("Open Image in New Tab")
                width: widestBtn.width
                visible: (imageLongPressAvailability && contextMenu.imageLbl.text != "")
                onClicked: { mainWindow.openNewTab("page"+salt(), fixUrl(contextMenu.imageLbl.text), true); contextMenu.visible = false; if (selection.visible) selection.visible = false}
            }
            Button {
                text: qsTr("Copy Link")
                width: widestBtn.width
                onClicked: { contextMenu.contextLbl.selectAll(); contextMenu.contextLbl.copy(); contextMenu.visible = false; if (selection.visible) selection.visible = false }
                visible: contextMenu.contextLbl.text != ""
            }
            Button {
                text: qsTr("Save Image")
                width: widestBtn.width
                visible: imageLongPressAvailability
                onClicked: { pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": contextMenu.imageLbl.text, "dataContainer": webview}); contextMenu.visible = false; if (selection.visible) selection.visible = false }
            }
            Button {
                text: qsTr("Save Link")
                width: widestBtn.width
                onClicked: { pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": fixUrl(contextMenu.contextLbl.text), "dataContainer": webview}); contextMenu.visible = false; if (selection.visible) selection.visible = false }
                visible: contextMenu.contextLbl.text != ""
            }
        }
    }
    MouseArea {
        id: suggestionsOverlay;
        anchors.fill: parent;
        enabled: suggestionView.visible
        onClicked: suggestionView.visible = false
        z: suggestionView.z - 1
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
            var max = parent.height / 1.25
            if (model == mainWindow.historyModel) {
                if (contentHeight <= max) return contentHeight
                else return max
            }
            else if (model == mediaList) {
                if (contentHeight <= max) return contentHeight
                else return max
            }
            else return max
        }
        visible: false
        onSelected: {
            toolbar.urlText.focus = false;
            suggestionView.visible = false ;
            webview.url = url;
            webview.focus = true;
            if (bookmarkList.visible || tabBar.visible) {
                bookmarkList.hide()
                tabBar.hide()
            }
        }
        onSelectedMedia: {
            suggestionView.visible = false;
            mediaDownloadRec.mediaDownloadRecTitle.text = mediaTitle;
            page.yt720p = yt720p;
            page.yt480p = yt480p;
            page.yt360p = yt360p;
            page.yt240p = yt240p;
            page.mediaYt = ytMedia;
            if (!ytMedia) mediaDownloadRec.mediaUrl = url;
            // Need to destroy player here as it has probably the wrong URL
            vPlayerLoader.setSource("");
            if (!webview.visible) webview.visible = true
            if (bookmarkList.visible || tabBar.visible) {
                bookmarkList.hide()
                tabBar.hide()
            }
        }
        z: {
            if (tabBar.visible) tabBar.z + 1
            else vPlayerLoader.z + 1
        }
    }
    TextArea {
        id: hiddenTxtBox
        visible: false
    }
    TextArea {
        id: hiddenHtmlBox
        visible: false
    }

    CoverActionList {
            enabled: page.status === PageStatus.Active && webview.contentItem && vPlayerLoader.status != Loader.Ready && mainWindow.coverActionGroup == 0
            iconBackground: true

            CoverAction {
                iconSource: "image://theme/icon-cover-new"
                onTriggered: {
                    mainWindow.activate()
                    mainWindow.loadInNewTab("about:bookmarks")
                }
            }

            CoverAction {
                iconSource: webview.loading ? "image://theme/icon-cover-cancel" : "image://theme/icon-cover-refresh"
                onTriggered: {
                    if (webview.loading) {
                        webview.stop()
                    } else {
                        webview.reload()
                    }
                }
            }
        }
    CoverActionList {
            enabled: page.status === PageStatus.Active && webview.contentItem && vPlayerLoader.status != Loader.Ready && mainWindow.coverActionGroup == 1 && mainWindow.tabModel.count > 1
            iconBackground: true

            CoverAction {
                iconSource: {
                    if (! mainWindow.currentTabIndex < 1) "image://theme/icon-cover-previous"
                    else ""
                }
                onTriggered: {
                    if (! mainWindow.currentTabIndex < 1) mainWindow.switchToTab(mainWindow.tabModel.get(mainWindow.currentTabIndex-1).pageid)
                }
            }

            CoverAction {
                iconSource: {
                    if (mainWindow.currentTabIndex < mainWindow.tabModel.count-1) "image://theme/icon-cover-next"
                    else ""
                }
                onTriggered: {
                    if (! mainWindow.currentTabIndex < mainWindow.tabModel.count) mainWindow.switchToTab(mainWindow.tabModel.get(mainWindow.currentTabIndex+1).pageid)
                }
            }
        }
}
