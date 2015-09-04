
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

window.addEventListener("load", function load(event){
                        window.removeEventListener("load", load, false); //remove listener, no longer needed
                        DigipostEditor.togglePlaceholder(true);

                        // remove placeholder first time element is clicked
                        document.getElementById("editor").onclick = function(){
                        DigipostEditor.togglePlaceholder(false);

                        document.getElementById("editor").removeEventListener("onclick", onclick, false); //remove listener, no longer needed

                        };

                        document.getElementById("editor").addEventListener("blur", function blur(event){
                                                                           var editable = document.querySelector('div[contenteditable]')
                                                                           var content = editable.innerHTML;
                                                                           content = content.replace(/<div>/g, '<p>');
                                                                           content = content.replace(/<\/div>/g, '</p>');
                                                                           editable.innerHTML = content;
                                                                           },false);
                        },false);

document.addEventListener("selectionchange", function() {
                          DigipostEditor.reportBackCurrentStyling();
                          });



// returns an array with style strings to native app.
// all values not present are non-active
//
// Example output:
// { "style: : ["Bold", "Italic"] }

DigipostEditor.reportBackCurrentStyling = function() {

    var style = DigipostEditor.currentStyling();
    var parentNode = window.getSelection().focusNode.parentNode;

    var classes = parentNode.classList

    var returnDictionary = {
        "style" : style,
        "classes" : classes
    };

    var jsonString = JSON.stringify(returnDictionary);
    // observe is a keyword the native code listens for, it triggers a callback in the app.
    window.webkit.messageHandlers.observe.postMessage(jsonString);
};

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

DigipostEditor.appendImageFromBase64Data = function(base64Data) {
    var imageHTMLObject = "<div contentEditable=\"true\" ><img src=\"data:image/png;base64," + base64Data + "\"/> <p><br></p></div>"
    var focusNode = window.getSelection().focusNode;
    if (focusNode == null) {
        $("div").last().after(imageHTMLObject);
    } else {
        var parentNode = window.getSelection().focusNode.parentNode;
        $(parentNode).after(imageHTMLObject);
    }
}

DigipostEditor.togglePlaceholder = function (shouldShow) {
    var placeHolderText = "<p>Skriv her...</p>";
    if (shouldShow) {
        console.log("should show");
        document.getElementById("editor").innerHTML = placeHolderText;
    } else {
        var existingText = document.getElementById("editor").innerHTML;
        if (existingText == placeHolderText) {
            document.getElementById("editor").innerHTML = "<p> </p>";
        }
    }
}

DigipostEditor.bodyInnerHTML = function () {
    var bodyInnerHTML = document.body.innerHTML;
    var returnDictionary = {
        "bodyInnerHTML" : bodyInnerHTML
    };

    var jsonString = JSON.stringify(returnDictionary);
    // observe is a keyword the native code listens for, it triggers a callback in the app.
    window.webkit.messageHandlers.observe.postMessage(jsonString);
}
