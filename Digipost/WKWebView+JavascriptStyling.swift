//
//  WKWebView+JavascriptStyling.swift
//  Digipost
//
//  Created by Håkon Bogen on 18/08/15.
//  Copyright (c) 2015 Posten. All rights reserved.
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

    func insertImageWithBase64Data(var base64: String) {
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
            let request = NSURLRequest(URL: url!)
            self.loadRequest(request)
        } else {
            let editorFinalPath = loadFileIntoTempWebDirectoryForWKWebViewReading(editorFilepath!)
            loadFileIntoTempWebDirectoryForWKWebViewReading(editorJavascriptFilepath!)
            loadRequest(NSURLRequest(URL: NSURL(fileURLWithPath: editorFinalPath)!))
        }
    }

    private func loadFileIntoTempWebDirectoryForWKWebViewReading(path : String) -> String! {
        let temporaryWebContentDirectoryPath = NSTemporaryDirectory().stringByAppendingPathComponent("www")
        var error: NSError? = nil
        NSFileManager.defaultManager().createDirectoryAtPath(temporaryWebContentDirectoryPath, withIntermediateDirectories: true, attributes: nil, error: &error)
        let finalPath = temporaryWebContentDirectoryPath.stringByAppendingPathComponent(path.lastPathComponent)
        if NSFileManager.defaultManager().fileExistsAtPath(finalPath) == false {
            if NSFileManager.defaultManager().copyItemAtPath(path, toPath: finalPath, error: &error) {

            }
        }
        if error != nil {
            return nil
        }

        return finalPath
    }
}
