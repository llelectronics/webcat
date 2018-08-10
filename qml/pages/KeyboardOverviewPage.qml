import QtQuick 2.2
import Sailfish.Silica 1.0
import "helper/browserComponents"

Page {
    id: keyboardPage
    allowedOrientations: mainWindow.orient
    property bool isBB10: true
    KeyboardCommands {
        id: keyboardCommands
        isBB10: parent.isBB10
    }
    ListModel {
        id: currentShortcutsModel
    }
    function readCommands(){
        /* group current keys by method */
        var tmpObj = {};
        var commandEntry, tmpKey;
        for(var keySettingsIndex = 0; keySettingsIndex < keyboardCommands.keyboardSettings.length; keySettingsIndex++) {
            commandEntry = keyboardCommands.keyboardSettings[keySettingsIndex];
            tmpKey = commandEntry.methods.join('|');
            tmpObj[tmpKey] = tmpObj[tmpKey] || {
                keys:[],
                displayed: false,
                methods: commandEntry.methods,
                descr: commandEntry.methods.map(function(methodName){
                    return keyboardCommands.keyCommandsOverview[methodName].text
                }).join('<br>')
            }
            tmpObj[tmpKey].keys.push({ key: commandEntry.key, modifiers: commandEntry.modifiers, combination: commandEntry.readableKeys.map(function(readableKey){return {key: readableKey};})})
            if(commandEntry.readableKeys && commandEntry.readableKeys.length > 0) {
                tmpObj[tmpKey].displayed = true;
            }
        }
        /* fill model */
        var tmpObjKeys = Object.keys(tmpObj);
        currentShortcutsModel.clear();
        for(var i = 0; i<tmpObjKeys.length;i++) {
            currentShortcutsModel.append(tmpObj[tmpObjKeys[i]]);
        }
    }
    Connections {
        target: keyboardCommands
        onStateChanged: readCommands()
    }
    Item {
        id: previewKeyHandlerItem
        anchors.fill: parent
        focus: true
        signal keysPressed(int key, int modifiers)
        Keys.onPressed: {
            previewKeyHandlerItem.keysPressed(event.key, event.modifiers)
        }
    }



    PageHeader {
        id: pageHeader
        title: qsTr('Current Keyboard Shortcuts')
        description: ''
        extraContent.height: headerLabel.height
        anchors.bottomMargin: headerLabel.height
    }
    Label {
        id: headerLabel
        anchors.top: pageHeader.bottom
        width: parent.width - Theme.horizontalPageMargin * 2
        x: Theme.horizontalPageMargin
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignRight
        color: Theme.secondaryHighlightColor
        text: keyboardPage.isBB10
              ? qsTr('You have selected BB10 (Blackberry 10) compatible keyboard shortcuts. Take a look at the list below to see what they are or try them out.')
              : qsTr('You have selected keyboard shortcuts which mimic some current popular browsers. Take a look at the list below to see what they are or try them out.')
    }
    SilicaListView {
        id: currentShortcutsList
        clip: true
        width: parent.width
        anchors.top: headerLabel.bottom
        anchors.bottom: parent.bottom
        model: currentShortcutsModel
        delegate: Item {
            id: keyCommandItem
            width: keyboardPage.width
            height: visible ? keyCommandColumn.height : 0

            visible: displayed
            Rectangle {
                anchors.fill: parent
                color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                opacity: combinationHighlightTimer.running ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 300 }
                }
            }
            Column {
                id: keyCommandColumn
                width: keyboardPage.width
                property color currentColor: combinationHighlightTimer.running ? Theme.primaryColor : Theme.highlightColor
                Behavior on currentColor {
                    ColorAnimation { duration: 300 }
                }
                Timer {
                    id: combinationHighlightTimer
                    interval: 1000
                    onRunningChanged: {
                        if(running){
                            currentShortcutsList.positionViewAtIndex(index, ListView.Visible)
                        }
                    }
                }

                Row {
                    id: keyCombinationRow
                    width: parent.width - Theme.horizontalPageMargin * 2
                    x: Theme.horizontalPageMargin
                    height: Math.max(keyColumn.height, commandLabel.height) + Theme.paddingMedium * 2

                    Column {
                        id: keyColumn
                        width: Theme.itemSizeExtraLarge * 2
                        spacing: Theme.paddingMedium
                        y: Theme.paddingMedium

                        Repeater {
                            model: keys
                            delegate: Flow {
                                width: keyColumn.width

                                property int _key: key
                                property int _modifiers: modifiers
                                Component.onCompleted: {

                                    previewKeyHandlerItem.keysPressed.connect(function(key, modifiers){
                                        if(key === _key && modifiers === _modifiers && keyCommandColumn.visible) {
                                            combinationHighlightTimer.start()
                                        }
                                    })

                                }
                                Repeater {
                                    model: combination
                                    delegate: Item {


                                        width: plusLabel.width + keyLabel.width
                                        height: keyLabel.height
                                        Label {
                                            id: plusLabel
                                            text: '+'
                                            visible: index > 0
                                            width: visible ? implicitWidth : 0
                                            horizontalAlignment: Text.AlignHCenter
                                            color: keyCommandColumn.currentColor
                                            anchors.left: parent.left
                                            anchors.verticalCenter: keyLabel.verticalCenter
                                        }
                                        Rectangle {
                                            color: 'transparent'
                                            border.color: keyCommandColumn.currentColor
                                            border.width: 2
                                            anchors.fill: keyLabel
                                            radius: Theme.paddingSmall
                                        }
                                        Label {
                                            id: keyLabel
                                            text: ' '+key+' '
                                            horizontalAlignment: Text.AlignHCenter
                                            color: keyCommandColumn.currentColor
                                            anchors.left: plusLabel.right
                                            anchors.top: parent.top
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Label {
                        id: commandLabel
                        color: keyCommandColumn.currentColor
                        width: parent.width - keyColumn.width
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: descr
                    }
                }
                Separator {
                    width: parent.width
                }
            }
        }
    }
    Component.onCompleted: readCommands()
}
