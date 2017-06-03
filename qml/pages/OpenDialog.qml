import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.webcat.FolderListModel 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    property bool multiSelect: onlyFolders ? true : false
    property bool selectMode: false
    property bool onlyFolders: false
    property string path
    property variant filter: [ "*" ]

    property QtObject dataContainer

    signal fileOpen(string path);

    onPathChanged: {
        openFile(path);
    }

    function openFile(path) {
        if (_fm.isFile(path)) {

            var mime = _fm.getMime(path);
            console.debug("[OpenDialog] Detected mimetype: " + mime);
            var mimeinfo = mime.toString().split("/");

            if(mimeinfo[0] === "video")
            {
                mainWindow.openWithvPlayer(path,"");
                if (mainWindow.vPlayerExternal) {
                    mainWindow.infoBanner.showText(qsTr("Opening..."))
                }
                return;
            }
            else if ((mimeinfo[1] === "html" || mimeinfo[0] === "image")  && dataContainer) {  // TODO: Check if this works for image files aswell
                dataContainer.url = path; // WTF this seems to work :P
                pageStack.pop(dataContainer.parent, PageStackAction.Animated);
            } else {
                mainWindow.infoBanner.showText(qsTr("Opening..."));
                Qt.openUrlExternally(path);
            }
        }
    }

    FolderListModel {
        id: fileModel
        folder: path ? path: _fm.getHome()
        showDirsFirst: true
        showDotAndDotDot: false
        showOnlyReadable: true
        nameFilters: filter
    }

    function humanSize(bytes) {
        var precision = 2;
        var kilobyte = 1024;
        var megabyte = kilobyte * 1024;
        var gigabyte = megabyte * 1024;
        var terabyte = gigabyte * 1024;

        if ((bytes >= 0) && (bytes < kilobyte)) {
            return bytes + ' B';

        } else if ((bytes >= kilobyte) && (bytes < megabyte)) {
            return (bytes / kilobyte).toFixed(precision) + ' KB';

        } else if ((bytes >= megabyte) && (bytes < gigabyte)) {
            return (bytes / megabyte).toFixed(precision) + ' MB';

        } else if ((bytes >= gigabyte) && (bytes < terabyte)) {
            return (bytes / gigabyte).toFixed(precision) + ' GB';

        } else if (bytes >= terabyte) {
            return (bytes / terabyte).toFixed(precision) + ' TB';

        } else {
            return bytes + ' B';
        }
    }

    function findBaseName(url) {
        var fileName = url.substring(url.lastIndexOf('/') + 1);
        return fileName;
    }

    function findFullPath(url) {
        url = url.toString();
        var fullPath = url.substring(url.lastIndexOf('://') + 3);
        return fullPath;
    }

    SilicaListView {
        id: view
        model: fileModel
        anchors.fill: parent

        header: PageHeader {
            title: findBaseName((fileModel.folder).toString())
            description: findFullPath(fileModel.folder.toString())
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Show Filesystem Root")
                onClicked: fileModel.folder = _fm.getRoot();
            }
            MenuItem {
                text: qsTr("Show Home")
                onClicked: fileModel.folder = _fm.getHome();
            }
            MenuItem {
                text: qsTr("Show Android SDCard")
                onClicked: fileModel.folder = _fm.getRoot() + "sdcard";
            }
            MenuItem {
                text: qsTr("Show SDCard")
                onClicked: fileModel.folder = _fm.getRoot() + "media/sdcard";
            }
            MenuItem {
                id: pasteMenuEntry
                visible: { if (_fm.sourceUrl != "" && _fm.sourceUrl != undefined) return true;
                    else return false
                }
                text: qsTr("Paste") + "(" + findBaseName(_fm.sourceUrl) + ")"
                onClicked: {
                    var err = false;
                    if (_fm.moveMode) {
                        console.debug("Moving " + _fm.sourceUrl + " to " + findFullPath(fileModel.folder)+ "/" + findBaseName(_fm.sourceUrl));
                        if (!_fm.moveFile(_fm.sourceUrl,findFullPath(fileModel.folder) + "/" + findBaseName(_fm.sourceUrl))) err = true;
                    }
                    else {
                        //console.debug("Copy " + _fm.sourceUrl + " to " + findFullPath(fileModel.folder)+ "/" + findBaseName(_fm.sourceUrl));
                        if (!_fm.copyFile(_fm.sourceUrl,findFullPath(fileModel.folder) + "/" + findBaseName(_fm.sourceUrl))) err = true;
                    }
                    if (err) {
                        var message = qsTr("Error pasting file ") + _fm.sourceUrl
                        console.debug(message);
                        infoBanner.showText(message)
                    }
                    else _fm.sourceUrl = "";
                }
            }
        }

        delegate: BackgroundItem {
            id: bgdelegate
            width: parent.width
            height: menuOpen ? contextMenu.height + delegate.height : delegate.height
            property Item contextMenu
            property bool menuOpen: contextMenu != null && contextMenu.parent === bgdelegate

            function remove() {
                var removal = removalComponent.createObject(bgdelegate)
                removal.execute(delegate,qsTr("Deleting ") + fileName, function() { _fm.remove(filePath); })
            }

            function copy() {
                _fm.sourceUrl = filePath
                //console.debug(_fm.sourceUrl)
            }

            function move() {
                _fm.moveMode = true;
                copy();
            }

            ListItem {
                id: delegate

                showMenuOnPressAndHold: false
                menu: myMenu
                visible : {
                    if (onlyFolders && fileIsDir) return true
                    else if (onlyFolders) return false
                    else return true
                }

                function showContextMenu() {
                    if (!contextMenu)
                        contextMenu = myMenu.createObject(view)
                    contextMenu.show(bgdelegate)
                }

                Image
                {
                    id: fileIcon
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    source: {
                        if (fileIsDir) "image://theme/icon-m-folder"
                        else if (_fm.getMime(filePath).indexOf("video") !== -1) "image://theme/icon-m-file-video"
                        else if (_fm.getMime(filePath).indexOf("audio") !== -1) "image://theme/icon-m-file-audio"
                        else if (_fm.getMime(filePath).indexOf("image") !== -1) "image://theme/icon-m-file-image"
                        else if (_fm.getMime(filePath).indexOf("text") !== -1) "image://theme/icon-m-file-document"
                        else if (_fm.getMime(filePath).indexOf("pdf") !== -1) "image://theme/icon-m-file-pdf"
                        else if (_fm.getMime(filePath).indexOf("android") !== -1) "image://theme/icon-m-file-apk"
                        else if (_fm.getMime(filePath).indexOf("rpm") !== -1) "image://theme/icon-m-file-rpm"
                        else "image://theme/icon-m-document"
                    }
                }

                Label {
                    id: fileLabel
                    anchors.left: fileIcon.right
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.top: fileInfo.text != "" ? parent.top : undefined
                    anchors.verticalCenter: fileInfo.text == "" ? parent.verticalCenter : undefined
                    text: fileName //+ (fileIsDir ? "/" : "")
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    width: mSelect.visible ? parent.width - (fileIcon.width + Theme.paddingLarge + Theme.paddingSmall + mSelect.width) : parent.width - (fileIcon.width + Theme.paddingLarge + Theme.paddingSmall)
                    truncationMode: TruncationMode.Fade
                }
                Label {
                    id: fileInfo
                    anchors.left: fileIcon.right
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.top: fileLabel.bottom
                    text: fileIsDir ? qsTr("directory") : humanSize(fileSize) + ", " + fileModified
                    color: Theme.secondaryColor
                    width: parent.width - fileIcon.width - (Theme.paddingLarge + Theme.paddingSmall + Theme.paddingLarge)
                    truncationMode: TruncationMode.Fade
                }
                Switch {
                    id: mSelect
                    visible: fileIsDir && multiSelect && onlyFolders
                    anchors.right: parent.right
                    checked: false
                    onClicked: {
                        checked = !checked
                        fileOpen(filePath);
                        pageStack.pop();
                    }
                }

                onClicked: {
                    if(multiSelect)
                    {
                        mSelect.checked = !mSelect.checked
                        return;
                    }

                    if (fileIsDir) {
                        var anotherFM = pageStack.push(Qt.resolvedUrl("OpenDialog.qml"), {"path": filePath, "dataContainer": dataContainer, "selectMode": selectMode, "multiSelect": multiSelect});
                        anotherFM.fileOpen.connect(fileOpen)
                    } else {
                        if (!selectMode) openFile(filePath)
                        else {
                            fileOpen(filePath);
                            pageStack.pop(dataContainer.parent);
                        }
                    }
                }
                onPressAndHold: showContextMenu()
            }

            Component {
                id: removalComponent
                RemorseItem {
                    id: remorse
                    onCanceled: destroy()
                }
            }

            Component {
                id: myMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("Cut")
                        onClicked: {
                            bgdelegate.move();
                        }
                    }
                    MenuItem {
                        text: qsTr("Copy")
                        onClicked: {
                            bgdelegate.copy();
                        }
                    }
                    MenuItem {
                        text: qsTr("Delete")
                        onClicked: {
                            bgdelegate.remove();
                        }
                    }
                }
            }

        }
        VerticalScrollDecorator { flickable: view }
    }
    Connections {
        target: _fm
        onSourceUrlChanged: {
            if (_fm.sourceUrl != "" && _fm.sourceUrl != undefined) {
                pasteMenuEntry.visible = true;
            }
            else pasteMenuEntry.visible = false;
        }
    }

}
