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
    var initUrl: String = "https://www.digipost.no"
    var viewTitle : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.title
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let myURL = URL(string: initUrl)
        let myRequest = URLRequest(url: myURL!)
        self.title = viewTitle
        
        webView.load(myRequest)
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
}
