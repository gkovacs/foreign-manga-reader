// Generated by IcedCoffeeScript 1.3.3f
(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  chrome.extension.onMessage.addListener(function(request, sender, sendResponse) {
    console.log('got request in background page!');
    if (request.takeScreenshot != null) {
      chrome.tabs.captureVisibleTab(null, {
        'format': 'png'
      }, sendResponse);
      return true;
    }
  });

}).call(this);
