import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property QtObject dataContainer

    allowedOrientations: mainWindow.orient

    SilicaListView {
        id: searchEngineComboMenu
        anchors.fill: parent
        model: searchEngineModel
        header: PageHeader {
            title: qsTr("Choose Search Engine")
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
