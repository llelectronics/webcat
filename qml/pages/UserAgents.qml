import QtQuick 2.0

ListModel {
    id: userAgentModel
    ListElement {
        title: "Default Jolla Webkit"
        agent: "Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
    }
    ListElement {
        title: "Jolla Sailfish Browser"
        agent: "Mozilla/5.0 (Maemo; Linux; U; Jolla; Sailfish; Mobile; rv:26.0) Gecko/26.0 Firefox/26.0 SailfishBrowser/1.0 like Safari/538.1"
    }
    ListElement {
        title: "Android 2.2"
        agent: "Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"
    }
    ListElement {
        title: "Android 4.4"
        agent: "Mozilla/5.0 (Linux; Android 4.4; Nexus 4 Build/KRT16H) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36"
    }
    ListElement {
        title: "iPhone 4s"
        agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B179 Safari/7534.48.3"
    }
    ListElement {
        title: "N900"
        agent: "Mozilla/5.0 (X11; U; Linux armv7l; en-GB; rv:1.9.2b6pre) Gecko/20100318 Firefox/3.5 Maemo Browser 1.7.4.8 RX-51 N900"
    }
    ListElement {
        title: "N9"
        agent: "Mozilla/5.0 (MeeGo; NokiaN9) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
    }
    ListElement {
        title: "Fennec (Firefox Mobile) 9"
        agent: "Mozilla/5.0 (Maemo; Linux armv7l; rv:9.0) Gecko/20111216 Firefox/9.0 Fennec/9.0"
    }
    ListElement {
        title: "Internet Explorer Mobile 9"
        agent: "Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)"
    }
    ListElement {
        title: "Opera Mini 9"
        agent: "Opera/9.80 (J2ME/MIDP; Opera Mini/9 (Compatible; MSIE:9.0; iPhone; BlackBerry9700; AppleWebKit/24.746; U; en) Presto/2.5.25 Version/10.54"
    }
    ListElement {
        title: "Blackberry 10"
        agent: "Mozilla/5.0 (BB10; Kbd) AppleWebKit/537.35+ (KHTML, like Gecko) Version/10.2.0.1803 Mobile Safari/537.35+"
    }
    ListElement {
        title: "NTT Docomo Browser"
        agent: "DoCoMo/2.0 SH901iC(c100;TB;W24H12)"
    }
    ListElement {
        title: "Firefox 25.0 Desktop Version"
        agent: "Mozilla/5.0 (X11; U; Linux i686; rv:25.0) Gecko/20100101 Firefox/25.0"
    }
}
