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

Page {
    id: page
    allowedOrientations: Orientation.All
    property alias url: webview.url
    property alias toolbar: toolbar
    property ListModel bookmarks
    property ListModel tabModel
    property string pageId
    backNavigation: false
    forwardNavigation: false
    showNavigationIndicator: false

    function loadUrl(requestUrl) {
        var valid = requestUrl
        if (valid.indexOf(":")<0) {
            if (valid.indexOf(".")<0 || valid.indexOf(" ")>=0) {
                // Fall back to a search engine; hard-code Google
                url = "http://www.google.com/search?q="+valid
            } else {
                url = "http://"+valid
            }
        }
    }
    // Todo: Need to merge fixUrl with loadUrl if latter is even necessary anymore
    function fixUrl(nonFixedUrl) {
        var valid = nonFixedUrl
        if (valid.match("^/")) return url + valid  // Necessary for reddit or google news i page but it will break local filesystem support, so you NEED to enter file:// infront
        else if (valid.indexOf(":")<0) {
            if (valid.indexOf(".")<0 || valid.indexOf(" ")>=0) {
                // Fall back to a search engine; hard-code Google
                return "http://www.google.com/search?q="+valid;
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
        // Don't use fixed values otherwise you won't make it into harbour
        //        width: page.orientation == Orientation.Portrait ? 540 : 960
        //        height: page.orientation == Orientation.Portrait ? 960 : 540
        anchors.fill: parent // automatically changed width and heights according to orientation
        //onUrlChanged: {
        /* user clicked a link */
        /*if (siteURL != url)
           siteURL = url */    // WTF: Create a loop on redirects ?
        //}

        // We don't want pageStackNavigation to interfere
        overridePageStackNavigation: true
        header: PageHeader {height: 0}

        // Prevent crashes by loading the mobile site instead of the desktop one // TODO: Make all this configurable via config later on
        //experimental.userAgent: "Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"
        experimental.userAgent: "Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
        experimental.preferences.minimumFontSize: 16  // We need readable fonts on g+, youtube and so on. This might hurt tmo though
        experimental.preferences.defaultFontSize: 20
        experimental.preferences.defaultFixedFontSize: 18
        experimental.preferences.dnsPrefetchEnabled: true

        // Scale the websites like g+ and others a little bit for better reading
        experimental.deviceWidth: page.width / 1.5
        experimental.deviceHeight: page.height
        experimental.itemSelector: PopOver {}
        experimental.preferences.fullScreenEnabled: true
        experimental.preferences.developerExtrasEnabled: true

        // This userScript makes longpress detection and other things working
        experimental.userScripts: [Qt.resolvedUrl("helper/userscript.js")]
        experimental.preferences.navigatorQtObjectEnabled: true

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
                if (data.target === '_blank') { // open link in new tab
                    openNewTab('page-'+salt(), fixUrl(data.href));
                }
                break;
            }
            // TODO: Need to add a contextmenu for opening up pages in new tab
            case 'longpress': {
                showContextMenu(data.href);
                // Open a new tab for now
                //console.debug(fixUrl(data.href));
                //openNewTab('page-'+salt(), fixUrl(data.href));
            }
            }
        }

        onLoadingChanged:
        {
            if (loadRequest.status == WebView.LoadStartedStatus)
            {
                urlLoading = true;
                contextMenu.visible = false;
            }
            else if (loadRequest.status == WebView.LoadFailedStatus)
            {
                urlLoading = false;
                errorText = "Load failed\n"+loadRequest.errorString
                popup.visible = true
            }
            else
            {
                urlLoading = false;
                if (url == "about:bookmarks") pageStack.push(Qt.resolvedUrl("SelectUrl.qml"), { dataContainer: page, siteURL: webview.url, bookmarks: page.bookmarks, siteTitle: webview.title})
                tabModel.setProperty(tabModel.count-1, "title", webview.title);
                //console.debug(tabModel.get(0).title);
            }
        }
        onNavigationRequested: {
            // detect URL scheme prefix, most likely an external link
            var schemaRE = /^\w+:/;
            if (schemaRE.test(request.url)) {
                request.action = WebView.AcceptRequest;
            } else {
                request.action = WebView.IgnoreRequest;
                popup.visible = true
                // delegate request.url here
            }
        }
        MouseArea {
            id: contextOverlay;
            anchors.fill: parent;
            enabled: contextMenu.visible
            onClicked: contextMenu.visible = false
        }
    } // WebView

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
                }
                PropertyChanges {
                    target: backIcon
                    visible: webview.canGoBack
                }
                PropertyChanges {
                    target: forIcon
                    visible: webview.canGoForward
                }
                PropertyChanges {
                    target: urlText
                    visible: true
                }
                PropertyChanges {
                    target: refreshButton
                    visible: false
                }
                PropertyChanges {
                    target: bookmarkButton
                    visible: true
                }
            },
            State {
                name: "minimized"
                PropertyChanges {
                    target: toolbar
                    height: 20
                }
                PropertyChanges {
                    target: urlTitle
                    visible: true
                }
                PropertyChanges {
                    target: gotoButton
                    visible: false
                }
                PropertyChanges {
                    target: backIcon
                    visible: false
                }
                PropertyChanges {
                    target: forIcon
                    visible: false
                }
                PropertyChanges {
                    target: urlText
                    visible: false
                }
                PropertyChanges {
                    target: refreshButton
                    visible: false
                }
                PropertyChanges {
                    target: bookmarkButton
                    visible: false
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
        }

        IconButton {
            id: gotoButton
            icon.source: "image://theme/icon-m-tabs"
            anchors.left: toolbar.left
            anchors.leftMargin: Theme.paddingSmall
            onClicked: pageStack.push(Qt.resolvedUrl("SelectUrl.qml"), { dataContainer: page, siteURL: webview.url, bookmarks: page.bookmarks, siteTitle: webview.title})
            onPressAndHold: {
                if (toolbar.state == "expanded") toolbar.state = "minimized"
            }

            //            Label {
            //                text: tabs.count
            //                x: (parent.width - contentWidth) / 2 - 5
            //                y: (parent.height - contentHeight) / 2 - 5
            //                font.pixelSize: Theme.fontSizeExtraSmall
            //                font.bold: true
            //                color: tabPageButton.down ? Theme.highlightColor : Theme.highlightDimmerColor
            //                horizontalAlignment: Text.AlignHCenter
            //            }
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
                    bookmarks.addBookmark(webview.url.toString(), webview.title)
                }
            }
        }
    }

    // On Loading show cancel loading button
    Rectangle {
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

    // Long press contextmenu for link
    Rectangle {
        id: contextMenu
        visible: false
        anchors.bottom: toolbar.top
        anchors.bottomMargin: -toolbarSep.height
        width: parent.width; height: 0
        onVisibleChanged: {
            //console.debug(visible);
            if (visible == true) {
                //console.debug("Now showing contextmenu")
                height = contextUrl.height + contextButtons.height + Theme.paddingMedium
            }
            else height = 0
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
            Button {
                text: "Open"
                onClicked: { webview.url = fixUrl(contextUrl.text); contextMenu.visible = false }
            }
            Button {
                text: "Open in New Tab"
                onClicked: { mainWindow.openNewTab("page"+salt(), fixUrl(contextUrl.text)); contextMenu.visible = false }
            }
            Button {
                text: "Copy Link"
                onClicked: { contextUrl.selectAll(); contextUrl.copy(); contextMenu.visible = false }
            }
        }
    }
}


