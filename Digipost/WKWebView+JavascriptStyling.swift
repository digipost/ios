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

}
