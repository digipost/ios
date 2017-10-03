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

@objc class ExternalLinkWebview: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var viewSubtitle: UILabel!
    
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    var initUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(ExternalLinkWebview.backButtonPressed))
        let myURL = URL(string: initUrl)
        let urlTitle = myURL!.deletingPathExtension().scheme! + "://" + myURL!.deletingPathExtension().host!
        viewSubtitle.text = urlTitle
        webView.delegate = self
        webView.scrollView.contentInset = UIEdgeInsets.zero;
        webView.loadRequest(URLRequest(url: myURL!))
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let completeUrl = self.webView.stringByEvaluatingJavaScript(from: "document.title") {
            if !completeUrl.isEmpty { 
                viewTitle.text = completeUrl
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
