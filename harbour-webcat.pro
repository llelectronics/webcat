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

SOURCES += src/harbour-webcat.cpp

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
    qml/pages/SettingsPage.qml

RESOURCES += \
    qrc.qrc

