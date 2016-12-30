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

    func toggleKeyword(_ keyword: String) {
        executeCommand(keyword)
    }

    fileprivate func executeCommand(_ type: TextStyleModelType) {

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

    fileprivate func executeCommand(_ keyword : String) {
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

    func insertImageWithBase64Data( _ base64: String) {
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

    func insertListElement(_ ordered: Bool) {
        evaluateJavaScript("DigipostEditor.insertListElement(\(ordered));", completionHandler: { (response, error) -> Void in

        })
    }

    func startLoadingWebViewContent(_ bundle: Bundle) {
        let editorFilepath = bundle.path(forResource: "Editor", ofType: "html")
        let editorJavascriptFilepath = bundle.path(forResource: "Editor", ofType: "js")
        if UIDevice.current.model == "iPhone Simulator" {
            let url = URL(fileURLWithPath: editorFilepath!)
            let request = URLRequest(url: url)
            self.load(request)
        } else {
            let editorFinalPath = loadFileIntoTempWebDirectoryForWKWebViewReading(editorFilepath!)
            loadFileIntoTempWebDirectoryForWKWebViewReading(editorJavascriptFilepath!)
            load(URLRequest(url: URL(fileURLWithPath: editorFinalPath!)))
        }
    }

    fileprivate func loadFileIntoTempWebDirectoryForWKWebViewReading(_ path : String) -> String! {
        let url = URL(string: NSTemporaryDirectory())
        let temporaryWebContentDirectoryPath = url?.appendingPathComponent("www")
        
        try! FileManager.default.createDirectory(at: temporaryWebContentDirectoryPath!, withIntermediateDirectories: true, attributes: nil)
        let pathUrl = URL(fileURLWithPath: path)
        let finalPath = temporaryWebContentDirectoryPath!.appendingPathComponent(pathUrl.lastPathComponent)
        if FileManager.default.fileExists(atPath: finalPath.absoluteString) == false {
            try! FileManager.default.copyItem(atPath: path, toPath: finalPath.absoluteString)
        }
        
        return finalPath.absoluteString
    }
}
