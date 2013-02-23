root = exports ? this

chrome.extension.onMessage.addListener((request, sender, sendResponse) ->
  console.log 'got request in background page!'
  if request.takeScreenshot?
    chrome.tabs.captureVisibleTab(null, {'format': 'png'}, sendResponse)
    return true
)


