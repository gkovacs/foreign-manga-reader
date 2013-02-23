root = exports ? this

if not root.selectedLanguage?
  root.selectedLanguage = 'zh'

chrome.extension.onMessage.addListener((request, sender, sendResponse) ->
  if request['selectedLanguage']?
    root.popupEnabled = true
    initializeSelectionPopup()
    root.selectedLanguage = request['selectedLanguage']
  if request['closePopup']?
    root.popupEnabled = false
  if request['log']?
    console.log request['log']
  console.log request
)

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
  root.addSentence(root.currentText, root.selectedLanguage, $('#popupSentenceDisplay'), true)
  #positionPopup()

root.finishedInitializing = false

initializeSelectionPopup = () ->
  if root.finishedInitializing
    return
  root.finishedInitializing = true
  root.serverLocation = 'http://geza.csail.mit.edu:1357'
  if $('#popupSentenceDisplay')? and $('#popupSentenceDisplay').length > 0
    return
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
  }).css('max-height', '100px').css('maxHeight', '100px')

root.previousSelection = null

splitIntoSentences = (text) ->
  output = []
  currentSentence = []
  for c in text
    currentSentence.push c
    if '。，、。.,“”；；;"「」（）（）()[]'.indexOf(c) != -1
      output.push currentSentence.join('')
      currentSentence = []
  if currentSentence.length > 0
    output.push currentSentence.join('')
  return output

getSentenceNum = (sentenceList, offsetIdx) ->
  offsetSoFar = 0
  for sentence,idx in sentenceList
    offsetSoFar += sentence.length
    if offsetSoFar >= offsetIdx
      return idx
  return sentenceList.length - 1

root.popupEnabled = false

setInterval(() ->
  if not root.popupEnabled
    return
  currentSelectionNode = window.getSelection()
  currentSelection = currentSelectionNode.toString()
  if currentSelection? and currentSelection.length > 0 and currentSelection.length < 100
    if currentSelection == root.previousSelection
      return
    root.previousSelection = root.currentText = currentSelection
    haveNewText()
  else
    currentSelectionParent = currentSelectionNode.anchorNode
    console.log currentSelectionParent
    if not currentSelectionParent?
      return
    currentSelectionParentText = currentSelectionParent.textContent
    if not currentSelectionParentText?
      return
    sentencesInParent = splitIntoSentences(currentSelectionParentText)
    console.log sentencesInParent
    selectedSentenceIdx = getSentenceNum(sentencesInParent, currentSelectionNode.anchorOffset)
    console.log selectedSentenceIdx
    selectedSentenceText = sentencesInParent[selectedSentenceIdx]
    if selectedSentenceText != root.previousSelection
      root.previousSelection = root.currentText = selectedSentenceText
      haveNewText()
, 1000)

