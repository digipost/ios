//
//  HTMLEditorViewController.swift
//  Digipost
//
//  Created by Håkon Bogen on 17/08/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import Cartography
import WebKit


class HTMLEditorViewController: UIViewController, WKScriptMessageHandler, StylePickerViewControllerDelegate {

    var webView : WKWebView!

    var stylePickerViewController : StylePickerViewController!

    var customInputView : CustomInputView!



    override func viewDidLoad() {
        super.viewDidLoad()

        var userContentController = WKUserContentController()
        var webViewConfiguration = WKWebViewConfiguration()
        userContentController.addScriptMessageHandler(self, name: "observe")
        webViewConfiguration.userContentController = userContentController

        webView = WKWebView(frame: CGRectMake(0, 0, 0, 0), configuration: webViewConfiguration)

        view.addSubview(webView)

        layout(self.view, webView) { firstView, secondView in
            secondView.left == firstView.left
            secondView.top == firstView.top + 44
            secondView.right == firstView.right
            secondView.bottom == firstView.bottom
        }

        webView.userInteractionEnabled = true

        let storyboard = UIStoryboard(name: "StylePicker", bundle: NSBundle.mainBundle())
        let stylePickerViewController : StylePickerViewController = {
            if self.stylePickerViewController == nil {
                self.stylePickerViewController = storyboard.instantiateViewControllerWithIdentifier(StylePickerViewController.storyboardIdentifier) as? StylePickerViewController
            }
            return self.stylePickerViewController!
            }()

        stylePickerViewController.delegate = self

        customInputView = CustomInputView()
        APIClient.sharedClient.stylepickerViewController = stylePickerViewController
        customInputView.setShowCustomInputViewEnabled(true, containedInScrollView: webView.scrollView)

        if let filePath = NSBundle(forClass: self.dynamicType).pathForResource("Editor", ofType: "html") {
            if let url = NSURL(fileURLWithPath: filePath) {
                let request = NSURLRequest(URL: url)
                webView.loadRequest(request)
            }
        }
    }

    func stylePickerViewControllerDidSelectStyle(stylePickerViewController : StylePickerViewController, textStyleModel : TextStyleModel, enabled: Bool) {
        webView.toggleKeyword(textStyleModel.keyword)
    }

    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let stringMessage = message.body as? String {
            let jsonData = stringMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            var error : NSError?
            if let responseDictionary = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments, error: &error) as? [NSObject : [String]] {
                if responseDictionary["style"] != nil {
                    stylePickerViewController.setKeywordsEnabled(responseDictionary["style"]!)
                }
            }
        }

        println(message.body)

    }
}

