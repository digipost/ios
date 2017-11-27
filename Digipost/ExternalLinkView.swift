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
    
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var deadline: UILabel!
    @IBOutlet weak var feedbackButton: UIButton!
    @objc var extraHeight = CGFloat(0)
    @objc var parentViewController: POSLetterViewController? = nil
    var url = "https://www.digipost.no"

    @objc func instanceWithData(externalLink: POSExternalLink) -> UIView{
        let view = UINib(nibName: "ExternalLinkView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ExternalLinkView        
        view.text.attributedText = attributedString(text: externalLink.text, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        view.url = externalLink.url;
        view.feedbackButton.setTitle(externalLink.buttonText, for: UIControlState.normal)
        view.feedbackButton.titleLabel?.numberOfLines = 2
        view.extraHeight += positiveHeightAdjustment(text: externalLink.text, width: view.text.frame.width, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        view.containerViewHeight.constant += extraHeight
        
        if externalLink.deadlineText.length > 0 {
            var deadlineText = String.localizedStringWithFormat(NSLocalizedString("metadata externalink deadline", comment:"Frist: "), externalLink.deadlineText)
            if externalLink.deadline < Date() {
                deadlineText = String.localizedStringWithFormat(NSLocalizedString("metadata externalink expired", comment:"Frist utløpt: "), externalLink.deadlineText)
                view.deadline.textColor = UIColor.init(r: 190, g: 49, b: 38)
            }
            view.deadline.attributedText = attributedString(text: deadlineText, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        }
        return view
    }

    
    @objc func setParentViewController(parentViewController: POSLetterViewController) {
        self.parentViewController = parentViewController
    }
    
    @IBAction func externalLinkButton(_ sender: UIButton) {
        parentViewController?.openExternalLink(url)
    }

    private func instanceFromNib() -> UIView {
        return UINib(nibName: "ExternalLinkView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
