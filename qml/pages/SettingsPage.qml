import QtQuick 2.0
import Sailfish.Silica 1.0
import "helper/db.js" as DB

Page {
    id: settingsPage

    property string uAgentTitle : "Custom"
    property string uAgent: mainWindow.userAgent

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: col.height


        PullDownMenu {
            MenuItem {
                text: qsTr("Save Settings")
                onClicked: saveBtn.clicked(null);
            }
        }
        PushUpMenu {
            MenuItem {
                text: qsTr("Goto top")
                onClicked: flick.scrollToTop();
            }
        }

        Column {
            id: col
            width: parent.width
            spacing: 15
            // TODO : Maybe it can be made as convenient as AddBookmark !?
            //        function enterPress() {
            //            if (bookmarkTitle.focus == true) bookmarkUrl.focus = true
            //            else if (bookmarkUrl.focus == true) { addBtn.focus = true; bookmarkUrl.text = fixUrl(bookmarkUrl.text);}
            //            else if (addBtn.focus == true) addBtn.clicked();
            //        }
            PageHeader {
                id: head
                title: "Add Bookmark"
            }
            SectionHeader {
                text: "Appearance"
            }
            ComboBox {
                id: defaultFontCombo
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Default Font Size"
                currentIndex: 34 - parseInt(mainWindow.defaultFontSize)
                menu: ContextMenu {
                    MenuItem { text: "34"}
                    MenuItem { text: "33"}
                    MenuItem { text: "32"}
                    MenuItem { text: "31"}
                    MenuItem { text: "30"}
                    MenuItem { text: "29"}
                    MenuItem { text: "28"}
                    MenuItem { text: "27"}
                    MenuItem { text: "26"}
                    MenuItem { text: "25"}
                    MenuItem { text: "24"}
                    MenuItem { text: "23"}
                    MenuItem { text: "22"}
                    MenuItem { text: "21"}
                    MenuItem { text: "20"}
                    MenuItem { text: "19"}
                    MenuItem { text: "18"}
                    MenuItem { text: "17"}
                    MenuItem { text: "16"}
                    MenuItem { text: "15"}
                    MenuItem { text: "14"}
                    MenuItem { text: "13"}
                    MenuItem { text: "12"}
                    MenuItem { text: "11"}
                    MenuItem { text: "10"}
                    MenuItem { text: "9" }
                }
            }
            ComboBox {
                id: defaultFixedFontCombo
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Default Fixed Font Size"
                currentIndex: 34 - parseInt(mainWindow.defaultFixedFontSize)
                menu: ContextMenu {
                    MenuItem { text: "34" }
                    MenuItem { text: "33" }
                    MenuItem { text: "32" }
                    MenuItem { text: "31" }
                    MenuItem { text: "30" }
                    MenuItem { text: "29" }
                    MenuItem { text: "28" }
                    MenuItem { text: "27" }
                    MenuItem { text: "26" }
                    MenuItem { text: "25" }
                    MenuItem { text: "24" }
                    MenuItem { text: "23" }
                    MenuItem { text: "22" }
                    MenuItem { text: "21" }
                    MenuItem { text: "20" }
                    MenuItem { text: "19" }
                    MenuItem { text: "18" }
                    MenuItem { text: "17" }
                    MenuItem { text: "16" }
                    MenuItem { text: "15" }
                    MenuItem { text: "14" }
                    MenuItem { text: "13" }
                    MenuItem { text: "12" }
                    MenuItem { text: "11" }
                    MenuItem { text: "10" }
                    MenuItem { text: "9" }
                }
            }
            ComboBox {
                id: minimumFontCombo
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Minimum Font Size"
                currentIndex: 34 - parseInt(mainWindow.minimumFontSize)
                menu: ContextMenu {
                    MenuItem { text: "34" }
                    MenuItem { text: "33" }
                    MenuItem { text: "32" }
                    MenuItem { text: "31" }
                    MenuItem { text: "30" }
                    MenuItem { text: "29" }
                    MenuItem { text: "28" }
                    MenuItem { text: "27" }
                    MenuItem { text: "26" }
                    MenuItem { text: "25" }
                    MenuItem { text: "24" }
                    MenuItem { text: "23" }
                    MenuItem { text: "22" }
                    MenuItem { text: "21" }
                    MenuItem { text: "20" }
                    MenuItem { text: "19" }
                    MenuItem { text: "18" }
                    MenuItem { text: "17" }
                    MenuItem { text: "16" }
                    MenuItem { text: "15" }
                    MenuItem { text: "14" }
                    MenuItem { text: "13" }
                    MenuItem { text: "12" }
                    MenuItem { text: "11" }
                    MenuItem { text: "10" }
                    MenuItem { text: "9" }
                }
            }

            SectionHeader {
                text: "General"
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 25
                Label {
                    text: "Homepage: "
                }
                TextField {
                    id: hp
                    text: mainWindow.siteURL
                    inputMethodHints: Qt.ImhUrlCharactersOnly
                }
            }
            TextSwitch {
                id: loadImagesSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Load Images"
                checked: mainWindow.loadImages
            }
            TextSwitch {
                id: privateBrowsingSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Private Browsing"
                checked: mainWindow.privateBrowsing
            }
            SectionHeader {
                text: "Advanced"
            }
            ValueButton {
                anchors.horizontalCenter: parent.horizontalCenter
                id: userAgentCombo
                label: "User Agent:"
                value: uAgentTitle
                onClicked: pageStack.push(Qt.resolvedUrl("UserAgentDialog.qml"), {dataContainer: settingsPage});
            }
            TextField {
                id: agentString
                anchors.horizontalCenter: parent.horizontalCenter
                readOnly: true
                width: parent.width - 20
                text: uAgent
            }
            TextSwitch {
                id: dnsPrefetchSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                text: "DNS Prefetch"
                checked: mainWindow.dnsPrefetch
            }
            TextSwitch {
                id: offlineWebApplicationCacheSwitch
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Offline Web Application Cache"
                checked: mainWindow.offlineWebApplicationCache
            }
            Button {
                id: saveBtn
                text: "Save Settings"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    DB.addSetting("homepage", hp.text);
                    DB.addSetting("minimumFontSize", minimumFontCombo.value.toString());
                    DB.addSetting("defaultFontSize", defaultFontCombo.value.toString());
                    DB.addSetting("defaultFixedFontSize", defaultFixedFontCombo.value.toString());
                    DB.addSetting("loadImages", loadImagesSwitch.checked.toString());
                    DB.addSetting("privateBrowsing", privateBrowsingSwitch.checked.toString());
                    DB.addSetting("dnsPrefetch", dnsPrefetchSwitch.checked.toString());
                    DB.addSetting("userAgent", agentString.text);
                    DB.addSetting("offlineWebApplicationCache", offlineWebApplicationCacheSwitch.checked.toString());
                    DB.getSettings();
                    pageStack.pop();
                }
            }

        }
    }

}
