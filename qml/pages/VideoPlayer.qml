import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import "helper/videoPlayerComponents"

Page {

    id: videoPlayerPage
    allowedOrientations: Orientation.All

    focus: true

    property alias dataContainer: videoComponent.dataContainer
    property alias streamUrl: videoComponent.streamUrl
    property alias streamTitle: videoComponent.streamTitle
    property alias autoplay: videoComponent.autoplay

    SilicaFlickable {
        anchors.fill: parent
        PullDownMenu {
            MenuItem {
                id: fOpen
                text: qsTr("Open File")
                onClicked: pageStack.replace(Qt.resolvedUrl("OpenDialog.qml"), { dataContainer: dataContainer })
            }
            MenuItem {
                id: uOpen
                text: qsTr("Open Stream")
                onClicked: pageStack.push(Qt.resolvedUrl("helper/videoPlayerComponents/OpenURLPage.qml"), { dataContainer: videoPlayerPage })
            }
        }

        VideoPlayerComponent {
            id: videoComponent
            anchors.fill: parent
            videoPage: true
            fullscreen: true
        }
    }
}
