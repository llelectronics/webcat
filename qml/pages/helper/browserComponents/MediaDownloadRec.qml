import QtQuick 2.0
import Sailfish.Silica 1.0
import "../yt.js" as YT

// On Media Loaded show download button
Rectangle {
    id: mediaDownloadRec

    property string mediaUrl
    property var dataContainer
    property alias mediaDownloadRecTitle: mediaDownloadRecTitle

    z:90

    onMediaUrlChanged: {
        //dataContainer.webview.checkYoutubeURL(mediaUrl);
        if (dataContainer.mediaYt && dataContainer.mediaUrl != "") {
            //console.debug("[FirstPage.qml] Youtube Media URL: " + mediaUrl + " Counter = " + counter)
            counter = counter + 1
            dataContainer.mediaList.insert(counter, {"mediaTitle": mediaUrl, "url": mediaUrl, "ytMedia":true});
            YT.getYoutubeDirectStream(mediaUrl.toString(),page, counter);
        }
        else if (mediaUrl != "" && !dataContainer.mediaList.contains(mediaUrl)) {
            counter = counter + 1
            var ext = mediaUrl.substr(mediaUrl.lastIndexOf('.') + 1);
            if (ext.length != 0)
                dataContainer.mediaList.insert(counter, {"mediaTitle": mainWindow.findBaseName(mediaUrl) + " (" + ext+ ")", "url": mediaUrl, "ytMedia": false});
            else
                dataContainer.mediaList.insert(counter, {"mediaTitle": mainWindow.findBaseName(mediaUrl), "url": mediaUrl, "ytMedia": false});
        }
//            console.debug("[firstPage.qml] MediaUrl changed to:" + mediaUrl)
    }

    gradient: Gradient {
        GradientStop { position: 0.0; color: isLightTheme ? "#dfdfdf" : "#262626" }
        GradientStop { position: 0.85; color: isLightTheme ? "#dfdfdf" : "#1F1F1F"}
    }
    anchors.bottom: {
        if (dataContainer.extraToolbar.enabled) return dataContainer.extraToolbar.top
        //else if (loadingRec.visible == true) return loadingRec.top
        else return dataContainer.toolbar.top
    }
    //anchors.bottomMargin: Theme.paddingSmall // This looks ugly
    width: dataContainer.width
    height: dataContainer.toolbarheight
    visible: false

    ProgressCircle {
        id: progressCircleYt
        z: 90
        anchors.centerIn: parent
        visible: dataContainer.ytUrlLoading
        height: dataContainer.toolbarheight / 2.25
        width: height
        Timer {
            interval: 32
            repeat: true
            onTriggered: progressCircleYt.value = (progressCircleYt.value + 0.005) % 1.0
            running: {
                if (dataContainer.ytUrlLoading) {
                    if ((mediaDownloadRec.mediaUrl != "") || (dataContainer.yt720p != "") || (dataContainer.yt480p != "") || (dataContainer.yt360p != "") || (dataContainer.yt240p != "")) return true
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
        text: dataContainer.mediaList.count > 0 ? dataContainer.mediaList.get(0).mediaTitle : ""
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (progressCircleYt.visible) {
                dataContainer.ytUrlLoading = false;
                mediaDownloadRec.visible = false;
                YT.getYoutubeDirectStream(dataContainer.webview.url,page);
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (dataContainer.mediaList.count > 1) {
                console.debug("[MediaDownloadRec.qml]: Chooser clicked because dataContainer.mediaList.count = " + dataContainer.mediaList.count);
//                    console.debug("[FirstPage.qml] dataContainer.mediaList.get(0).dataContainer.yt360p:" + dataContainer.mediaList.get(0).dataContainer.yt360p);
//                    console.debug("[FirstPage.qml] dataContainer.mediaList.get(1).dataContainer.yt360p:" + dataContainer.mediaList.get(1).dataContainer.yt360p);
//                    console.debug("[FirstPage.qml] dataContainer.mediaList.get(2).dataContainer.yt360p:" + dataContainer.mediaList.get(2).dataContainer.yt360p);
                suggestionView.model = dataContainer.mediaList
                suggestionView.anchors.bottom = mediaDownloadRec.top
                suggestionView.visible = true
            }
        }
    }

    IconButton {
        id: mediaDownloadBtn
        icon.source: "image://theme/icon-m-device-download"
        onClicked:  {
            if (dataContainer.mediaYt || dataContainer.mediaYtEmbeded) {
                if (dataContainer.yt720p != "") pageStack.push(Qt.resolvedUrl("../../DownloadManager.qml"), {"downloadUrl": dataContainer.yt720p, "downloadName": mediaDownloadRecTitle.text, "dataContainer": dataContainer.webview});
                else if (dataContainer.yt480p != "") pageStack.push(Qt.resolvedUrl("../../DownloadManager.qml"), {"downloadUrl": dataContainer.yt480p, "downloadName": mediaDownloadRecTitle.text, "dataContainer": dataContainer.webview});
                else if (dataContainer.yt360p != "") pageStack.push(Qt.resolvedUrl("../../DownloadManager.qml"), {"downloadUrl": dataContainer.yt360p,"downloadName": mediaDownloadRecTitle.text, "dataContainer": dataContainer.webview});
                else if (dataContainer.yt240p != "") pageStack.push(Qt.resolvedUrl("../../DownloadManager.qml"), {"downloadUrl": dataContainer.yt240p,"downloadName": mediaDownloadRecTitle.text,"dataContainer": dataContainer.webview});
                else if (mediaDownloadRec.mediaUrl != "") pageStack.push(Qt.resolvedUrl("../../DownloadManager.qml"), {"downloadUrl": mediaDownloadRec.mediaUrl, "dataContainer": dataContainer.webview});
            }
            else if (mediaDownloadRec.mediaUrl != "") pageStack.push(Qt.resolvedUrl("../../DownloadManager.qml"), {"downloadUrl": mediaDownloadRec.mediaUrl, "dataContainer": dataContainer.webview});
            else pageStack.push(Qt.resolvedUrl("../../DownloadManager.qml"), {"downloadUrl": url, "dataContainer": dataContainer.webview});
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
            //console.debug("[FirstPage.qml] dataContainer.mediaList.count: " + dataContainer.mediaList.count);
            //console.debug("[FirstPage.qml] dataContainer.mediaList.get(0).mediaTitle: " + dataContainer.mediaList.get(0).mediaTitle);
            if (dataContainer.mediaYt || dataContainer.mediaYtEmbeded) dataContainer.ytQualChooser.setSource("ytQualityChooserContextMenu.qml", {"url720p":dataContainer.yt720p, "url480p":dataContainer.yt480p, "url360p": dataContainer.yt360p, "url240p":dataContainer.yt240p, "download": true, "streamTitle": mediaDownloadRecTitle.text})
            dataContainer.ytQualChooser.item.show();
        }
    }
    IconButton {
        id: mediaPlayBtn
        icon.source: "image://theme/icon-m-play"
        onClicked:  {
            if (mainWindow.vPlayerExternal) {
                mainWindow.infoBanner.parent = page
                mainWindow.infoBanner.anchors.top = page.top
                mainWindow.infoBanner.showText(qsTr("Opening..."));
            }
            if (dataContainer.mediaYt || dataContainer.mediaYtEmbeded) {
                // Always try to play highest quality first // TODO: Allow setting a default
                if (! mainWindow.vPlayerExternal) {
                    console.debug("Load videoPlayer in window...");
                    if (dataContainer.yt720p != "") dataContainer.vPlayerLoader.setSource("../../VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: dataContainer.yt720p, streamTitle: mediaDownloadRecTitle.text});
                    else if (dataContainer.yt480p != "") dataContainer.vPlayerLoader.setSource("../../VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: dataContainer.yt480p, streamTitle: mediaDownloadRecTitle.text});
                    else if (dataContainer.yt360p != "") dataContainer.vPlayerLoader.setSource("../../VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: dataContainer.yt360p, streamTitle: mediaDownloadRecTitle.text});
                    else if (dataContainer.yt240p != "") dataContainer.vPlayerLoader.setSource("../../VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: dataContainer.yt240p, streamTitle: mediaDownloadRecTitle.text});
                    else if (mediaDownloadRec.mediaUrl != "") dataContainer.vPlayerLoader.setSource("../../VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: mediaDownloadRec.mediaUrl, streamTitle: mediaDownloadRecTitle.text});
                }
                else {
                    if (dataContainer.yt720p != "") mainWindow.openWithvPlayer(dataContainer.yt720p,mediaDownloadRecTitle.text);
                    else if (dataContainer.yt480p != "") mainWindow.openWithvPlayer(dataContainer.yt480p,mediaDownloadRecTitle.text);
                    else if (dataContainer.yt360p != "") mainWindow.openWithvPlayer(dataContainer.yt360p,mediaDownloadRecTitle.text);
                    else if (dataContainer.yt240p != "") mainWindow.openWithvPlayer(dataContainer.yt240p,mediaDownloadRecTitle.text);
                    else if (mediaDownloadRec.mediaUrl != "") mainWindow.openWithvPlayer(mediaDownloadRec.mediaUrl,mediaDownloadRecTitle.text);
                }
            }
            else if (mediaDownloadRec.mediaUrl != "" && mainWindow.vPlayerExternal) mainWindow.openWithvPlayer(mediaDownloadRec.mediaUrl,"");
            else if (mediaDownloadRec.mediaUrl != "") dataContainer.vPlayerLoader.setSource("../../VideoPlayerComponent.qml", {dataContainer: firstPage, streamUrl: mediaDownloadRec.mediaUrl})
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
            //console.debug("[firstPage.qml]: 720p:" + mainWindow.dataContainer.yt720p + " 480p:" + mainWindow.dataContainer.yt480p + " 360p:" + mainWindow.dataContainer.yt360p + " 240p:" + mainWindow.dataContainer.yt240p);
            if (dataContainer.mediaYt || dataContainer.mediaYtEmbeded) dataContainer.ytQualChooser.setSource("ytQualityChooserContextMenu.qml", {"url720p":dataContainer.yt720p, "url480p":dataContainer.yt480p, "url360p": dataContainer.yt360p, "url240p":dataContainer.yt240p})
            dataContainer.ytQualChooser.item.show();
        }
    }


}
