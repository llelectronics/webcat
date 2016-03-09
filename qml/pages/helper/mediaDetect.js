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

// Extended HTML5 Support

document.createElement('video').constructor.prototype.canPlayType = function(type){
    if (type.indexOf("video/mp4") != -1 || type.indexOf("video/ogg") != -1 || type.indexOf("audio/mpeg") != -1 || type.indexOf("audio/ogg") != -1 || type.indexOf("audio/mp4") != -1 ||
            type.indexOf("application/vnd.apple.mpegURL") != -1 || type.indexOf("application/x-mpegURL") != -1 || type.indexOf("audio/mpegurl") != -1)
        return true;
    else
        return false;
};

document.createElement('video').constructor.prototype.play = function(){
    var data = new Object({'type': 'video'})
    data.video = getImgFullUri(this.src);
    data.play = true;
    navigator.qt.postMessage( JSON.stringify(data) );
};

document.createElement('video').constructor.prototype.load = function(){
    var data = new Object({'type': 'video'})
    data.video = getImgFullUri(this.src);
    navigator.qt.postMessage( JSON.stringify(data) );
};

document.createElement('video').constructor.prototype.src = function(src){
    var data = new Object({'type': 'video'})
    data.video = getImgFullUri(src);
    navigator.qt.postMessage( JSON.stringify(data) );
    return src;
};

document.createElement('video').constructor.prototype.currentSrc = function(){ return this.src; };
document.createElement('video').constructor.prototype.pause = function(){ console.debug("Do nothing"); };
document.createElement('video').constructor.prototype.currentTime = function(){ return 0; };
document.createElement('video').constructor.prototype.defaultPlaybackRate = function(rate){ return rate };
document.createElement('video').constructor.prototype.readyState = function(){ return 4 }; // Always have enough data to start
document.createElement('video').constructor.prototype.seeking = function(){ return false };
document.createElement('video').constructor.prototype.autoplay = function(autoplay){ return autoplay };
document.createElement('video').constructor.prototype.ended = function(){ return false };

// ////////////////////////////

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
                continue;
            }
        }
    }
    else if (delement[i].hasAttribute('src')) {
        var data = new Object({'type': 'video'})
        data.video = getImgFullUri(delement[i].getAttribute('src'));
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

// mobilegeeks.de uses this
var frames = document.documentElement.getElementsByTagName('pagespeed_iframe');
for (var i=0; i<frames.length; i++) {
    var isrc = frames[i].getAttribute('src');
    if (isrc.slice(0, 2) === '//') {
        isrc = "http:" + isrc
    }
    var data = new Object({'type':'iframe'});
    data.isrc = isrc;
    navigator.qt.postMessage(JSON.stringify(data));
}

// facebook.com uses this and detecting html5 video only does somehow not work
// improved version by Dax89 (Thanks for that)
var fbembeddedvideos = document.querySelectorAll("div[data-store^='{\"videoID']");
for (var i=0; i<fbembeddedvideos.length; i++) {
    var videoobj = JSON.parse(fbembeddedvideos[i].getAttribute("data-store"));

    if(!videoobj.hasOwnProperty("videoID") || !videoobj.hasOwnProperty("src"))
        continue;

    var data = new Object({'type': 'video'})
    data.video = getImgFullUri(videoobj.src);
    navigator.qt.postMessage( JSON.stringify(data) );
}
