//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import WebKit

extension WKWebView {

    func toggleKeyword(keyword: String) {
        executeCommand(keyword)
    }

    private func executeCommand(type: TextStyleModelType) {

        switch type {
        case .Paragraph, .H1:
            evaluateJavaScript("document.execCommand('formatBlock', false, '\(type.rawValue)');", completionHandler: { (response, error) -> Void in

            })
            break

        case .OrderedList, .UnorderedList:

            break
        default:
            evaluateJavaScript("document.execCommand('\(type.rawValue)', false, null);", completionHandler: { (response, error) -> Void in

            })
        }
    }

    private func executeCommand(keyword : String) {
        if keyword == "h1" || keyword == "h2" || keyword == "p" {
            evaluateJavaScript("document.execCommand('formatBlock', false, '\(keyword)');", completionHandler: { (response, error) -> Void in

            })
        } else if keyword == "align-left" || keyword == "align-right" || keyword == "align-center" {
            evaluateJavaScript("DigipostEditor.setAlignment('\(keyword)');", completionHandler: { (response, error) -> Void in
                self.evaluateJavaScript("DigipostEditor.reportBackCurrentStyling();", completionHandler: { (response, error) -> Void in

                })
            })
        } else {
            evaluateJavaScript("document.execCommand('\(keyword)', false, null);", completionHandler: { (response, error) -> Void in

            })
        }
    }

    func startGettingBodyInnerHTML() {
        evaluateJavaScript("DigipostEditor.bodyInnerHTML();", completionHandler: { (response, error) -> Void in

        })
    }

    func insertImageWithBase64Data( base64: String) {
        evaluateJavaScript("DigipostEditor.appendImageFromBase64Data('\(base64)');", completionHandler: { (response, error) -> Void in

        })
    }

    func startFocus() {
        evaluateJavaScript("DigipostEditor.becomeFirstResponder();", completionHandler: { (response, error) -> Void in

        })
    }

    func insertTextModule() {
        evaluateJavaScript("DigipostEditor.insertTextModule();", completionHandler: { (response, error) -> Void in

        })
    }

    func insertListElement(ordered: Bool) {
        evaluateJavaScript("DigipostEditor.insertListElement(\(ordered));", completionHandler: { (response, error) -> Void in

        })
    }

    func startLoadingWebViewContent(bundle: NSBundle) {
        let editorFilepath = bundle.pathForResource("Editor", ofType: "html")
        let editorJavascriptFilepath = bundle.pathForResource("Editor", ofType: "js")
        if UIDevice.currentDevice().model == "iPhone Simulator" {
            let url = NSURL(fileURLWithPath: editorFilepath!)
            let request = NSURLRequest(URL: url)
            self.loadRequest(request)
        } else {
            let editorFinalPath = loadFileIntoTempWebDirectoryForWKWebViewReading(editorFilepath!)
            loadFileIntoTempWebDirectoryForWKWebViewReading(editorJavascriptFilepath!)
            loadRequest(NSURLRequest(URL: NSURL(fileURLWithPath: editorFinalPath)))
        }
    }

    private func loadFileIntoTempWebDirectoryForWKWebViewReading(path : String) -> String! {
        let url = NSURL(string: NSTemporaryDirectory())
        let temporaryWebContentDirectoryPath = url?.URLByAppendingPathComponent("www")
        
        try! NSFileManager.defaultManager().createDirectoryAtURL(temporaryWebContentDirectoryPath!, withIntermediateDirectories: true, attributes: nil)
        let pathUrl = NSURL(fileURLWithPath: path)
        let finalPath = temporaryWebContentDirectoryPath!.URLByAppendingPathComponent(pathUrl.lastPathComponent!)
        if NSFileManager.defaultManager().fileExistsAtPath(finalPath!.absoluteString!) == false {
            try! NSFileManager.defaultManager().copyItemAtPath(path, toPath: finalPath!.absoluteString!)
        }
        
        return finalPath!.absoluteString
    }
}
