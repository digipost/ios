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
import Cartography
import WebKit


class HTMLEditorViewController: UIViewController, WKScriptMessageHandler, StylePickerViewControllerDelegate, ModuleSelectorViewControllerDelegate {

    var webView : WKWebView!

    var stylePickerViewController : StylePickerViewController!

    var customInputView : CustomInputView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var previewButton: UIBarButtonItem!

    var currentShowingBodyInnnerHTML : String?

    var recipients = [Recipient]()

    // the selected digipost address for the mailbox that should show as sender when sending current compsing letter
    @objc var mailboxDigipostAddress : String?


    fileprivate var isShowingCustomStylePicker : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let userContentController = WKUserContentController()
        let webViewConfiguration = WKWebViewConfiguration()
        userContentController.add(self, name: "observe")
        webViewConfiguration.userContentController = userContentController

        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), configuration: webViewConfiguration)

        view.addSubview(webView)
        
        constrain(self.view, webView) { firstView, secondView in
            secondView.left == firstView.left
            secondView.right == firstView.right
            secondView.bottom == firstView.bottom
        }

        constrain(titleTextField, webView) { firstView,secondView in
            secondView.top == firstView.bottom + 5
        }

        webView.isUserInteractionEnabled = true

        let storyboard = UIStoryboard(name: "StylePicker", bundle: Bundle.main)
        let stylePickerViewController : StylePickerViewController = {
            if self.stylePickerViewController == nil {
                self.stylePickerViewController = storyboard.instantiateViewController(withIdentifier: StylePickerViewController.storyboardIdentifier) as? StylePickerViewController
            }
            return self.stylePickerViewController!
            }()

        stylePickerViewController.delegate = self

        customInputView = CustomInputView()
        APIClient.sharedClient.stylepickerViewController = stylePickerViewController
        webView.startLoadingWebViewContent(Bundle(for: type(of: self)))
        setupNavBarButtonItems()
    }

    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.webView.startFocus()
    }

    func setupNavBarButtonItems() {
        let currentRightBarButtonItem = self.navigationItem.rightBarButtonItem
        let toggleEditingStyleModeBarButtonItem = UIBarButtonItem(image: UIImage(named: "Styling")!, style: .done, target: self, action: #selector(HTMLEditorViewController.toggleEditingStyle))
        let addNewModuleBarButtonItem = UIBarButtonItem(image: UIImage(named: "Add")!, style: .done, target: self, action: #selector(HTMLEditorViewController.didTapAddNewModuleBarButtonItem(_:)))
        let barButtonItems = [ currentRightBarButtonItem!, toggleEditingStyleModeBarButtonItem, addNewModuleBarButtonItem ]
        self.navigationItem.rightBarButtonItems = barButtonItems
    }

    @objc func didTapAddNewModuleBarButtonItem(_ sender: UIButton) {
        performSegue(withIdentifier: "presentModuleSelectorSegue", sender: self)
    }

    @objc func toggleEditingStyle() {
        customInputView.setShowEnabled(isShowingCustomStylePicker == false, containedIn: webView.scrollView)
        isShowingCustomStylePicker = isShowingCustomStylePicker == false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(r: 230, g: 231, b: 233, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.black
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }

    func stylePickerViewControllerDidSelectStyle(_ stylePickerViewController : StylePickerViewController, textStyleModel : TextStyleModel, enabled: Bool) {
        webView.toggleKeyword(textStyleModel.keyword)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let stringMessage = message.body as? String {
            let jsonData = stringMessage.data(using: String.Encoding.utf8, allowLossyConversion: true)
            
            if let responseDictionary = try! JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments) as? [AnyHashable: Any] {
                if let actualBodyInnerHTML = responseDictionary["bodyInnerHTML"] as? String {
                    self.currentShowingBodyInnnerHTML = actualBodyInnerHTML
                    self.performSegue(withIdentifier: "showPreviewSegue", sender: self)
                } else {
                    stylePickerViewController.setCurrentStyling(responseDictionary)
                }
            }
        }
    }

    @IBAction func didTapPreviewButton(_ sender: UIBarButtonItem) {
        // Todo: show spinner while loading
        self.webView.startGettingBodyInnerHTML()
    }

    @IBAction func didTapCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let previewViewController = segue.destination as? PreviewViewController{
            previewViewController.recipients = recipients
            previewViewController.mailboxDigipostAddress = mailboxDigipostAddress
            previewViewController.currentShowingHTMLContent = currentShowingBodyInnnerHTML

        } else if let moduleSelectViewController = segue.destination  as? ModuleSelectorViewController{
            moduleSelectViewController.delegate = self
        }
    }

    func moduleSelectorViewControllerWasDismissed(_ moduleSelectorViewController: ModuleSelectorViewController) {

    }

    func moduleSelectorViewController(_ moduleSelectorViewController: ModuleSelectorViewController, didSelectModule module: ComposerModule) {

        if let imageModule = module as? ImageComposerModule {
            webView.insertImageWithBase64Data(imageModule.image.base64Representation)
        }

        moduleSelectorViewController.dismiss(animated: true, completion: nil)
    }

    fileprivate func currentBundle() -> Bundle {
        return Bundle(for: type(of: self))
    }
}
