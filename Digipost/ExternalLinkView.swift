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

import Foundation
import SafariServices

@objc class ExternalLinkView: MetadataView, SFSafariViewControllerDelegate{
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var deadline: UILabel!
    
    var url = "https://www.digipost.no"
    @IBOutlet weak var feedbackButton: UIButton! 

     func instanceWithData(externalLink: POSExternalLink) -> UIView{
        let view = UINib(nibName: "ExternalLinkView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ExternalLinkView
        
        view.title.attributedText = attributedString(text: view.title.text!, lineSpacing: customTitleLineSpacing, minimumLineHeight: minimumTitleLineHeight)
        view.text.attributedText = attributedString(text: view.text.text!, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        view.deadline.attributedText = attributedString(text: view.deadline.text!, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        view.url = externalLink.url;
        
        view.feedbackButton.setTitle("Bekreft eller avslå barnehageplass", for: UIControlState.normal)
        view.feedbackButton.titleLabel?.numberOfLines = 2
        return view
    }
    
    @IBAction func externalLinkButton(_ sender: UIButton) {
        let safariVC = SFSafariViewController(url: URL(string: url)!)
        getCurrentViewController()?.present(safariVC, animated: true, completion: nil)        
        safariVC.delegate = self
    }
    
    private func instanceFromNib() -> UIView {
        return UINib(nibName: "ExternalLinkView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
