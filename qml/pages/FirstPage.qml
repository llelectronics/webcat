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

Page {
    id: page
    allowedOrientations: mainWindow.orient

    // minimize toolbar when switching to landscape
    onOrientationChanged: {
        if (orientation == Orientation.Landscape && toolbar.state == "expanded") toolbar.state = "minimized"
        else if (orientation == Orientation.Portrait && toolbar.state == "minimized") toolbar.state = "expanded"
    }

    property alias url: webview.url
    property alias toolbar: toolbar
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
    property string ytStreamUrl;
    property bool ytUrlLoading;
    property bool readerMode: false
    property bool nightMode: false
    property bool searchMode: false
    property int toolbarheight: Theme.itemSizeSmall //Screen.height / 13
    property int extratoolbarheight: Theme.itemSizeSmall + (Theme.itemSizeSmall / 4)//Screen.height / 10
    property alias webview: webview
    property alias mediaDownloadRec: mediaDownloadRec
    property string yt720p: mediaList.count > 0 && mediaYt && mediaList.get(0).yt720p ? mediaList.get(0).yt720p : ""
    property string yt480p: mediaList.count > 0 && mediaYt && mediaList.get(0).yt480p ? mediaList.get(0).yt480p : ""
    property string yt360p: mediaList.count > 0 && mediaYt && mediaList.get(0).yt360p ? mediaList.get(0).yt360p : ""
    property string yt240p: mediaList.count > 0 && mediaYt && mediaList.get(0).yt240p ? mediaList.get(0).yt240p : ""
    property string mediaTitle;
    property int counter;
    property alias mediaList: mediaList
    property bool inputFocus: false

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
                           minimizeButton, 'NonGraphicalFeedback');
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
            mediaDownloadRecTitle.text = mediaList.count > 0 && mediaYt && mediaList.get(0).mediaTitle ? mediaList.get(0).mediaTitle : ""
            //console.debug("MediaTitle = " + mediaList.get(0).mediaTitle)
        }
        onRowsInserted: {
            mediaDownloadRecTitle.text = mediaList.get(0).mediaTitle
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

        smooth: false
        maximumFlickVelocity: Theme.maximumFlickVelocity / 2

        width: {
            if (!page.orientationTransitionRunning) {
                if (page.orientation == Orientation.Portrait || page.orientation == Orientation.PortraitInverted)  {
                    mainWindow.width
                } else {
                    mainWindow.height
                }
            }
        }
        height: { //page.height - 20 // minimized toolbar size. We don't want to set the toolbar.height here otherwise it would make webview resizing which is painfully slow
            if (!page.orientationTransitionRunning) {
                if (page.orientation == Orientation.Portrait || page.orientation == Orientation.PortraitInverted)  {
                    //console.debug("Not in Landscape")
                    if (inputFocus && mediaDownloadRec.visible) mainWindow.height - (toolbarheight / 3) - mediaDownloadRec.height - Qt.inputMethod.keyboardRectangle.height
                    else if (mediaDownloadRec.visible) mainWindow.height - (toolbarheight / 3) - mediaDownloadRec.height
                    else if (inputFocus) mainWindow.height - (toolbarheight /3) - Qt.inputMethod.keyboardRectangle.height
                    else mainWindow.height - (toolbarheight /3)
                } else {
                    //console.debug("In Landscape")
                    if (inputFocus && mediaDownloadRec.visible) mainWindow.width - (toolbarheight / 3) - mediaDownloadRec.height - Qt.inputMethod.keyboardRectangle.width
                    else if (mediaDownloadRec.visible) mainWindow.width - (toolbarheight / 3) - mediaDownloadRec.height
                    else if (inputFocus) mainWindow.width - (toolbarheight /3) - Qt.inputMethod.keyboardRectangle.width
                    else mainWindow.width - (toolbarheight /3)
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
            backIcon.visible = true
            forIcon.visible = webview.canGoForward
//            if ((/^rtsp:/).test(url) || (/^rtmp:/).test(url) || (/^mms:/).test(url)) {
//                if (mediaYt == true) {
//                    mediaPlayBtn.clicked("");
//                }
//                else if (mainWindow.vPlayerExternal) mainWindow.openWithvPlayer(url);
//                else vPlayerLoader.setSource("VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: url})
//            }

            urlText.text = urlText.simplifyUrl(url)
            urlText.fullUrl = url

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

            checkYoutubeURL(url);

            // Add to url history
            DB.addHistory(url.toString());

            inputFocus = false;
            // Remove selection if still visible
            if (selection.visible) selection.visible = false
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

        // Some speed improvement things that might work or not
//        layer.enabled: true
//        layer.format: ShaderEffectSource.RGBA
//        layer.mipmap: true
//        layer.smooth: true
//        layer.sourceRect: webview.width + "x" + webview.height
//        layer.textureSize: webview.width + "x" + webview.height

        // Theoretically a nice function to replace the DevicePixelRatio hack but does not work as intended always
//        property variant devicePixelRatio: {//1.5
//            if (Screen.width <= 540) return 1.5;
//            else if (Screen.width > 540 && Screen.width <= 768) return 2.0;
//            else if (Screen.width > 768) return 3.0;
//        }
//        experimental.customLayoutWidth: page.width / devicePixelRatio

        // Helps rendering websites that are only optimized for desktop
        experimental.preferredMinimumContentsWidth: 980

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
        experimental.userStyleSheet: Qt.resolvedUrl("helper/adblock.css")

        experimental.userScripts: [
            Qt.resolvedUrl("helper/devicePixelRatioHack.js"),
            // Polyfills, Thx Dax89 for notifying me about those
            Qt.resolvedUrl("helper/es6-collections.min.js"), // ES6 Harmony Collections: https://github.com/WebReflection/es6-collections
            Qt.resolvedUrl("helper/canvg.min.js"),           // SVG Support: https://github.com/gabelerner/canvg
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

        experimental.onDownloadRequested: {
            //console.debug("Download requested: " + downloadItem.url);
            var mime = _fm.getMime(downloadItem.url.toString());
            //console.debug("[firstPage] Download requested detected mimetype: " + mime);
            var mimeinfo = mime.toString().split("/");

            if(mimeinfo[0] === "video")
            {
                if (mainWindow.vPlayerExternal) {
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
            //console.log('onMessageReceived: ' + message.data );
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
                //console.debug("[FirstPage.qml] INPUT Box data: " + data.state)
                if (data.state == "show") inputFocus = true;
                else if (data.state == "hide") inputFocus = false; // somehow sometimes an undefined is received so don't react on it
                if (toolbar.state == "expanded" && data.state == "show" && ! urlText.focus == true) toolbar.state = "minimized"
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
                nightMode = false;
            }
            else if (loadRequest.status == WebView.LoadFailedStatus)
            {
                urlLoading = false;
                errorText = "Load failed\n"+loadRequest.errorString
                // Don't show error on rtsp, rtmp or mms links as they are opened externally
                if (! ((/^rtsp:/).test(url.toString()) || (/^rtmp:/).test(url.toString()) || (/^mms:/).test(url.toString()) )) {
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
                if (url == "about:bookmarks" && loadHP === true) pageStack.push(Qt.resolvedUrl("SelectUrl.qml"), { dataContainer: page, siteURL: webview.url, bookmarks: page.bookmarks, siteTitle: webview.title})
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
            else if (schemaRE.test(request.url)) {
                request.action = WebView.AcceptRequest;
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
                pageStack.push(Qt.resolvedUrl("SelectionEditPage.qml"), { editText: hiddenTxtBox.text, htmlText: hiddenHtmlBox.text })
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
            enabled: contextMenu.visible || shareContextMenu.visible || contextMenu.height != 0 || shareContextMenu.height != 0 || (ytQualChooser.status == Loader.Ready && ytQualChooser.visible)
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
            anchors.bottom: toolbar.top
        }
        Keys.onPressed: {
            if (urlText.focus == false && inputFocus == false) {
                if (event.key == Qt.Key_T) webview.scrollToTop()
                else if (event.key == Qt.Key_B) webview.scrollToBottom()
                else if (event.key == Qt.Key_K) gotoButton.clicked(undefined)
                else if (event.key == Qt.Key_S) searchModeButton.clicked(undefined)
                else if (event.key == Qt.Key_R) readerModeButton.clicked(undefined)
                else if (event.key == Qt.Key_L) webview.reload()
                else if (event.key == Qt.Key_U) { toolbar.state = "expanded" ; urlText.selectAll(); urlText.forceActiveFocus() }
                else if (event.key == Qt.Key_W && event.modifiers == Qt.ShiftModifier) newWindowButton.clicked(undefined)
                else if (event.key == Qt.Key_W) newTabButton.clicked(undefined)
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
    }

    // ToolBar
    Rectangle {
        id: toolbar
        width: page.width
        state: "expanded"
        z: 91
        //color: Theme.highlightBackgroundColor // As alternative perhaps maybe someday
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#262626" }
            GradientStop { position: 0.85; color: "#1F1F1F"}
        }
        height: toolbarheight
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
                    height: toolbarheight
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
                    visible: true
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
                    height: Math.floor(toolbarheight / 3)
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

        Image {
            id: webIcon
            source: webview.icon != "" ? webview.icon : "image://theme/icon-lock-social";
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
            text: webview.title + " - " + webview.url
            anchors.top: toolbar.top
            anchors.topMargin: 3
            anchors.left: webIcon.right
            anchors.leftMargin: Theme.paddingSmall
            font.bold: true
            font.pixelSize: Theme.fontSizeTiny //parent.height - 4
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
            height: toolbarheight / 1.5
            width: height
            icon.height: toolbar.height
            icon.width: icon.height
            anchors.verticalCenter: toolbar.verticalCenter

            onClicked: {
                    extraToolbar.hide()
                    pageStack.push(Qt.resolvedUrl("SelectUrl.qml"), { dataContainer: page, siteURL: webview.url, bookmarks: page.bookmarks, siteTitle: webview.title})
            }
            property int mx
            property bool searchButton: false
            onPressAndHold: {
                if (extraToolbar.opacity == 0 || extraToolbar.visible == false) {
                    extraToolbar.quickmenu = true
                    extraToolbar.show()
                    extraToolbar.height = extratoolbarheight
                    minimizeButton.highlighted = true
                    mx = mouse.x
                }
            }
            onPositionChanged: {
                if (extraToolbar.opacity == 1 && extraToolbar.quickmenu && mouse.y > ((extratoolbarheight + toolbarheight) * -1)) {
                    //console.debug("X Position: " + mouse.x)
                    if (mouse.x > newTabButton.x && mouse.x < newWindowButton.x) { minimizeButton.highlighted = false; newTabButton.highlighted = true; newWindowButton.highlighted = false; reloadThisButton.highlighted = false; orientationLockButton.highlighted = false; readerModeButton.highlighted = false; searchModeButton.highlighted = false; shareButton.highlighted = false; }
                    else if (mouse.x < newTabButton.x) {minimizeButton.highlighted = true; newTabButton.highlighted = false; newWindowButton.highlighted = false; reloadThisButton.highlighted = false; orientationLockButton.highlighted = false; readerModeButton.highlighted = false; searchModeButton.highlighted = false; shareButton.highlighted = false; }
                    else if (mouse.x > newWindowButton.x && mouse.x < reloadThisButton.x) { minimizeButton.highlighted = false; newTabButton.highlighted = false; newWindowButton.highlighted = true; reloadThisButton.highlighted = false; orientationLockButton.highlighted = false; readerModeButton.highlighted = false; searchModeButton.highlighted = false; shareButton.highlighted = false; }
                    else if (mouse.x > reloadThisButton.x && mouse.x < orientationLockButton.x) { minimizeButton.highlighted = false; newTabButton.highlighted = false; newWindowButton.highlighted = false; reloadThisButton.highlighted = true; orientationLockButton.highlighted = false; readerModeButton.highlighted = false; searchModeButton.highlighted = false; shareButton.highlighted = false; }
                    else if (mouse.x > orientationLockButton.x && mouse.x < orientationLockButton.x + orientationLockButton.width + Theme.paddingMedium) { minimizeButton.highlighted = false; newTabButton.highlighted = false; newWindowButton.highlighted = false; reloadThisButton.highlighted = false; orientationLockButton.highlighted = true; readerModeButton.highlighted = false; searchModeButton.highlighted = false; shareButton.highlighted = false; }
                    else if (mouse.x > readerModeButton.x && mouse.x < readerModeButton.x + readerModeButton.width + Theme.paddingMedium) { minimizeButton.highlighted = false; newTabButton.highlighted = false; newWindowButton.highlighted = false; reloadThisButton.highlighted = false; orientationLockButton.highlighted = false; readerModeButton.highlighted = true; searchModeButton.highlighted = false; shareButton.highlighted = false; }
                    else if (mouse.x > searchModeButton.x && mouse.x < searchModeButton.x + searchModeButton.width + Theme.paddingMedium) { minimizeButton.highlighted = false; newTabButton.highlighted = false; newWindowButton.highlighted = false; reloadThisButton.highlighted = false; orientationLockButton.highlighted = false; readerModeButton.highlighted = false; searchModeButton.highlighted = true; shareButton.highlighted = false;}
                    else if (mouse.x > shareButton.x && mouse.x < shareButton.x + shareButton.width + Theme.paddingMedium) { minimizeButton.highlighted = false; newTabButton.highlighted = false; newWindowButton.highlighted = false; reloadThisButton.highlighted = false; orientationLockButton.highlighted = false; readerModeButton.highlighted = false; searchModeButton.highlighted = false; shareButton.highlighted = true; }
                    else if (mouse.x > shareButton.x + shareButton.width + Theme.paddingMedium) { minimizeButton.highlighted = false; newTabButton.highlighted = false; newWindowButton.highlighted = false; reloadThisButton.highlighted = false; orientationLockButton.highlighted = false; readerModeButton.highlighted = false; searchModeButton.highlighted = false; shareButton.highlighted = false; }
                }
                if (mouse.y < ((extratoolbarheight + toolbarheight) * -1)) {
                    minimizeButton.highlighted = false;
                    newTabButton.highlighted = false;
                    newWindowButton.highlighted = false;
                    reloadThisButton.highlighted = false;
                    orientationLockButton.highlighted = false;
                    readerModeButton.highlighted = false;
                    searchModeButton.highlighted = false;
                    shareButton.highlighted = false;
                    tabListOverlay.curTab = mainWindow.tabModel.getIndexFromId(mainWindow.currentTab);
                    tabListOverlay.tabCount = tabListOverlay.list.count;
                    for (var i=1; i <= tabListOverlay.tabCount ; i++) {
                           if (mouse.y < (toolbarheight + Theme.paddingSmall) * -(i+1) && mouse.y > (toolbarheight + Theme.paddingSmall) * -(i+2)) {
                               tabListOverlay.list.currentIndex = tabListOverlay.curIndex = tabListOverlay.list.count - i
                               break;
                           }
                    }

//                    if (mouse.y < toolbarheight * -2 && mouse.y > toolbarheight * -3) {
//                        tabListOverlay.list.currentIndex = tabListOverlay.list.count - 1
//                        tabListOverlay.curIndex = tabListOverlay.list.count - 1
//                    }
//                    if (mouse.y < toolbarheight * -3 && mouse.y > toolbarheight * -4) {
//                        tabListOverlay.list.currentIndex = tabListOverlay.list.count - 2
//                        tabListOverlay.curIndex = tabListOverlay.list.count - 2
//                    }
//                    if (mouse.y < toolbarheight * -4 && mouse.y > toolbarheight * -5) {
//                         tabListOverlay.list.currentIndex = tabListOverlay.list.count - 3
//                         tabListOverlay.curIndex = tabListOverlay.list.count - 3
//                    }
                }
            }

            onReleased: {
                if (extraToolbar.opacity == 1 && extraToolbar.quickmenu && minimizeButton.highlighted == true) minimizeButton.clicked(undefined)
                else if (extraToolbar.opacity == 1 && extraToolbar.quickmenu && newTabButton.highlighted == true) newTabButton.clicked(undefined)
                else if (extraToolbar.opacity == 1 && extraToolbar.quickmenu && newWindowButton.highlighted == true) newWindowButton.clicked(undefined)
                else if (extraToolbar.opacity == 1 && extraToolbar.quickmenu && reloadThisButton.highlighted == true) reloadThisButton.clicked(undefined)
                else if (extraToolbar.opacity == 1 && extraToolbar.quickmenu && orientationLockButton.highlighted == true) orientationLockButton.clicked(undefined)
                else if (extraToolbar.opacity == 1 && extraToolbar.quickmenu && readerModeButton.highlighted == true) readerModeButton.clicked(undefined)
                else if (extraToolbar.opacity == 1 && extraToolbar.quickmenu && searchModeButton.highlighted == true) searchModeButton.clicked(undefined)
                else if (extraToolbar.opacity == 1 && extraToolbar.quickmenu && shareButton.highlighted == true) shareButton.clicked(undefined)
                else if (extraToolbar.opacity == 1 && extraToolbar.quickmenu && mouse.y > ((extratoolbarheight + toolbarheight) * -1)) extraToolbar.hide()
                else if (extraToolbar.opacity == 1 && extraToolbar.quickmenu && mouse.y < ((extratoolbarheight + toolbarheight) * -1)) {
                    // tabListOverlay.list click curent index item
                    if (tabListOverlay.curTab == tabListOverlay.list.currentIndex) { tabListOverlay.hideTriggered(); }
                    else {
                        console.debug("[FirstPage.qml] tabListOverlay.curIndex = " + tabListOverlay.curIndex + " ; tabListOverlay.list.currentIndex = " + tabListOverlay.list.currentIndex);
                        tabListOverlay.hideTriggered();
                        mainWindow.switchToTab(mainWindow.tabModel.get(tabListOverlay.curIndex).pageid);
                    }
                } // last else if
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
            height: toolbarheight / 1.5
            width: height
            enabled: webview.canGoBack
            visible: webview.canGoBack
            anchors.left: gotoButton.right
            anchors.leftMargin: Theme.paddingMedium
            onClicked: {
                webview.goBack();
                forIcon.visible = true;
            }
            anchors.verticalCenter: toolbar.verticalCenter
            icon.height: toolbar.height
            icon.width: icon.height
        }

        IconButton {
            id: forIcon
            icon.source: "image://theme/icon-m-forward"
            height: toolbarheight / 1.5
            width: height
            enabled: webview.canGoForward
            visible: webview.canGoForward
            anchors.left: backIcon.visible ? backIcon.right : gotoButton.right
            anchors.leftMargin: (1.5 * Theme.paddingLarge)
            onClicked: {
                webview.goForward();
            }
            anchors.verticalCenter: toolbar.verticalCenter
            icon.height: toolbar.height
            icon.width: icon.height
        }

        // Url textbox here
        TextField{
            id: urlText
            visible: true
            text: simplifyUrl(url)
            inputMethodHints: Qt.ImhUrlCharactersOnly
            placeholderText: qsTr("Enter an url")
            font.pixelSize: Theme.fontSizeMedium
            y: parent.height / 2 - height / 4
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
                if (backIcon.visible === false && forIcon.visible === false) return parent.width - gotoButton.width - refreshButton.width - bookmarkButton.width
                else if (backIcon.visible === true && forIcon.visible === false) return parent.width - gotoButton.width - refreshButton.width - bookmarkButton.width - backIcon.width
                else if (backIcon.visible === false && forIcon.visible === true) return parent.width - gotoButton.width - refreshButton.width - bookmarkButton.width - forIcon.width
                else if (backIcon.visible === true && forIcon.visible === true) return parent.width - gotoButton.width - refreshButton.width - bookmarkButton.width - backIcon.width - backIcon.width
            }
            onFocusChanged: {
                if (focus) {
                    backIcon.visible = false
                    forIcon.visible = false
                    bookmarkButton.visible = false
                    gotoButton.searchButton = true
                    text = fullUrl
                    color = Theme.primaryColor
                    suggestionView.visible = false
                    selectAll();
                }
                else {
                    backIcon.visible = webview.canGoBack
                    forIcon.visible = webview.canGoForward
                    bookmarkButton.visible = true
                    gotoButton.searchButton = false
                    text = simplifyUrl(url)
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
                if (page.suggestionView.visible) page.suggestionView.visible = false;
                webview.url = fixUrl(urlText.text);
                urlText.focus = false;  // Close keyboard
                webview.focus = true;
            }

            Keys.onReturnPressed: {
                if (page.suggestionView.visible) page.suggestionView.visible = false;
                webview.url = fixUrl(urlText.text);
                urlText.focus = false;
                webview.focus = true;
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
                else webview.loading ? "image://theme/icon-m-reset" : "image://theme/icon-m-menu"
            }
            onClicked: {
                if (webview.loading) webview.stop()
                else if (icon.source == "image://theme/icon-m-refresh") webview.reload()
                else if (extraToolbar.opacity == 0 || extraToolbar.visible == false) {
                    extraToolbar.quickmenu = false
                    extraToolbar.show()
                }
                else if (extraToolbar.opacity == 1 || extraToolbar.visible == true) {
                    extraToolbar.hide()
                }
            }
            anchors.right: urlText.focus ? parent.right : bookmarkButton.left
            anchors.rightMargin: Theme.paddingMedium
            visible:true
            height: toolbarheight / 1.5
            width: height
            anchors.verticalCenter: toolbar.verticalCenter
            icon.height: toolbar.height
            icon.width: icon.height
        }


        IconButton {
            id: bookmarkButton
            property bool favorited: bookmarks.count > 0 && bookmarks.contains(webview.url)
            icon.source: {
                if (readerMode) nightMode ? "image://theme/icon-camera-wb-sunny" : "image://theme/icon-camera-wb-tungsten"
                else favorited ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
            }
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingSmall
            height: toolbarheight / 1.5
            width: height
            anchors.verticalCenter: toolbar.verticalCenter
            icon.height: toolbar.height
            icon.width: icon.height
            onClicked: {
                if (readerMode) {
                    if (!nightMode)
                        webview.experimental.evaluateJavaScript("document.body.style.backgroundColor=\"#262626\"; document.body.style.color=\"#FFFFFF\"");
                    else
                        webview.experimental.evaluateJavaScript("document.body.style.backgroundColor=\"#f4f4f4\"; document.body.style.color=\"#000000\"");

                    nightMode = !nightMode
                }
                else {
                    if (favorited) {
                        bookmarks.removeBookmark(webview.url.toString())
                    } else {
                        bookmarks.addBookmark(webview.url.toString(), webview.title, userAgent)
                    }
                }
            }
            onPressAndHold: {
                favIconSaver.loadImage(webIcon.source)
                //console.debug("[FirstPage.qml] favIconSaver image loaded: " + favIconSaver.isImageLoaded(webIcon.source));
                var favIconPath = _fm.getHome() + "/.local/share/applications/" + mainWindow.findHostname(webview.url) + "-" + mainWindow.findBaseName(webview.url) + ".png"
                var savingFav = favIconSaver.save(favIconPath);
                //console.debug("[FirstPage.qml] Saving FavIcon: " + savingFav)
                mainWindow.createDesktopLauncher(favIconPath ,webview.title,webview.url);
                mainWindow.infoBanner.showText(qsTr("Created Desktop Launcher for " + webview.title));
            }
        }
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
        anchors.bottomMargin: -toolbarSep.height
        width: parent.width;
    }

    // Extra Toolbar
    Rectangle {
        id: extraToolbar
        width: page.width
        property bool quickmenu
        //color: Theme.highlightBackgroundColor // As alternative perhaps maybe someday
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#353535" }
            GradientStop { position: 0.85; color: "#262626"}
        }
        height: 0
        z: 92
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
            font.pixelSize: parent.height - (minimizeButton.height + Theme.paddingLarge)
            text: {
                if (minimizeButton.highlighted) { _ngfEffect.play(); return qsTr("Minimize") }
                else if (newTabButton.highlighted) { _ngfEffect.play(); return qsTr("New Tab") }
                else if (newWindowButton.highlighted) { _ngfEffect.play(); return qsTr("New Window") }
                else if (reloadThisButton.highlighted) { _ngfEffect.play(); return qsTr("Reload") }
                else if (orientationLockButton.highlighted) { _ngfEffect.play(); return qsTr("Lock Orientation") }
                else if (readerModeButton.highlighted) { _ngfEffect.play(); return qsTr("Reader Mode") }
                else if (searchModeButton.highlighted) { _ngfEffect.play(); return qsTr("Search") }
                else if (shareButton.highlighted) { _ngfEffect.play(); return qsTr("Share") }
                else if (extraToolbar.opacity == 1 && extraToolbar.quickmenu) { _ngfEffect.play(); return qsTr("Close menu") }
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
            anchors.bottomMargin: actionLbl.height / 2
            icon.height: height
            icon.width: icon.height
            height: toolbarheight / 1.5
            width: height
            onClicked: {
                if (toolbar.state == "expanded") toolbar.state = "minimized"
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
            anchors.bottomMargin: actionLbl.height / 2
            icon.height: height
            icon.width: icon.height
            height: toolbarheight / 1.5
            width: height
            onClicked: {
                mainWindow.loadInNewTab("about:bookmarks");
                highlighted = false;
                extraToolbar.hide();
            }
        }

        IconButton {
            id: newWindowButton
            icon.source: "image://theme/icon-m-tab"
            anchors.left: newTabButton.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.bottom: parent.bottom
            anchors.bottomMargin: actionLbl.height / 2
            icon.height: height
            icon.width: icon.height
            height: toolbarheight / 1.5
            width: height
            Image {
                anchors.fill: parent
                source: "image://theme/icon-m-add"
            }
            onClicked: {
                mainWindow.openNewWindow("about:bookmarks");
                highlighted = false;
                extraToolbar.hide();
            }
        }


        IconButton {
            id: reloadThisButton
            icon.source: "image://theme/icon-m-refresh"
            anchors.left: newWindowButton.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.bottom: parent.bottom
            anchors.bottomMargin: actionLbl.height / 2
            icon.height: extraToolbar.height - (extraToolbar.height / 3)
            icon.width: icon.height
            height: toolbarheight / 1.5
            width: height
            onClicked: {
                webview.reload();
                highlighted = false;
                extraToolbar.hide();
            }
        }

        IconButton {
            id: orientationLockButton
            icon.source: "image://theme/icon-m-backup"
            anchors.left: reloadThisButton.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.bottom: parent.bottom
            anchors.bottomMargin: actionLbl.height / 2
            icon.height: extraToolbar.height - (extraToolbar.height / 3)
            icon.width: icon.height
            height: toolbarheight / 1.5
            width: height
            Image {
                source: "image://theme/icon-m-reset"
                anchors.fill: parent
                visible: page.allowedOrientations !== Orientation.All
            }
            onClicked: {
                if (page.allowedOrientations === Orientation.All) { page.allowedOrientations = page.orientation; mainWindow.orient = page.orientation }
                else { page.allowedOrientations = Orientation.All; mainWindow.orient = Orientation.All; }
                highlighted = false;
                extraToolbar.hide();
            }
        }

        IconButton {
            id: readerModeButton
            icon.source: "image://theme/icon-m-message"
            anchors.left: orientationLockButton.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.bottom: parent.bottom
            anchors.bottomMargin: actionLbl.height / 2
            icon.height: extraToolbar.height - (extraToolbar.height / 3)
            icon.width: icon.height
            height: toolbarheight / 1.5
            width: height
            onClicked: {
                toggleReaderMode()
                highlighted = false
                extraToolbar.hide();
            }
        }

        IconButton {
            id: searchModeButton
            icon.source: "image://theme/icon-m-search"
            anchors.left: readerModeButton.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.bottom: parent.bottom
            anchors.bottomMargin: actionLbl.height / 2
            icon.height: extraToolbar.height - (extraToolbar.height / 3)
            icon.width: icon.height
            height: toolbarheight / 1.5
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
            anchors.bottom: parent.bottom
            anchors.bottomMargin: actionLbl.height / 2
            icon.height: extraToolbar.height - (extraToolbar.height / 3)
            icon.width: icon.height
            height: toolbarheight / 1.5
            width: height
            visible: mainWindow.transferEngine.count > 0
            onClicked: {
                // Open Share Context Menu
                //console.debug("Open Share context menu here")
                shareContextMenu.share(webview.title, webview.url);
                highlighted = false;
                extraToolbar.hide();
            }
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
    Rectangle {
        id: mediaDownloadRec
        property string mediaUrl
        z:90

        onMediaUrlChanged: {
            //webview.checkYoutubeURL(mediaUrl);
            if (mediaYt && mediaUrl != "") {
                //console.debug("[FirstPage.qml] Youtube Media URL: " + mediaUrl + " Counter = " + counter)
                counter = counter + 1
                mediaList.insert(counter, {"mediaTitle": mediaUrl, "url": mediaUrl});
                YT.getYoutubeDirectStream(mediaUrl.toString(),page, counter);
            }
            else if (mediaUrl != "" && !mediaList.contains(mediaUrl)) {
                counter = counter + 1
                var ext = mediaUrl.substr(mediaUrl.lastIndexOf('.') + 1);
                if (ext.length != 0)
                    mediaList.insert(counter, {"mediaTitle": mainWindow.findBaseName(mediaUrl) + " (" + ext+ ")", "url": mediaUrl});
                else
                    mediaList.insert(counter, {"mediaTitle": mainWindow.findBaseName(mediaUrl), "url": mediaUrl});
            }
//            console.debug("[firstPage.qml] MediaUrl changed to:" + mediaUrl)
        }

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#262626" }
            GradientStop { position: 0.85; color: "#1F1F1F"}
        }
        anchors.bottom: {
            if (extraToolbar.enabled) return extraToolbar.top
            //else if (loadingRec.visible == true) return loadingRec.top
            else return toolbar.top
        }
        //anchors.bottomMargin: Theme.paddingSmall // This looks ugly
        width: parent.width
        height: toolbarheight
        visible: false

        ProgressCircle {
            id: progressCircleYt
            z: 90
            anchors.centerIn: parent
            visible: ytUrlLoading
            height: toolbarheight / 2.25
            width: height
            Timer {
                interval: 32
                repeat: true
                onTriggered: progressCircleYt.value = (progressCircleYt.value + 0.005) % 1.0
                running: {
                    if (ytUrlLoading) {
                        if ((mediaDownloadRec.mediaUrl != "") || (yt720p != "") || (yt480p != "") || (yt360p != "") || (yt240p != "")) return true
                    }
                    else return false
                }
            }
        }
        Label {
            id: mediaDownloadRecTitle
            anchors.centerIn: parent
            anchors.margins: Theme.paddingLarge
            visible: !progressCircleYt.visible
            width: parent.width - (mediaDownloadBtn.width + mediaPlayBtn.width) - Theme.paddingLarge
            truncationMode: TruncationMode.Fade
            text: mediaList.count > 0 ? mediaList.get(0).mediaTitle : ""
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (progressCircleYt.visible) {
                    ytUrlLoading = false;
                    mediaDownloadRec.visible = false;
                    YT.getYoutubeDirectStream(webview.url,page);
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (mediaList.count > 1) {
                    console.debug("[FirstPage.qml]: Chooser clicked because mediaList.count = " + mediaList.count);
//                    console.debug("[FirstPage.qml] mediaList.get(0).yt360p:" + mediaList.get(0).yt360p);
//                    console.debug("[FirstPage.qml] mediaList.get(1).yt360p:" + mediaList.get(1).yt360p);
//                    console.debug("[FirstPage.qml] mediaList.get(2).yt360p:" + mediaList.get(2).yt360p);
                    suggestionView.model = mediaList
                    suggestionView.anchors.bottom = mediaDownloadRec.top
                    suggestionView.visible = true
                }
            }
        }

        IconButton {
            id: mediaDownloadBtn
            icon.source: "image://theme/icon-m-device-download"
            onClicked:  {
                if (mediaYt || mediaYtEmbeded) {
                    if (yt720p != "") pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": yt720p, "downloadName": mediaDownloadRecTitle.text, "dataContainer": webview});
                    else if (yt480p != "") pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": yt480p, "downloadName": mediaDownloadRecTitle.text, "dataContainer": webview});
                    else if (yt360p != "") pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": yt360p,"downloadName": mediaDownloadRecTitle.text, "dataContainer": webview});
                    else if (yt240p != "") pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": yt240p,"downloadName": mediaDownloadRecTitle.text,"dataContainer": webview});
                }
                else if (mediaDownloadRec.mediaUrl != "") pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": mediaDownloadRec.mediaUrl, "dataContainer": webview});
                else pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": url, "dataContainer": webview});
            }
            visible: ! progressCircleYt.visible
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingSmall
            anchors.verticalCenter: parent.verticalCenter
            height: toolbarheight / 1.2   // TODO: 1.5 looks to small. But that depends on the image. Maybe later sailfish OS versions will change something here
            width: height
            icon.height: height
            icon.width: width
            onPressAndHold: {
                //console.debug("[FirstPage.qml] mediaList.count: " + mediaList.count);
                //console.debug("[FirstPage.qml] mediaList.get(0).mediaTitle: " + mediaList.get(0).mediaTitle);
                if (mediaYt || mediaYtEmbeded) ytQualChooser.setSource("helper/browserComponents/ytQualityChooserContextMenu.qml", {"url720p":yt720p, "url480p":yt480p, "url360p": yt360p, "url240p":yt240p, "download": true, "streamTitle": mediaDownloadRecTitle.text})
                ytQualChooser.item.show();
            }
        }
        IconButton {
            id: mediaPlayBtn
            icon.source: "image://theme/icon-m-play"
            onClicked:  {
                if (mainWindow.vPlayerExternal) mainWindow.infoBanner.showText(qsTr("Opening..."));
                if (mediaYt || mediaYtEmbeded) {
                    // Always try to play highest quality first // TODO: Allow setting a default
                    if (! mainWindow.vPlayerExternal) {
                        console.debug("Load videoPlayer in window...");
                        if (yt720p != "") vPlayerLoader.setSource("VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: yt720p, streamTitle: mediaDownloadRecTitle.text});
                        else if (yt480p != "") vPlayerLoader.setSource("VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: yt480p, streamTitle: mediaDownloadRecTitle.text});
                        else if (yt360p != "") vPlayerLoader.setSource("VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: yt360p, streamTitle: mediaDownloadRecTitle.text});
                        else if (yt240p != "") vPlayerLoader.setSource("VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: yt240p, streamTitle: mediaDownloadRecTitle.text});
                    }
                    else {
                        if (yt720p != "") mainWindow.openWithvPlayer(yt720p,mediaDownloadRecTitle.text);
                        else if (yt480p != "") mainWindow.openWithvPlayer(yt480p,mediaDownloadRecTitle.text);
                        else if (yt360p != "") mainWindow.openWithvPlayer(yt360p,mediaDownloadRecTitle.text);
                        else if (yt240p != "") mainWindow.openWithvPlayer(yt240p,mediaDownloadRecTitle.text);
                    }
                }
                else if (mediaDownloadRec.mediaUrl != "" && mainWindow.vPlayerExternal) mainWindow.openWithvPlayer(mediaDownloadRec.mediaUrl,"");
                else if (mediaDownloadRec.mediaUrl != "") vPlayerLoader.setSource("VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: mediaDownloadRec.mediaUrl})
                else Qt.openUrlExternally(url);
            }
            visible: ! progressCircleYt.visible
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall
            anchors.verticalCenter: parent.verticalCenter
            height: toolbarheight / 1.2
            width: height
            icon.height: height
            icon.width: width
            onPressAndHold: {
                //console.debug("[firstPage.qml]: 720p:" + mainWindow.yt720p + " 480p:" + mainWindow.yt480p + " 360p:" + mainWindow.yt360p + " 240p:" + mainWindow.yt240p);
                if (mediaYt || mediaYtEmbeded) ytQualChooser.setSource("helper/browserComponents/ytQualityChooserContextMenu.qml", {"url720p":yt720p, "url480p":yt480p, "url360p": yt360p, "url240p":yt240p})
                ytQualChooser.item.show();
            }
        }


    }

    Loader {
        id: vPlayerLoader
        width: page.width
        height: page.height - toolbar.height - mediaDownloadRec.height
        //source: "VideoPlayer.qml"
        z:80
        onLoaded: if (webview.visible) webview.visible = false
    }

    Connections {
        target: vPlayerLoader.item
        onSwitchFullscreen: {
            if (vPlayerLoader.item.fullscreen === true) {
                vPlayerLoader.anchors.fill = page
                vPlayerLoader.z = 99 //Above everything else
            }
            else {
                vPlayerLoader.anchors.fill = webview
                vPlayerLoader.width = page.width
                vPlayerLoader.height = page.height - toolbar.height - mediaDownloadRec.height
                if (toolbar.state == "expanded") toolbar.state = "minimized"
                vPlayerLoader.z = 80
            }
        }
        onClosePlayer: {
            vPlayerLoader.anchors.fill = webview
            vPlayerLoader.z = 80
            vPlayerLoader.setSource(""); 
            if (!webview.visible) webview.visible = true
        }
    }

    Loader {
        id: ytQualChooser
        anchors.bottom: mediaDownloadRec.top
        anchors.bottomMargin: -toolbarSep.height
        width: parent.width;
        z: 90
    }

    Connections {
        target: ytQualChooser.item
        onPlayStream: {
            if (vPlayerLoader.status == Loader.Ready) {
                vPlayerLoader.setSource("");  // Changing the source only seems not to work for some obscure reason
            }
            vPlayerLoader.setSource("VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: url, streamTitle: mediaDownloadRecTitle.text})
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
    ContextMenu {
        id: contextMenu
        visible: false
        anchors.bottom: toolbar.top
        anchors.bottomMargin: -toolbarSep.height
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
        onSelected: { urlText.focus = false; suggestionView.visible = false ; webview.url = url; webview.focus = true; }
        onSelectedMedia: {
            suggestionView.visible = false;
            mediaDownloadRecTitle.text = mediaTitle;
            page.yt720p = yt720p;
            page.yt480p = yt480p;
            page.yt360p = yt360p;
            page.yt240p = yt240p;
            if (!mediaYt) mediaDownloadRec.mediaUrl = url;
            // Need to destroy player here as it has probably the wrong URL
            vPlayerLoader.setSource("");
            if (!webview.visible) webview.visible = true
        }
        z: vPlayerLoader.z + 1
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
            enabled: page.status === PageStatus.Active && webview.contentItem && vPlayerLoader.status != Loader.Ready
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
}
