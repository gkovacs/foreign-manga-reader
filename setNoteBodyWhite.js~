noteBodyOpacity = $('div.selection.selected').css('opacity')
$('div.selection.selected').css('opacity', 0.0)
console.log(noteBodyOpacity)

drawableSelectionOpacity = $('div.ui-drawable-selection').css('opacity')
$('div.ui-drawable-selection').css('opacity', 0.0)

screenshotCoordinates = {
  'left': $('div.selection.selected').offset().left,
  'top': $('div.selection.selected').offset().top,
  'width': $('div.selection.selected').width(),
  'height': $('div.selection.selected').height()
}

chrome.extension.sendMessage({"screenshotCoordinates": screenshotCoordinates})

