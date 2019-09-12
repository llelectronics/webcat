import QtQuick 2.0

ListModel {
    id: searchEngineModel
    ListElement {
        title: "Google"
        uri: "https://www.google.com/search?q=%s"
    }
    ListElement {
        title: "Duck Duck Go"
        uri: "https://duckduckgo.com/?q=%s"
    }
    ListElement {
        title: "Startpage"
        uri: "https://startpage.com/do/search?query=%s"
    }
    ListElement {
        title: "MetaGer"
        uri: "https://metager.de/meta/cgi-bin/meta.ger1?ui=en&lang=en&wikiboost=on&QuickTips=off&langfilter=yes&eingabe=%s&mm=and&time=1&exalead=on&fastbot=on&yacy=on&nebel=on&atsearch=on&acoon=on&overture=on&base=on&yandex=on&onenewspage=on&dmozint=on"
    }
    ListElement {
        title: "Bing"
        uri: "https://www.bing.com/search?q=%s"
    }
    ListElement {
        title: "Wikipedia (en)"
        uri: "https://en.wikipedia.org/wiki/%s"
    }
    ListElement {
        title: "Wolfram Alpha"
        uri: "https://www.wolframalpha.com/input/?i=%s"
    }
    ListElement {
        title: "Exalead"
        uri: "https://www.exalead.com/search/web/results/?q=%s"
    }
    ListElement {
        title: "Blinkx"
        uri: "http://www.blinkx.com/search/%s"
    }
    ListElement {
        title: "Baidu"
        uri: "https://www.baidu.com/s?&wd=%s"
    }
    ListElement {
        title: "QWant"
        uri: "https://www.qwant.com/?q=%s"
    }
    ListElement {
        title: qsTr("Custom")
        uri: ""
    }
}
