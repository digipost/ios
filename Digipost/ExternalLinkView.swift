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

@objc class ExternalLinkView: MetadataView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var deadline: UILabel!
    @IBAction func externalLinkButton(_ sender: UIButton) {
    }
    
     func instanceWithData(externalLink: POSExternalLink) -> UIView{
        let view = UINib(nibName: "ExternalLinkView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ExternalLinkView
        
        title.attributedText = attributedString(text: title.text!, lineSpacing: customTitleLineSpacing, minimumLineHeight: minimumTitleLineHeight)
        text.attributedText = attributedString(text: text.text!, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        deadline.attributedText = attributedString(text: deadline.text!, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        
        return view
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
