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
    src/myclass.cpp

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
    qml/pages/SearchEngineDialog.qml

RESOURCES += \
    qrc.qrc

HEADERS += \
    src/myclass.h

