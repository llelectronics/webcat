# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-webcat

CONFIG += sailfishapp

SOURCES += src/harbour-webcat.cpp \
    src/myclass.cpp \
    src/DownloadManager.cpp \
    src/folderlistmodel/qquickfolderlistmodel.cpp \
    src/folderlistmodel/fileinfothread.cpp \
    src/transferengine/transferengine.cpp \
    src/transferengine/transfermethodinfo.cpp \
    src/transferengine/transfermethodmodel.cpp \
    src/dbus/webcatadaptor.cpp \
    src/dbus/webcatinterface.cpp \
    src/proxymanager.cpp

OTHER_FILES += qml/harbour-webcat.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    rpm/harbour-webcat.spec \
    rpm/harbour-webcat.yaml \
    harbour-webcat.desktop \
    qml/pages/AboutPage.qml \
    qml/pages/CreditsModel.qml \
    qml/pages/SelectUrl.qml \
    qml/pages/helper/userscript.js \
    qml/pages/helper/db.js \
    qml/pages/PopOver.qml \
    qml/pages/AddBookmark.qml \
    qml/pages/UserAgentDialog.qml \
    qml/pages/helper/tabhelper.js \
    qml/pages/SettingsPage.qml \
    qml/pages/FancyScroller.qml \
    qml/pages/DropShadow.qml \
    qml/pages/helper/FastGlow.qml \
    qml/pages/helper/GaussianGlow.qml \
    qml/pages/helper/SourceProxy.qml \
    qml/pages/helper/GaussianDirectionalBlur.qml \
    qml/pages/helper/jsmime.js \
    qml/pages/UserAgents.qml \
    qml/pages/SearchEngines.qml \
    qml/pages/SearchEngineDialog.qml \
    qml/pages/Suggestions.qml \
    qml/pages/ConfirmDialog.qml \
    qml/pages/AuthenticationDialog.qml \
    qml/pages/DownloadManager.qml \
    qml/pages/helper/yt.js \
    qml/pages/Selection.qml \
    qml/pages/SelectionHandle.qml \
    qml/pages/img/multi_selection_handle.png \
    qml/pages/SelectionEditPage.qml \
    qml/pages/helper/readability.js \
    qml/pages/HistoryPage.qml \
    translations/harbour-webcat.ts \
    translations/harbour-webcat-de.ts \
    translations/harbour-webcat-zh_CN.ts \
    translations/harbour-webcat-nl_NL.ts \
    translations/harbour-webcat-it.ts \
    translations/harbour-webcat-cs.ts \
    qml/pages/InfoBanner.qml \
    qml/pages/helper/devicePixelRatioHack.js \
    qml/pages/helper/mediaDetect.js \
    qml/pages/helper/adblock.css \
    qml/pages/OpenDialog.qml \
    qml/pages/VideoPlayer.qml \
    qml/pages/helper/VideoPoster.qml \
    qml/pages/ScreenBlank.qml \
    qml/pages/helper/ContextMenu.qml \
    qml/pages/helper/videoPlayerComponents/FastGlow.qml \
    qml/pages/helper/videoPlayerComponents/GaussianDirectionalBlur.qml \
    qml/pages/helper/videoPlayerComponents/GaussianGlow.qml \
    qml/pages/helper/videoPlayerComponents/SourceProxy.qml \
    qml/pages/helper/videoPlayerComponents/VideoPoster.qml \
    qml/pages/helper/browserComponents/ShareContextMenu.qml \
    qml/pages/helper/browserComponents/TabList.qml \
    org.harbour.webcat.service \
    open-url-webcat.desktop

RESOURCES += \
    qrc.qrc

HEADERS += \
    src/myclass.h \
    src/DownloadManager.hpp \
    src/folderlistmodel/qquickfolderlistmodel.h \
    src/folderlistmodel/fileproperty_p.h \
    src/folderlistmodel/fileinfothread_p.h \
    src/fmhelper.hpp \
    src/videohelper.hpp \
    src/transferengine/transferengine.h \
    src/transferengine/transfermethodinfo.h \
    src/transferengine/transfermethodmodel.h \
    src/dbus/webcatadaptor.h \
    src/dbus/webcatinterface.h \
    src/proxymanager.h \
    src/cookiemanager.hpp

QT += network

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

TRANSLATIONS += translations/harbour-webcat-de.ts \
        translations/harbour-webcat-zh_CN.ts \
        translations/harbour-webcat-cs.ts \
        translations/harbour-webcat-it.ts \
        translations/harbour-webcat-nl_NL.ts \
        translations/harbour-webcat-es.ts \
        translations/harbour-webcat-ru.ts \
        translations/harbour-webcat-fr.ts \
        translations/harbour-webcat-ca.ts \
        translations/harbour-webcat-fi.ts \
        translations/harbour-webcat-sv.ts \
        translations/harbour-webcat-pl.ts


# Hmm... not allowed for now I guess
#PKGCONFIG += nemotransferengine-qt5
QT += dbus

dbus.files = org.harbour.webcat.service
dbus.path = /usr/share/harbour-webcat

opendesktopfile.files = open-url-webcat.desktop
opendesktopfile.path = /usr/share/harbour-webcat

QT += sql

INSTALLS += dbus opendesktopfile

DISTFILES += \
    qml/pages/VideoPlayerComponent.qml \
    qml/pages/helper/browserComponents/ytQualityChooserContextMenu.qml \
    qml/pages/ProxySettingsPage.qml \
    qml/pages/BackupPage.qml \
    translations/harbour-webcat-ca.ts \
    translations/harbour-webcat-es.ts \
    translations/harbour-webcat-fr.ts \
    translations/harbour-webcat-ru.ts \
    qml/pages/helper/es6-collections.min.js \
    qml/pages/helper/canvg.min.js \
    qml/pages/SplitWeb.qml \
    qml/pages/helper/otherComponents/SectionHeader.qml \
    translations/harbour-webcat-sv.ts \
    qml/pages/helper/otherComponents/MenuPopup.qml \
    qml/pages/helper/videoPlayerComponents/OpenURLPage.qml \
    qml/pages/CookiePage.qml \
    qml/pages/helper/browserComponents/Toolbar.qml \
    qml/pages/helper/browserComponents/ExtraToolbar.qml \
    translations/harbour-webcat-pl.ts \
    qml/pages/img/graphic-diagonal-line-texture.png \
    qml/pages/helper/browserComponents/MediaDownloadRec.qml \
    qml/pages/helper/browserComponents/TabBar.qml \
    qml/pages/helper/browserComponents/LinkContextMenu.qml \
    qml/pages/helper/otherComponents/TabBar.qml \
    qml/pages/helper/nightmode.css \
    qml/pages/helper/otherComponents/BookmarkList.qml \
    qml/pages/helper/fmComponents/FileProperties.qml \
    qml/pages/helper/fmComponents/RenameDialog.qml \
    qml/pages/helper/fmComponents/CreateDirDialog.qml \
    qml/pages/helper/fmComponents/PermissionDialog.qml \
    qml/pages/helper/fmComponents/LetterSwitch.qml \
    qml/pages/helper/fmComponents/PlacesPage.qml \
    qml/pages/helper/fmComponents/DirEntryDelegate.qml \
    qml/pages/img/sdcard.png \
    qml/pages/img/fileman.png

include(src/sortFilterProxyModel/SortFilterProxyModel.pri)
