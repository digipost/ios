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


class HTMLEditorViewController: UIViewController, WKScriptMessageHandler, StylePickerViewControllerDelegate, ModuleSelectorViewControllerDelegate {

    var webView : WKWebView!

    var stylePickerViewController : StylePickerViewController!

    var customInputView : CustomInputView!
    
    @IBOutlet weak var previewButton: UIBarButtonItem!

    var currentShowingBodyInnnerHTML : String?

    var recipients = [Recipient]()

    // the selected digipost address for the mailbox that should show as sender when sending current compsing letter
    var mailboxDigipostAddress : String?


    private var isShowingCustomStylePicker : Bool = false

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
        if let filePath = NSBundle(forClass: self.dynamicType).pathForResource("Editor", ofType: "html") {
            if let url = NSURL(fileURLWithPath: filePath) {
                let request = NSURLRequest(URL: url)
                webView.loadRequest(request)
            }
        }
        setupNavBarButtonItems()
    }


    func setupNavBarButtonItems() {
        let currentRightBarButtonItem = self.navigationItem.rightBarButtonItem
        let toggleEditingStyleModeBarButtonItem = UIBarButtonItem(image: UIImage(named: "Styling")!, style: .Done, target: self, action: Selector("toggleEditingStyle"))
        let addNewModuleBarButtonItem = UIBarButtonItem(image: UIImage(named: "Add")!, style: .Done, target: self, action: Selector("didTapAddNewModuleBarButtonItem:"))
        let barButtonItems = [ currentRightBarButtonItem!, toggleEditingStyleModeBarButtonItem, addNewModuleBarButtonItem ]
        self.navigationItem.rightBarButtonItems = barButtonItems
    }

    func didTapAddNewModuleBarButtonItem(sender: UIButton) {
        performSegueWithIdentifier("presentModuleSelectorSegue", sender: self)
    }

    func toggleEditingStyle() {
        customInputView.setShowCustomInputViewEnabled(isShowingCustomStylePicker == false, containedInScrollView: webView.scrollView)
        isShowingCustomStylePicker = isShowingCustomStylePicker == false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(r: 230, g: 231, b: 233, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }

    func stylePickerViewControllerDidSelectStyle(stylePickerViewController : StylePickerViewController, textStyleModel : TextStyleModel, enabled: Bool) {
        webView.toggleKeyword(textStyleModel.keyword)
    }

    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let stringMessage = message.body as? String {
            let jsonData = stringMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            var error : NSError?
            if let responseDictionary = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments, error: &error) as? [NSObject : AnyObject] {
                if let actualBodyInnerHTML = responseDictionary["bodyInnerHTML"] as? String {
                    self.currentShowingBodyInnnerHTML = actualBodyInnerHTML
                    self.performSegueWithIdentifier("showPreviewSegue", sender: self)
                } else {
                    stylePickerViewController.setCurrentStyling(responseDictionary)
                }
            }
        }
    }

    @IBAction func didTapPreviewButton(sender: UIBarButtonItem) {
        // Todo: show spinner while loading
        self.webView.startGettingBodyInnerHTML()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let previewViewController = segue.destinationViewController as? PreviewViewController{
            previewViewController.recipients = recipients
            previewViewController.mailboxDigipostAddress = mailboxDigipostAddress
            previewViewController.currentShowingHTMLContent = currentShowingBodyInnnerHTML

        } else if let moduleSelectViewController = segue.destinationViewController  as? ModuleSelectorViewController{
            moduleSelectViewController.delegate = self
        }
    }

    func moduleSelectorViewControllerWasDismissed(moduleSelectorViewController: ModuleSelectorViewController) {

    }

    func moduleSelectorViewController(moduleSelectorViewController: ModuleSelectorViewController, didSelectModule module: ComposerModule) {

        if let imageModule = module as? ImageComposerModule {
            webView.insertImageWithBase64Data(imageModule.image.base64Representation)
        }

        moduleSelectorViewController.dismissViewControllerAnimated(true, completion: nil)
    }

}
