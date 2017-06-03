import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import "helper/videoPlayerComponents"

Item {
    id: videoPlayerPage
    objectName: "videoPlayerPage"
    //allowedOrientations: Orientation.All

    focus: true

    property QtObject dataContainer

    property string videoDuration: {
        if (videoPoster.duration > 3599) return Format.formatDuration(videoPoster.duration, Formatter.DurationLong)
        else return Format.formatDuration(videoPoster.duration, Formatter.DurationShort)
    }
    property string videoPosition: {
        if (videoPoster.position > 3599) return Format.formatDuration(videoPoster.position, Formatter.DurationLong)
        else return Format.formatDuration(videoPoster.position, Formatter.DurationShort)
    }
    property string originalUrl
    property string streamUrl
    property bool youtubeDirect: true;
    property bool isYtUrl
    property string streamTitle
    property string title: videoPoster.player.metaData.title ? videoPoster.player.metaData.title : ""
    property string artist: videoPoster.player.metaData.albumArtist ? videoPoster.player.metaData.albumArtist : ""
    property bool liveView: true
    property Page dPage
    property bool autoplay: true
    property bool fullscreen: false
    property bool videoPage: false
    property bool isNewSource: false

    property alias showTimeAndTitle: showTimeAndTitle
    property alias pulley: pulley
    property alias onlyMusic: onlyMusic
    property alias videoPoster: videoPoster

    signal switchFullscreen()
    signal closePlayer()

    function switchScreen() {
        if (fullscreen === false) {
            fsIcon.icon.source = "img/exit-fullscreen.png"
            fullscreen = true
            switchFullscreen()
        }
        else {
            fsIcon.icon.source = "img/enter-fullscreen.png"
            fullscreen = false
            switchFullscreen()
        }
    }

    Component.onCompleted: {
        if (autoplay) {
            videoPoster.play();
            pulley.visible = false;
        }
    }



    onStreamUrlChanged: {
        if (errorDetail.visible && errorTxt.visible) { errorDetail.visible = false; errorTxt.visible = false }
        videoPoster.showControls();
        if (streamTitle == "") streamTitle = mainWindow.findBaseName(streamUrl)
        isNewSource = true
    }

    function videoPlay() {
        // this seems not to work somehow
        if (videoPoster.player.playbackState == MediaPlayer.PlayingState) videoPoster.player.stop();
        videoPoster.player.play();
    }

    Rectangle {
        id: headerBg
        width:parent.width
        height: {
            if (urlHeader.visible && videoPage == false) urlHeader.height * 2
            else if (urlHeader.visible) urlHeader.height + Theme.paddingLarge
            else if (titleHeader.visible && videoPage == false) titleHeader.height * 2
            else if (titleHeader.visible) titleHeader.height + Theme.paddingLarge
        }
        visible: {
            if (urlHeader.visible || titleHeader.visible) return true
            else return false
        }
        gradient: Gradient {
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 1.0; color: "transparent" } //Theme.highlightColor} // Black seems to look and work better
        }
    }

    Label {
        id: urlHeader
        text: mainWindow.findBaseName(streamUrl)
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: (orientation == Orientation.LandscapeMask) ? Theme.paddingMedium : Theme.paddingLarge
        anchors.leftMargin: Theme.paddingLarge
        truncationMode: TruncationMode.Fade
        visible: {
            if (titleHeader.visible == false && pulley.visible && mainWindow.applicationActive && fullscreen === true) return true
            else return false
        }
        font.pixelSize: mainWindow.applicationActive ? Theme.fontSizeMedium : Theme.fontSizeHuge
        color: "white"
        states: [
            State {
                name: "cover"
                PropertyChanges {
                    target: urlHeader
                    visible: true
                }
            }
        ]
    }
    Label {
        id: titleHeader
        text: streamTitle
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: (orientation == Orientation.LandscapeMask) ? Theme.paddingMedium : Theme.paddingLarge
        anchors.leftMargin: Theme.paddingLarge
        truncationMode: TruncationMode.Fade
        visible: {
            if (streamTitle != "" && pulley.visible && mainWindow.applicationActive && fullscreen === true) return true
            else return false
        }
        font.pixelSize: mainWindow.applicationActive ? Theme.fontSizeMedium : Theme.fontSizeHuge
        color: "white"
        states: [
            State {
                name: "cover"
                PropertyChanges {
                    target: titleHeader
                    visible: true
                }
            }
        ]
    }

    function videoPauseTrigger() {
        // this seems not to work somehow
        if (videoPoster.player.playbackState == MediaPlayer.PlayingState) videoPoster.player.pause();
        else if (videoPoster.source.toString().length !== 0) videoPoster.player.play();
        if (videoPoster.controls.opacity === 0.0) videoPoster.toggleControls();

    }

    Item {
        id: pulley

    }

    Image {
        id: onlyMusic
        anchors.centerIn: parent
        source: Qt.resolvedUrl("img/audio.png")
        opacity: 0.0
        Behavior on opacity { FadeAnimation { } }
    }

    ProgressCircle {
        id: progressCircle

        anchors.centerIn: parent
        visible: false

        Timer {
            interval: 32
            repeat: true
            onTriggered: progressCircle.value = (progressCircle.value + 0.005) % 1.0
            running: visible
        }
    }

    Column {
        id: errorBox
        anchors.top: parent.top
        anchors.topMargin: 65
        spacing: 15
        width: parent.width
        height: parent.height
        z:99
        visible: {
            if (errorTxt.text !== "" || errorDetail.text !== "" ) return true;
            else return false;
        }
        Label {
            // TODO: seems only show error number. Maybe disable in the future
            id: errorTxt
            text: ""

            //            anchors.top: parent.top
            //            anchors.topMargin: 65
            font.bold: true
            onTextChanged: {
                if (text !== "") visible = true;
            }
        }


        TextArea {
            id: errorDetail
            text: ""
            width: parent.width
            height: parent.height / 2
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            readOnly: true
            onTextChanged: {
                if (text !== "") visible = true;
            }
            background: null
        }
        Button {
            text: qsTr("Dismiss")
            onClicked: {
                errorTxt.text = ""
                errorDetail.text = ""
                errorBox.visible = false
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }


    Item {
        id: mediaItem
        property bool active : true
        visible: active && mainWindow.applicationActive
        anchors.fill: parent

        VideoPoster {
            id: videoPoster
            width: videoPlayerPage.width
            height: videoPlayerPage.height

            player: mediaPlayer

            //duration: videoDuration
            active: mediaItem.active
            source: streamUrl
            onSourceChanged: {
                player.stop();
                //play();  // autoPlay TODO: add config for it
                position = 0;
                player.seek(0);
            }

            onPlayClicked: {
                toggleControls();
            }

            function toggleControls() {
                //console.debug("Controls Opacity:" + controls.opacity);
                if (controls.opacity === 0.0) {
                    console.debug("Show controls");
                    controls.opacity = 1.0;
                }
                else {
                    console.debug("Hide controls");
                    controls.opacity = 0.0;
                }
                pulley.visible = !pulley.visible
            }

            function hideControls() {
                controls.opacity = 0.0
                pulley.visible = false
            }

            function showControls() {
                controls.opacity = 1.0
                pulley.visible = true
            }


            onClicked: {
                if (mediaPlayer.playbackState == MediaPlayer.PlayingState) {
                    //console.debug("Mouse values:" + mouse.x + " x " + mouse.y)
                    var middleX = width / 2
                    var middleY = height / 2
                    //console.debug("MiddleX:" + middleX + " MiddleY:"+middleY + " mouse.x:"+mouse.x + " mouse.y:"+mouse.y)
                    if ((mouse.x >= middleX - 64 && mouse.x <= middleX + 64) && (mouse.y >= middleY - 64 && mouse.y <= middleY + 64)) {
                        mediaPlayer.pause();
                        if (controls.opacity === 0.0) toggleControls();
                        progressCircle.visible = false;
                        if (! mediaPlayer.seekable) mediaPlayer.stop();
                    }
                    else {
                        toggleControls();
                    }
                } else {
                    //mediaPlayer.play()
                    //console.debug("clicked something else")
                    toggleControls();
                }
            }
        }

        Rectangle {
            anchors.centerIn: fsIcon
            width: fsIcon.width + 2
            height: fsIcon.height + 2
            color: "black"
            opacity: 0.4
            radius: width / 2
            border.color: "white"
            border.width: 2
            visible: videoPoster.controls.opacity && (videoPage == false)
        }

        Rectangle {
            anchors.centerIn: closeIcon
            width: closeIcon.width + 2
            height: closeIcon.height + 2
            color: "black"
            opacity: 0.4
            radius: width / 2
            border.color: "white"
            border.width: 2
            visible: videoPoster.controls.opacity && (videoPage == false)
        }

        IconButton {
            id: fsIcon
            icon.source: "img/enter-fullscreen.png"
            onClicked: switchScreen()
            anchors.right: mediaItem.right
            anchors.rightMargin: Theme.paddingMedium
            y: headerBg.height
            anchors.topMargin: Theme.paddingLarge * 2
            visible: (videoPage == false)
            opacity: videoPoster.controls.opacity
            width: height
            height: Theme.iconSizeMedium
            icon.width: width
            icon.height: height
        }
        IconButton {
            id: closeIcon
            icon.source: "img/close-icon.png"
            onClicked: closePlayer()
            anchors.left: mediaItem.left
            anchors.leftMargin: Theme.paddingMedium
            y: headerBg.height
            visible: (videoPage == false)
            anchors.topMargin: Theme.paddingLarge * 2
            opacity: videoPoster.controls.opacity
            width: height
            height: Theme.iconSizeMedium
            icon.width: width
            icon.height: height
        }
    }

    children: [

        // Always use a black background
        Rectangle {
            anchors.fill: parent
            color: "black"
        },

        VideoOutput {
            id: video
            anchors.fill: parent

            source: mediaPlayer

            visible: mediaPlayer.status >= MediaPlayer.Loaded && mediaPlayer.status <= MediaPlayer.EndOfMedia
            width: parent.width
            height: parent.height
            anchors.centerIn: videoPlayerPage

            ScreenBlank {
                suspend: mediaPlayer.playbackState == MediaPlayer.PlayingState
            }

        }
    ]

    // Need some more time to figure that out completely
    Timer {
        id: showTimeAndTitle
        property int count: 0
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            ++count
            if (count >= 5) {
                stop()
                coverTime.fadeOut.start()
                urlHeader.state = ""
                titleHeader.state = ""
                count = 0
            } else {
                coverTime.visible = true
                if (title.toString().length !== 0 && !mainWindow.applicationActive) titleHeader.state = "cover";
                else if (streamUrl.toString().length !== 0 && !mainWindow.applicationActive) urlHeader.state = "cover";
            }
        }
    }

    Rectangle {
        width: parent.width
        height: Theme.fontSizeHuge
        y: coverTime.y + 10
        color: "black"
        opacity: 0.4
        visible: coverTime.visible
    }

    Item {
        id: coverTime
        property alias fadeOut: fadeout
        //visible: !mainWindow.applicationActive && liveView
        visible: false
        onVisibleChanged: {
            if (visible) fadein.start()
        }
        anchors.top: titleHeader.bottom
        anchors.topMargin: 15
        x : (parent.width / 2) - ((curPos.width/2) + (dur.width/2))
        NumberAnimation {
            id: fadein
            target: coverTime
            property: "opacity"
            easing.type: Easing.InOutQuad
            duration: 500
            from: 0
            to: 1
        }
        NumberAnimation {
            id: fadeout
            target: coverTime
            property: "opacity"
            duration: 500
            easing.type: Easing.InOutQuad
            from: 1
            to: 0
            onStopped: coverTime.visible = false;
        }
        Label {
            id: dur
            text: videoDuration
            anchors.left: curPos.right
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeHuge
            font.bold: true
        }
        Label {
            id: curPos
            text: videoPosition + " / "
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeHuge
            font.bold: true
        }
    }

    MediaPlayer {
        id: mediaPlayer

        onDurationChanged: {
            //console.debug("Duration(msec): " + duration);
            videoPoster.duration = (duration/1000);
            if (hasAudio === true && hasVideo === false) onlyMusic.opacity = 1.0
            else onlyMusic.opacity = 0.0;
        }
        onStatusChanged: {
            //errorTxt.visible = false     // DEBUG: Always show errors for now
            //errorDetail.visible = false
            //console.debug("[videoPlayer.qml]: mediaPlayer.status: " + mediaPlayer.status)
            if (mediaPlayer.status === MediaPlayer.Loading || mediaPlayer.status === MediaPlayer.Buffering || mediaPlayer.status === MediaPlayer.Stalled) progressCircle.visible = true;
            else if (mediaPlayer.status === MediaPlayer.EndOfMedia) videoPoster.showControls();
            else  { progressCircle.visible = false; }
            if (metaData.title) dPage.title = metaData.title
        }
        onError: {
            // Just a little help
//            MediaPlayer.NoError - there is no current error.
//            MediaPlayer.ResourceError - the video cannot be played due to a problem allocating resources.
//            MediaPlayer.FormatError - the video format is not supported.
//            MediaPlayer.NetworkError - the video cannot be played due to network issues.
//            MediaPlayer.AccessDenied - the video cannot be played due to insufficient permissions.
//            MediaPlayer.ServiceMissing - the video cannot be played because the media service could not be instantiated.
            if (error == MediaPlayer.ResourceError) errorTxt.text = "Ressource Error";
            else if (error == MediaPlayer.FormatError) errorTxt.text = "Format Error";
            else if (error == MediaPlayer.NetworkError) errorTxt.text = "Network Error";
            else if (error == MediaPlayer.AccessDenied) errorTxt.text = "Access Denied Error";
            else if (error == MediaPlayer.ServiceMissing) errorTxt.text = "Media Service Missing Error";
            //errorTxt.text = error;
            // Prepare user friendly advise on error
            errorDetail.text = errorString;
            if (error == MediaPlayer.ResourceError) errorDetail.text += qsTr("\nThe video cannot be played due to a problem allocating resources.\n\
On Youtube Videos please make sure to be logged in. Some videos might be geoblocked or require you to be logged into youtube.")
            else if (error == MediaPlayer.FormatError) errorDetail.text += qsTr("\nThe audio and or video format is not supported.")
            else if (error == MediaPlayer.NetworkError) errorDetail.text += qsTr("\nThe video cannot be played due to network issues.")
            else if (error == MediaPlayer.AccessDenied) errorDetail.text += qsTr("\nThe video cannot be played due to insufficient permissions.")
            else if (error == MediaPlayer.ServiceMissing) errorDetail.text += qsTr("\nThe video cannot be played because the media service could not be instantiated.")
            errorBox.visible = true;
            /* Avoid MediaPlayer undefined behavior */
            stop();
        }
        onBufferProgressChanged: {
            if (bufferProgress == 1.0 && isNewSource) {
                isNewSource = false
                play()
            } else if(isNewSource) pause()
        }
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_Space) videoPauseTrigger();
        if (event.key == Qt.Key_Left && mediaPlayer.seekable) {
            mediaPlayer.seek(mediaPlayer.position - 5000)
        }
        if (event.key == Qt.Key_Right && mediaPlayer.seekable) {
            mediaPlayer.seek(mediaPlayer.position + 5000)
        }
    }

    CoverActionList {
        id: coverAction
        enabled: liveView

        //        CoverAction {
        //            iconSource: "image://theme/icon-cover-next"
        //        }

        CoverAction {
            iconSource: {
                if (videoPoster.player.playbackState === MediaPlayer.PlayingState) return "image://theme/icon-cover-pause"
                else return "image://theme/icon-cover-play"
            }
            onTriggered: {
                //console.debug("Pause triggered");
                videoPauseTrigger();
                if (!showTimeAndTitle.running) showTimeAndTitle.start();
                else showTimeAndTitle.count = 0;
                videoPoster.hideControls();
            }
        }
    }
}
