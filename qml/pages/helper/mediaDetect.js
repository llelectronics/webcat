// Hmm... TODO: Need to get that out of here so it can be used from userscripts.js and mediaDetect.js
function getImgFullUri(uri) {
//    if ((uri.slice(0, 7) === 'http://') ||
//        (uri.slice(0, 8) === 'https://') ||
//        (uri.slice(0, 7) === 'file://')) {
//        return uri;
//    } else if (uri.slice(0, 1) === '/') {
//        var docuri = document.documentURI;
//        var firstcolon = docuri.indexOf('://');
//        var protocol = 'http://';
//        if (firstcolon !== -1) {
//            protocol = docuri.slice(0, firstcolon + 3);
//        }
//        return protocol + document.domain + uri;
//    } else {
//        var base = document.baseURI;
//        var lastslash = base.lastIndexOf('/');
//        if (lastslash === -1) {
//            return base + '/' + uri;
//        } else {
//            return base.slice(0, lastslash + 1) + uri;
//        }
//    }
    // Sometimes life can be made a lot easier
    var a;
    if (!a) a = document.createElement('a');
    a.href = uri;

    return a.href;
}
// ////

// Extended HTML5 Support

//document.createElement('video').constructor.prototype.canPlayType = function(type){
//    if (type.indexOf("video/mp4") != -1 || type.indexOf("video/ogg") != -1 || type.indexOf("audio/mpeg") != -1 || type.indexOf("audio/ogg") != -1 || type.indexOf("audio/mp4") != -1 ||
//            type.indexOf("application/vnd.apple.mpegURL") != -1 || type.indexOf("application/x-mpegURL") != -1 || type.indexOf("audio/mpegurl") != -1) {
//        return "probably";
//     } else
//        return "";
//};

//document.createElement('video').constructor.prototype.play = function(){
//    var data = new Object({'type': 'video'})
//    if (this.hasChildNodes()) {
//        var children = this.childNodes;
//        for (var j = 0; j < children.length; j++) {
//            if (children[j].tagName === 'SOURCE') {
//                if (children[j].hasAttribute('src')) data.video = getImgFullUri(children[j].getAttribute('src'));
//                data.play = true;
//                navigator.qt.postMessage( JSON.stringify(data) );
//                break;
//            }
//        }
//    } else {
//        data.video = getImgFullUri(this.src);
//        data.play = true;
//        navigator.qt.postMessage( JSON.stringify(data) );
//    }
//};

//document.createElement('audio').constructor.prototype.play = function(){
//    var data = new Object({'type': 'video'})
//    if (this.hasChildNodes()) {
//        var children = this.childNodes;
//        for (var j = 0; j < children.length; j++) {
//            if (children[j].tagName === 'SOURCE') {
//                if (children[j].hasAttribute('src')) data.video = getImgFullUri(children[j].getAttribute('src'));
//                data.play = true;
//                navigator.qt.postMessage( JSON.stringify(data) );
//                break;
//            }
//        }
//    } else {
//        data.video = getImgFullUri(this.src);
//        data.play = true;
//        navigator.qt.postMessage( JSON.stringify(data) );
//    }
//};

//document.createElement('video').constructor.prototype.load = function(){
//    var data = new Object({'type': 'video'})
//    if (this.hasChildNodes()) {
//        var children = this.childNodes;
//        for (var j = 0; j < children.length; j++) {
//            if (children[j].tagName === 'SOURCE') {
//                if (children[j].hasAttribute('src')) data.video = getImgFullUri(children[j].getAttribute('src'));
//                navigator.qt.postMessage( JSON.stringify(data) );
//                break;
//            }
//        }
//    } else {
//        data.video = getImgFullUri(this.src);
//        navigator.qt.postMessage( JSON.stringify(data) );
//    }
//};

//document.createElement('video').constructor.prototype.src = function(src){
//    var data = new Object({'type': 'video'})
//    data.video = getImgFullUri(src);
//    navigator.qt.postMessage( JSON.stringify(data) );
//    return getImgFullUri(src);
//};

//document.createElement('video').constructor.prototype.buffered = function(){
//    var TimeRangesObj = newObject;
//    TimeRangesObj.length = 1
//    TimeRangesObj.start = 0
//    TimeRangesObj.end = 0
//    return TimeRangesObj
//};

//document.createElement('video').constructor.prototype.seekable = function(){
//    var TimeRangesObj = newObject;
//    TimeRangesObj.length = 1
//    TimeRangesObj.start = 0
//    TimeRangesObj.end = 0
//    return TimeRangesObj
//};

//document.createElement('video').constructor.prototype.played = function(){
//    var TimeRangesObj = newObject;
//    TimeRangesObj.length = 1
//    TimeRangesObj.start = 0
//    TimeRangesObj.end = 0
//    return TimeRangesObj
//};

//document.createElement('video').constructor.prototype.mediaController = function(){
//    var MediaControllerObj = newObject;
//    MediaControllerObj.buffered = this.buffered()
//    MediaControllerObj.seekable = this.seekable()
//    MediaControllerObj.duration = "Inf"
//    MediaControllerObj.play = this.play()
//    MediaControllerObj.pause = this.pause()
//    MediaControllerObj.defaultPlaybackRate = this.defaultPlaybackRate
//    MediaControllerObj.playbackRate = this.playbackRate
//    MediaControllerObj.volume = 1.0
//    MediaControllerObj.muted = false
//    return MediaControllerObj
//};

//document.createElement('video').constructor.prototype.currentSrc = getImgFullUri(this.src)
//document.createElement('video').constructor.prototype.pause = function(){ console.debug("Do nothing"); };
//document.createElement('video').constructor.prototype.paused = false
//document.createElement('video').constructor.prototype.currentTime = 1;
//document.createElement('video').constructor.prototype.defaultPlaybackRate = 1.0
//document.createElement('video').constructor.prototype.playbackRate = 1.0
//document.createElement('video').constructor.prototype.volume = 1.0
//document.createElement('audio').constructor.prototype.volume = 1.0
//document.createElement('video').constructor.prototype.networkState = 2 // Always loading
//document.createElement('video').constructor.prototype.readyState = 4  // Always have enough data to start
//document.createElement('video').constructor.prototype.seeking = false
//document.createElement('video').constructor.prototype.autoplay = false
//document.createElement('video').constructor.prototype.ended = false
//document.createElement('video').constructor.prototype.preload = none
//document.createElement('video').constructor.prototype.controls = false
//document.createElement('video').constructor.prototype.loop = false
//document.createElement('video').constructor.prototype.muted = false
//document.createElement('video').constructor.prototype.duration = "Inf"
//document.createElement('video').constructor.prototype.startDate = new Date();

// ////////////////////////////

// Detect HTML5 Video
var delement = document.documentElement.getElementsByTagName('video');

for (var i=0; i<delement.length; i++) {
    var _vonplaying = delement[i].onplaying;
    delement[i].onplaying = function () {
        _vonplaying();
        // We need to unmute all with multiple elements
        for (var j=0; j<delement.length; j++) {
            delement[j].muted = false;
        }
    };
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
    if (delement[i].hasAttribute('muted')) {
        delement[i].muted=false;
    }
}
// ////

// Detect HTML5 Audio
var aelement = document.documentElement.getElementsByTagName('audio');

for (var i=0; i<aelement.length; i++) {
    var _onplaying = aelement[i].onplaying;
    aelement[i].onplaying = function () {
        // We need to unmute all with multiple elements
        for (var j=0; j<aelement.length; j++) {
            aelement[j].muted = false;
        }
        _onplaying();
    };
    if (aelement[i].hasChildNodes()) {
        console.debug("Has children");
        var children = aelement[i].childNodes;
        for (var j = 0; j < children.length; j++) {
            if (children[j].tagName === 'SOURCE') {
                var data = new Object({'type': 'video'})
                if (children[j].hasAttribute('src')) data.video = getImgFullUri(children[j].getAttribute('src'));
                navigator.qt.postMessage( JSON.stringify(data) );
                continue;
            }
        }
    }
    else if (aelement[i].hasAttribute('src')) {
        var data = new Object({'type': 'video'})
        data.video = getImgFullUri(aelement[i].getAttribute('src'));
        navigator.qt.postMessage( JSON.stringify(data) );
    }
    if (aelement[i].hasAttribute('muted')) {
        aelement[i].muted=false;
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

    // Detect html5 video tags hidding in iframes. This only works for iframes from the same server
    var iframeDoc = (frames[i].contentWindow || frames[i].contentDocument);
    if (iframeDoc.document) iframeDoc = iframeDoc.document;
    var iframeVideoElement = iframeDoc.getElementsByTagName('video');
    for (var k=0; k<iframeVideoElement.length; k++) {
        var _ivonplaying = iframeVideoElement[k].onplaying;
        iframeVideoElement[k].onplaying = function () {
            _ivonplaying();
            // We need to unmute all with multiple elements
            for (var j=0; j<iframeVideoElement.length; j++) {
                iframeVideoElement[j].muted = false;
            }
        };
        if (iframeVideoElement[k].hasChildNodes()) {
            console.debug("Has children");
            var children = iframeVideoElement[k].childNodes;
            for (var j = 0; j < children.length; j++) {
                if (children[j].tagName === 'SOURCE') {
                    var data = new Object({'type': 'video'})
                    if (children[j].hasAttribute('src')) data.video = getImgFullUri(children[j].getAttribute('src'));
                    navigator.qt.postMessage( JSON.stringify(data) );
                    continue;
                }
            }
        }
        else if (iframeVideoElement[k].hasAttribute('src')) {
            var data = new Object({'type': 'video'})
            data.video = getImgFullUri(iframeVideoElement[k].getAttribute('src'));
            navigator.qt.postMessage( JSON.stringify(data) );
        }
    }
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
//var fbembeddedvideos = document.querySelectorAll("div[data-store^='{\"videoID']");
//for (var i=0; i<fbembeddedvideos.length; i++) {
//    var videoobj = JSON.parse(fbembeddedvideos[i].getAttribute("data-store"));

//    if(!videoobj.hasOwnProperty("videoID") || !videoobj.hasOwnProperty("src"))
//        continue;

//    var data = new Object({'type': 'video'})
//    data.video = getImgFullUri(videoobj.src);
//    navigator.qt.postMessage( JSON.stringify(data) );
//}

// Facebook touch grabber (Thx to Dax89)
function clickGrabFb(touchevent) {
    var fbvideoelement = touchevent.target;

    if((fbvideoelement.tagName === "DIV") && (fbvideoelement.hasAttribute("data-sigil")))
        fbvideoelement = fbvideoelement.parentElement;

    if((fbvideoelement.tagName === "I") && (fbvideoelement.hasAttribute("data-sigil")))
        fbvideoelement = fbvideoelement.parentElement;

    if((fbvideoelement.tagName !== "DIV") || !fbvideoelement.hasAttribute("data-store"))
        return;

    var videoobj = JSON.parse(fbvideoelement.getAttribute("data-store"));

    if(!videoobj.hasOwnProperty("videoID") || !videoobj.hasOwnProperty("src"))
        return;

    var data = new Object({'type': 'video'})
    data.video = getImgFullUri(videoobj.src);
    data.play = true;
    navigator.qt.postMessage(JSON.stringify(data));
};

//function clickGrabVideo(touchevent) {
//    var videoelement = touchevent.target;
//    if((videoelement.tagName === "VIDEO") && (videoelement.hasAttribute("src"))) {
//        var data = new Object({'type': 'video'})
//        data.video = getImgFullUri(videoelemtn.getAttribute('src'));
//        data.play = true;
//        navigator.qt.postMessage(JSON.stringify(data));
//    }
//    else if (videoelement.tagName === "VIDEO") {
//        var children = videoelement.childNodes;
//        for (var j = 0; j < children.length; j++) {
//            if (children[j].tagName === 'SOURCE') {
//                var data = new Object({'type': 'video'})
//                if (children[j].hasAttribute('src')) data.video = getImgFullUri(children[j].getAttribute('src'));
//                data.play = true
//                navigator.qt.postMessage( JSON.stringify(data) );
//                break;
//            }
//        }
//    }

//}

if(document.location.hostname === "www.facebook.com" || document.location.hostname === "m.facebook.com")
    document.addEventListener("touchend",  clickGrabFb, true);
//else
//    document.addEventListener("touchend", clickGrabVideo, true);
