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

        evaluateJavaScript("document.execCommand('\(keyword)', false, null);", completionHandler: { (response, error) -> Void in

        })

    }

}
