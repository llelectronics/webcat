import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.webcat.FolderListModel 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    property bool multiSelect: false
    property bool selectMode: false
    property string path

    property QtObject dataContainer

    signal fileOpen(string path);

    onPathChanged: {
        openFile(path);
    }

    function openFile(path) {
        if (_fm.isFile(path)) {
            var tmppath = findBaseName(path);
            var fpath = tmppath.substring(tmppath.lastIndexOf('.') + 1);
            if (fpath.indexOf('html') == 0 && dataContainer) {  // TODO: Check if this works for image files aswell
                dataContainer.url = path; // WTF this seems to work :P
                pageStack.pop();
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
        showDotAndDotDot: true
        showOnlyReadable: true
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

    SilicaListView {
        id: view
        model: fileModel
        anchors.fill: parent

        header: PageHeader {
            title: findBaseName((fileModel.folder).toString())
        }

        PullDownMenu {
            MenuItem {
                text: "Show Filesystem Root"
                onClicked: fileModel.folder = _fm.getRoot();
            }
            MenuItem {
                text: "Show Home"
                onClicked: fileModel.folder = _fm.getHome();
            }
            MenuItem {
                text: "Show Android SDCard"
                onClicked: fileModel.folder = _fm.getRoot() + "/data/sdcard";
            }
            MenuItem {
                text: "Show SDCard"
                onClicked: fileModel.folder = _fm.getRoot() + "/media/sdcard";
            }
        }

        delegate: BackgroundItem {
            id: delegate
            width: parent.width
            height: fileIcon.height + (Theme.paddingMedium * 2)
            Image
            {
                id: fileIcon
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingSmall
                anchors.verticalCenter: parent.verticalCenter
                source: fileIsDir ? "image://theme/icon-m-folder" : "image://theme/icon-m-document"
            }

            Label {
                id: fileLabel
                anchors.left: fileIcon.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.top: fileInfo.visible ? parent.top : undefined
                anchors.verticalCenter: !fileInfo.visible ? parent.verticalCenter : undefined
                text: fileName + (fileIsDir ? "/" : "")
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                width: mSelect.visible ? parent.width - (fileIcon.width + Theme.paddingLarge + Theme.paddingSmall + mSelect.width) : parent.width - (fileIcon.width + Theme.paddingLarge + Theme.paddingSmall)
                truncationMode: TruncationMode.Fade
            }
            Label {
                id: fileInfo
                visible: !fileIsDir
                anchors.left: fileIcon.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.top: fileLabel.bottom
                text: humanSize(fileSize) + ", " + fileModified
                color: Theme.secondaryColor
                width: parent.width - fileIcon.width - (Theme.paddingLarge + Theme.paddingSmall + Theme.paddingLarge)
                truncationMode: TruncationMode.Fade
            }
            Switch
            {
                id: mSelect
                visible: !fileIsDir && multiSelect
                anchors.right: parent.right
            }

            onClicked: {
                if(multiSelect)
                {
                    mSelect.checked = !mSelect.checked
                    return;
                }

                if (fileIsDir) {
                    if (fileName === "..") fileModel.folder = fileModel.parentFolder
                    else if (fileName === ".") return
                    else fileModel.folder = filePath
                } else {
                    if (!selectMode) openFile(filePath)
                    else {
                        fileOpen(filePath);
                        pageStack.pop();
                    }
                }
            }
        }
        VerticalScrollDecorator { flickable: view }
    }
}
