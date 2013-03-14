root = exports ? this

root.currentText = ''

positionPopup = root.positionPopup = () ->
  selectedBubble = $('.selection.selected')
  if not selectedBubble? or selectedBubble.length == 0
    return
  popupDialog = $('.ui-dialog')
  if not popupDialog? or popupDialog.length == 0
    return
  console.log 'setting offset!'
  popupDialog.offset({'left': selectedBubble.offset().left, 'top': selectedBubble.offset().top - Math.max(popupDialog.height()+10, 150)})
  #popupDialog.css('left', selectedBubble.offset().left).css('bottom', $(window).height() - selectedBubble.offset().top).css('height', '100%')

getLineNumFromText = (selectedText) ->
  parenIndexes = (selectedText.indexOf(x) for x in ')）' when selectedText.indexOf(x) != -1)
  if parenIndexes.length > 0
    parenIndex = Math.min.apply(Math, parenIndexes)
    lineNum = selectedText[...parenIndex].trim()
    if not isNaN(lineNum)
      return parseInt(lineNum)
  return -1

getCurrentDialog = () ->
  for x,i in $('.location-lens')
    if $(x).hasClass('selected')
      return i
  return -1

goToDialog = (idx) ->
  $($('.location-lens')[idx]).click()

goToNextDialog = () ->
  currentDialog = getCurrentDialog()
  if currentDialog == -1
    goToDialog(0)
  else
    goToDialog(currentDialog + 1)

goToPreviousDialog = () ->
  currentDialog = getCurrentDialog()
  if currentDialog <= 0
    goToDialog(0)
  else
    goToDialog(currentDialog - 1)

trimSelectedText = (selectedText) ->
  if selectedText.indexOf('http://geza') != -1
    selectedText = selectedText[...selectedText.indexOf('http://geza')]
  parenIndexes = (selectedText.indexOf(x) for x in ')）' when selectedText.indexOf(x) != -1)
  if parenIndexes.length > 0
    parenIndex = Math.min.apply(Math, parenIndexes)
    lineNum = selectedText[...parenIndex].trim()
    if not isNaN(lineNum)
      selectedText = selectedText[parenIndex+1..]
  return selectedText.trim()

getRawTextForBubble = (bubble_id) ->
  if isNaN(parseInt(bubble_id))
    bubble_id = bubble_id.attr('id_item')
  return $('.location-lens[id_item=' + bubble_id + ']').find('.location-shortbody').text()

getTextForBubble = (bubble_id) ->
  rawtext = getRawTextForBubble(bubble_id)
  rawtext = (line for line in rawtext.split('\n') when line.indexOf('lang=') != 0 and line.indexOf('showenglish') != 0).join(' ')
  return trimSelectedText(rawtext)

$(document).ready(
  assignVariable('$', 'jQuery')
  assignVariable('callOnceObjectAvailable', callOnceObjectAvailable)
  assignVariable('getLineNumFromText', getLineNumFromText)
  assignVariable('positionPopup', positionPopup)
  assignVariable('getTextForBubble', getTextForBubble)
  assignVariable('getRawTextForBubble', getRawTextForBubble)
  assignVariable('trimSelectedText', trimSelectedText)
  #assignVariable('synthesizeSpeech', synthesizeSpeech)
  #assignVariable('getTextForBubble', exposeFunction('getTextForBubble', (textOutput) -> console.log(textOutput)))
  executeInPage(() ->
    console.log('executing in page!')
    console.log(window)
    console.log(window['NB$'])
    window.foo = () -> console.log(35)
    window.callOnceObjectAvailable('NB$', () ->
      console.log window.NB$.ui.notepaneView.prototype.options.loc_sort_fct
      window.NB$.ui.notepaneView.prototype.options.loc_sort_fct = (o1,o2) ->
        o1LineNum = getLineNumFromText(o1.body)
        o2LineNum = getLineNumFromText(o2.body)
        if o1LineNum == o2LineNum
          return o1.right - o2.right
        else
          if o1LineNum == -1 or o2LineNum == -1
            return o1.right - o2.right
          else
            return o1LineNum - o2LineNum
      console.log window.NB$.ui.notepaneView.prototype.options.loc_sort_fct
    )
    console.log('done executing in page')
  )
  $(document).keyup((e) ->
    console.log e
    focused = $(':focus')
    if focused.length > 0 and focused[0].type in ['textarea', 'input', 'text']
      return false
    if e.keyCode == 40 #or e.keyCode == 39
      goToNextDialog()
      return false
    else if e.keyCode == 38 #or e.keyCode == 37
      goToPreviousDialog()
      return false
  )
  callOnceElementAvailable('.active-view', () ->
    $('.active-view').scroll(() ->
      #console.log 'scrolling!'
      positionPopup()
    )
  )
  #callOnceElementAvailable('.perspective', () ->
  #  $('.perspective').css('height', parseInt($('.perspective').css('height').split('px').join('')) - 150)
  #  $('.perspective').css('top', parseInt($('.perspective').css('top').split('px').join('')) + 150)
  #)
  #callOnceElementAvailable('.nb-viewport', () ->
  #  $('.nb-viewport').css('height', parseInt($('.nb-viewport').css('height').split('px').join('')) - 150)
  #  $('.nb-viewport').css('top', parseInt($('.nb-viewport').css('top').split('px').join('')) + 150)
  #)
  root.serverLocation = 'http://geza.csail.mit.edu:1357'
  popupSentenceDisplay = $('''<div id="popupSentenceDisplay">dialog content is here</div>''')
  popupSentenceDisplay.dialog({
    'autoOpen': false,
    'modal': false,
    'title': '',
    #'show': 'clip',
    #'hide': 'clip',
    'position': ['left', 'top'],
    'zIndex': 99,
    'width': 'auto',
    'height': 'auto',
    #'float': 'left',
    #'width': '100%',
    'maxHeight': '100px',
    'max-height': '100px',
    'create': () ->
      $(this).css("maxHeight", '100px').css('max-height', '100px')
    'close': () ->
      audioTag = $('audio')[0]
      if audioTag?
        audioTag.pause()
  }).css('max-height', '100px').css('maxHeight', '100px')
  callOnceElementAvailable('.location-shortbody-text', () ->
    for lang in ['zh', 'ja', 'fr', 'de']
      console.log lang
      console.log $('.location-shortbody-text').text()
      if $('.location-shortbody-text').text().indexOf('lang=' + lang) != -1
        root.selectedLanguage = lang
        break
  )
)

root.selectedLanguage = 'zh'

chrome.extension.onMessage.addListener((request, sender, sendResponse) ->
  if request['selectedLanguage']?
    root.selectedLanguage = request['selectedLanguage']
  if request['screenshotResult']?
    console.log 'screenshot result'
    console.log request['screenshotResult']
  if request['executeHere']? and request['executeHere'].function? and request['executeHere'].arglist?
    root[request['executeHere'].function].apply(request['executeHere'].arglist)
  if request['log']?
    console.log request['log']
  console.log request
)

synthesizeSpeech = root.synthesizeSpeech = (sentence, lang) ->
  audioTag = $('audio')[0]
  if not audioTag
    $('body').append($('<audio>').attr('autoplay', true).attr('loop', true))
    audioTag = $('audio')[0]
  audioTag.src = 'http://geza.csail.mit.edu:1357/synthesize?sentence=' + sentence + '&lang=' + lang
  audioTag.play()

haveNewText = () ->
  console.log root.currentText
  $('#popupSentenceDisplay').dialog('open')
  $('#popupSentenceDisplay').text('')
  $('#popupSentenceDisplay').css('width', 'auto')
  $('#popupSentenceDisplay').css('height', 'auto')
  $('.selection.selected').unbind('click', haveNewText)
  $('.selection.selected').bind('click', haveNewText)
  $('.location-lens.selected').unbind('click', haveNewText)
  $('.location-lens.selected').bind('click', haveNewText)
  $('.ui-dialog').css('z-index', 99)
  $('.ui-dialog').css('width', 'auto')
  $('.ui-dialog').css('height', 'auto')
  #selectedOffset = $('.selection.selected').offset()
  #if selectedOffset?
  #  $('.ui-dialog').offset({'left': selectedOffset.left, 'top': selectedOffset.top})
  $('#popupSentenceDisplay').css('max-height', '500px')
  root.addSentence(root.currentText, root.selectedLanguage, $('#popupSentenceDisplay'), true, () ->
    positionPopup()
  )
  synthesizeSpeech(root.currentText, root.selectedLanguage)
  #positionPopup()

getOCR = (imagedata, callback) ->
  dataPrefix = 'data:image/png;base64,'
  if imagedata.indexOf(dataPrefix) == 0
    imagedata = imagedata[dataPrefix.length..]
  $.get(root.serverLocation + '/getOCR?data=' + imagedata, callback)

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

prevScreenshotCoordinates = null

setInterval(() ->
  if root.selectedLanguage not in ['zh', 'ja']
    return
  if not $('.ui-drawable-selection')? or not $('.ui-drawable-selection').offset or not $('.ui-drawable-selection').offset()?
    return
  #console.log 'something selected'
  screenshotCoordinates = {
    'left': $('.ui-drawable-selection').offset().left,
    'top': $('.ui-drawable-selection').offset().top,
    'width': $('.ui-drawable-selection').width(),
    'height': $('.ui-drawable-selection').height(),
  }
  if _.isEqual(screenshotCoordinates, prevScreenshotCoordinates)
    return
  prevScreenshotCoordinates = screenshotCoordinates
  console.log 'taking screenshot'
  console.log screenshotCoordinates
  origOpacity = $('.ui-drawable-selection').css('opacity')
  $('.ui-drawable-selection').css('opacity', 0.0).promise().done(() ->
    chrome.extension.sendMessage({'takeScreenshot': true}, (screenshotData) ->
      $('.ui-drawable-selection').css('opacity', origOpacity)
      console.log 'screenshot data!'
      cropBase64Image(screenshotData, screenshotCoordinates, (croppedImage) ->
        console.log "printing result of crop"
        console.log croppedImage
        getOCR(croppedImage, (ocrText) ->
          console.log ocrText
          noteBodyNum = 0
          noteBodySelector = $('.note-body')
          if noteBodySelector? and noteBodySelector.length > 0
            noteBodyText = noteBodySelector.text()
            noteBodyNum = getLineNumFromText(noteBodyText)
          ocrPrefix = ''
          if not isNaN(noteBodyNum)
            ocrPrefix = (parseInt(noteBodyNum) + 1) + ') '
          if $('textarea').text() == ''
            $('textarea').text(ocrPrefix + ocrText)
        )
      )
    )
  )
  #chrome.tabs.captureVisibleTab(null, {'format': 'png'}, (screenshotData) ->
  #  console.log 'screenshot captured'
  #  cropBase64Image(screenshotData, screenshotCoordinates, (croppedImage) ->
  #    console.log "printing result of crop"
  #    console.log croppedImage
  #    #sendMessage({'screenshotResult': croppedImage})
  #  )
  #)
  #chrome.extension.sendMessage({'takeScreenshot': true})
, 3000)

#setInterval(() ->
#  positionPopup()
#, 300)

setInterval(() ->
  selectedText = $('.note-body').html()
  if not selectedText?
    return
  selectedText = selectedText.split('<br>')
  selectedText = (line for line in selectedText when line.indexOf('lang=') != 0 and line.indexOf('showenglish') != 0).join(' ')
  selectedText = $('<span>').html(selectedText).text()
  selectedText = trimSelectedText(selectedText)
  if selectedText != root.currentText
    root.currentText = selectedText
    haveNewText()
, 300)

