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

@objc class SingleUseWebViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    @objc var initUrl: String = ""
    @objc var viewTitle : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.title
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = viewTitle
        
        let newBackButton = UIBarButtonItem(title: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE",comment:"Tilbake"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SingleUseWebViewController.dismissView))
        self.navigationItem.leftBarButtonItem = newBackButton
        let myURL = URL(string: initUrl)
        let request = NSMutableURLRequest(url: myURL!)
        webView.load(request as URLRequest)
    }
    
    override func loadView() {
        webView = WKWebView(frame: .zero)
        webView.uiDelegate = self
        view = webView
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: {});
    }
}
