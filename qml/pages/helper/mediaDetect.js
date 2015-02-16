// Hmm... TODO: Need to get that out of here so it can be used from userscripts.js and mediaDetect.js
function getImgFullUri(uri) {
    if ((uri.slice(0, 7) === 'http://') ||
            (uri.slice(0, 8) === 'https://') ||
            (uri.slice(0, 7) === 'file://')) {
        return uri;
    } else if (uri.slice(0, 1) === '/') {
        var docuri = document.documentURI;
        var firstcolon = docuri.indexOf('://');
        var protocol = 'http://';
        if (firstcolon !== -1) {
            protocol = docuri.slice(0, firstcolon + 3);
        }
        return protocol + document.domain + uri;
    } else {
        var base = document.baseURI;
        var lastslash = base.lastIndexOf('/');
        if (lastslash === -1) {
            return base + '/' + uri;
        } else {
            return base.slice(0, lastslash + 1) + uri;
        }
    }
}
// ////

// Detect HTML5 Video
var delement = document.documentElement.getElementsByTagName('video');

for (var i=0; i<delement.length; i++) {
    if (delement[i].hasChildNodes()) {
        console.debug("Has children");
        var children = delement[i].childNodes;
        for (var j = 0; j < children.length; j++) {
            if (children[j].tagName === 'SOURCE') {
                var data = new Object({'type': 'video'})
                if (children[j].hasAttribute('src')) data.video = getImgFullUri(children[j].getAttribute('src'));
                navigator.qt.postMessage( JSON.stringify(data) );
                break;
            }
        }
    }
    else if (delement[i].hasAttribute('src')) {
        var data = new Object({'type': 'video'})
        data.video = getImgFullUri(delement[j].getAttribute('src'));
        navigator.qt.postMessage( JSON.stringify(data) );
    }
}
// ////

// Detect embedded Youtube Video

var frames = document.documentElement.getElementsByTagName('iframe');
for (var i=0; i<frames.length; i++) {
    var isrc = frames[i].getAttribute('src');
    if (isrc.slice(0, 2) === '//') {
        isrc = "http:" + isrc
    }
    var data = new Object({'type':'iframe'});
    data.isrc = isrc;
    navigator.qt.postMessage(JSON.stringify(data));
}
