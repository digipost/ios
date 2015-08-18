

// returns an array with style strings to native app.
// all values not present are non-active
//
// Example output:
// { "style: : ["Bold", "Italic"] }

document.addEventListener("selectionchange", function() {
                          var style = DigipostEditor.currentStyling();
                          var returnDictionary = { "style" : style };
                          var jsonString = JSON.stringify(returnDictionary);

                          window.webkit.messageHandlers.observe.postMessage(jsonString);

                          });


var DigipostEditor = {};

// returns a comma separated list of the styling in the current selection
DigipostEditor.currentStyling = function(e) {
    var styling = [];
    DigipostEditor.addStyleIfPresentInSelection(styling, "Bold");
    DigipostEditor.addStyleIfPresentInSelection(styling, "Italic");
    return styling;
}

DigipostEditor.addStyleIfPresentInSelection = function(arrayToAddTo, styleName) {
    if (DigipostEditor.selectionHasStyle(styleName)) {
        arrayToAddTo.push(styleName);
    }
}

DigipostEditor.selectionHasStyle = function(styleName) {
    return document.queryCommandState(styleName);
}




