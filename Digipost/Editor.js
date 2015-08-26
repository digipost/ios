
var DigipostEditor = {};

//// Textalignment
var alignmentEnum = {
    left: "left",
    right: "right",
    center: "center"
};

var TextAlignment = function (alignment) {
    this.alignment = alignment;
};

TextAlignment.prototype.stringValue = function() {
    return "align-" + this.alignment;
};

TextAlignment.allAlignments = function() {
    var alignments = []
    for(var key in alignmentEnum) {
        var value = alignmentEnum[key];
        alignments.push("align-" + value);
    }
    return alignments;
};

// returns an array with style strings to native app.
// all values not present are non-active
//
// Example output:
// { "style: : ["Bold", "Italic"] }

document.addEventListener("selectionchange", function() {
                          var style = DigipostEditor.currentStyling();
                          var parentNode = window.getSelection().focusNode.parentNode;

                          var classes = parentNode.classList

                          console.log(classes[0]);

                          var returnDictionary = {
                          "style" : style,
                          "classes" : classes
                          };



                          var jsonString = JSON.stringify(returnDictionary);
                          // observe is a keyword the native code listens for, it triggers a callback in the app.
                          window.webkit.messageHandlers.observe.postMessage(jsonString);

                          });


// returns a comma separated list of the styling in the current selection
DigipostEditor.currentStyling = function(e) {
    var styling = [];
    DigipostEditor.addStyleIfPresentInSelection(styling, "Bold");
    DigipostEditor.addStyleIfPresentInSelection(styling, "Italic");
    DigipostEditor.addStyleIfPresentInSelection(styling, "h1");
    DigipostEditor.addStyleIfPresentInSelection(styling, "h2");
    DigipostEditor.addStyleIfPresentInSelection(styling, "p");

    // group that does not show up in ordinary checks for styling,
    // TOOD search for classes on current nodes instead
    DigipostEditor.addStyleIfPresentInSelection(styling, "align-left");
    DigipostEditor.addStyleIfPresentInSelection(styling, "align-center");
    DigipostEditor.addStyleIfPresentInSelection(styling, "align-right");

    return styling;
}

DigipostEditor.addStyleIfPresentInSelection = function(arrayToAddTo, styleName) {
    if (DigipostEditor.selectionHasStyle(styleName)) {
        arrayToAddTo.push(styleName);
    }
}

DigipostEditor.setAlignment = function(anAlignment) {
    var parentNode = window.getSelection().focusNode.parentNode;
    var allAlignments = TextAlignment.allAlignments();

    for (index in allAlignments) {
        $(parentNode).removeClass(allAlignments[index]);
    }

    $(parentNode).addClass(anAlignment);
}

DigipostEditor.setClassNamedForSelectedNode = function(cssClass) {
    var parentNode = window.getSelection().focusNode.parentNode;
    
    $(parentNode).addClass(cssClass);
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

