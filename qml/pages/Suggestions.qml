import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: suggestions

    property alias model: listview.model
    property alias count: listview.count
    property alias contentHeight: listview.contentHeight

    signal selected(url url)
    signal selectedMedia(string mediaTitle, string yt720p, string yt480p, string yt360p, string yt240p,string url,bool ytMedia)

    radius: 5
    //color: "white"
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#262626" }
        GradientStop { position: 0.85; color: "#1F1F1F"}
    }
    border {
        color: Theme.secondaryHighlightColor
        width: 1
    }

    clip: true

    SilicaListView {
        id: listview

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: parent.height

        delegate: BackgroundItem {
            // Not using ListItem.Subtitled because it’s not themable,
            // and we want the subText to be on one line only.

            property alias text: label.text

            Item  {
                id: middleVisuals
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                height: childrenRect.height + label.anchors.topMargin

                Label {
                    id: label
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    elide: Text.ElideRight
                    color: "white"
                    text: {
                        if (mediaTitle) return mediaTitle
                        else return url
                    }
                }
            }

            onClicked: {
                if (mediaTitle) suggestions.selectedMedia(mediaTitle,yt720p,yt480p,yt360p,yt240p,url,ytMedia)
                else suggestions.selected(url,ytMedia)
            }

        }
    }
}
