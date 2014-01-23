import QtQuick 2.0

ListModel {
    id: searchEngineModel
    ListElement {
        title: "Google"
        uri: "http://www.google.com/search?q=%s"
    }
    ListElement {
        title: "Duck Duck Go"
        uri: "http://duckduckgo.com/?q=%s"
    }
    ListElement {
        title: "Startpage"
        uri: "http://startpage.com/do/search?query=%s"
    }
    ListElement {
        title: "MetaGer"
        uri: "http://metager.de/meta/cgi-bin/meta.ger1?ui=en&lang=en&wikiboost=on&QuickTips=off&langfilter=yes&eingabe=%s&mm=and&time=1&exalead=on&fastbot=on&yacy=on&nebel=on&atsearch=on&acoon=on&overture=on&base=on&yandex=on&onenewspage=on&dmozint=on"
    }
    ListElement {
        title: "Bing"
        uri: "http://www.bing.com/search?q=%s"
    }
    ListElement {
        title: "Wikipedia (en)"
        uri: "http://en.wikipedia.org/wiki/%s"
    }
    ListElement {
        title: "Wolfram Alpha"
        uri: "http://www.wolframalpha.com/input/?i=%s"
    }
    ListElement {
        title: "Exalead"
        uri: "http://www.exalead.com/search/web/results/?q=%s"
    }
    ListElement {
        title: "Blinkx"
        uri: "http://www.blinkx.com/search/%s"
    }
    ListElement {
        title: "Izik"
        uri: "http://izik.com/?q=%s"
    }
    ListElement {
        title: "Custom"
        uri: ""
    }
}
