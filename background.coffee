root = exports ? this

chrome.extension.onMessage.addListener((request, sender, sendResponse) ->
  console.log 'got request in background page!'
  if request.screenshotCoordinates?
    console.log "got screenshot coordinates"
    captureScreenshot(request.screenshotCoordinates)
  if request.takeScreenshot?
    chrome.tabs.captureVisibleTab(null, {'format': 'png'}, sendResponse)
    return true
)

sendMessage = root.sendMessage = (message) ->
  console.log 'sending message:'
  console.log message
  chrome.tabs.getSelected(null, (tab) ->
    chrome.tabs.sendMessage(tab.id, message)
  )

captureScreenshot = root.captureScreenshot = (screenshotCoordinates) ->
  console.log "capturing screenshot"
  sendMessage {'log': 'captureScreenshot did stuff!'}
  chrome.tabs.captureVisibleTab(null, {'format': 'png'}, (screenshotData) ->
    #console.log screenshotData
    console.log "cropping screenshot"
    cropBase64Image(screenshotData, screenshotCoordinates, (croppedImage) ->
      console.log "printing result of crop"
      console.log croppedImage
      sendMessage({'screenshotResult': croppedImage})
    )
    chrome.tabs.executeScript(null, {'file': 'setNoteBodyBackToNormal.js'})
  )

cropBase64Image = (imgData, screenshotCoordinates, callback) ->
  canvas = document.createElement('canvas')
  canvas.width = screenshotCoordinates.width
  canvas.height = screenshotCoordinates.height
  context = canvas.getContext('2d')
  imageObj = new Image()
  imageObj.width = screenshotCoordinates.width
  imageObj.heigth = screenshotCoordinates.height
  imageObj.onload = () ->
    context.drawImage(
      imageObj,
      screenshotCoordinates.left,
      screenshotCoordinates.top,
      screenshotCoordinates.width,
      screenshotCoordinates.height,
      0,
      0,
      screenshotCoordinates.width,
      screenshotCoordinates.height
    )
    callback(context.canvas.toDataURL("image/png"))
  imageObj.src = imgData

