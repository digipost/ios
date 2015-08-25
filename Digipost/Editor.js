

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
    DigipostEditor.addStyleIfPresentInSelection(styling, "h1");
    return styling;
}

DigipostEditor.addStyleIfPresentInSelection = function(arrayToAddTo, styleName) {
    if (DigipostEditor.selectionHasStyle(styleName)) {
        arrayToAddTo.push(styleName);
    }
}

/**
 *  Asks the currently selected text if it has a style
 *
 *  @param styleName the style to ask for
 *
 *  @return bool indicating if the currently selected text has the style or not
 */
DigipostEditor.selectionHasStyle = function(styleName) {

    var currentSelectedElement = DigipostEditor.isElement();

    console.log(currentSelectedElement);

    if($(currentSelectedElement).is(styleName)){
        return true;
    }

    return document.queryCommandState(styleName);

}

 /**
 *  Returns the node currently selected, if its a text node
 *
 *  @return Node of the element currently selected
 */
DigipostEditor.isElement = function() {
    var range = window.getSelection().getRangeAt(0);
    if (range) {
        container = range.commonAncestorContainer;
        if (container) {
            if (container.nodeType == 3) {
                return container.parentNode
            } else {
                return container
            }
        }
    }
    return ""
}

