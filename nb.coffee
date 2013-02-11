root = exports ? this

root.currentText = ''

$(document).ready(
  popupSentenceDisplay = $('''<div id="popupSentenceDisplay">dialog content is here</div>''')
  popupSentenceDisplay.dialog({
    'autoOpen': false,
    'modal': false,
    'title': 'some dialog',
    'show': 'clip',
    'hide': 'clip',
    'position': ['right', 'top'],
    'zIndex': 99,
    'width': '800px'
  })
)

haveNewText = () ->
  console.log root.currentText
  $('#popupSentenceDisplay').dialog('open')
  $('#popupSentenceDisplay').text('')
  $('.ui-dialog').css('z-index', 99)
  root.addSentence(root.currentText, 'zh', $('#popupSentenceDisplay'))

setInterval(() ->
  selectedText = $('.note-body').text()
  if selectedText.indexOf('http://geza') != -1
    selectedText = selectedText[...selectedText.indexOf('http://geza')]
  parenIndexes = (selectedText.indexOf(x) for x in ')）' when selectedText.indexOf(x) != -1)
  if parenIndexes.length > 0
    parenIndex = Math.min.apply(Math, parenIndexes)
    lineNum = selectedText[...parenIndex].trim()
    if not isNaN(lineNum)
      selectedText = selectedText[parenIndex+1..]
  if selectedText != root.currentText
    root.currentText = selectedText
    haveNewText()
, 1000)
