import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property QtObject dataContainer

    allowedOrientations: Orientation.All

    SilicaListView {
        id: searchEngineComboMenu
        anchors.fill: parent
        model: searchEngineModel
        header: PageHeader {
            title: "Choose Search Engine"
        }
        delegate: ListItem {
            Label {
                text: title
            }
            onClicked: {
                dataContainer.searchEngineTitle = title
                dataContainer.searchEngineUri = uri
                pageStack.pop();
            }
        }
    }
}
