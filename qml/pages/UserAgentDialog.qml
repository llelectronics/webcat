import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property QtObject dataContainer

    allowedOrientations: mainWindow.orient

    SilicaListView {
        id: userAgentComboMenu
        anchors.fill: parent
        model: userAgentModel
        header: PageHeader {
            title: "Choose User Agent"
        }
        delegate: ListItem {
            Label {
                text: title
            }
            onClicked: {
                dataContainer.uAgentTitle = title
                dataContainer.uAgent = agent
                pageStack.pop();
            }
        }
    }
}
