

document.addEventListener("selectionchange", function() {
                          var selection = window.getSelection() + "";

                          if(document.queryCommandState('Bold')){

                          }
                          var style = document.getSelection().style + "style";
                          window.webkit.messageHandlers.observe.postMessage(style);

                          });
