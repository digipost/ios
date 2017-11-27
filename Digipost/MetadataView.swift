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

@objc class MetadataView: UIView {
    
    let customTitleLineSpacing:CGFloat = 4
    let customTextLineSpacing:CGFloat = 3
    let minimumTitleLineHeight:CGFloat = 20
    let minimumTextLineHeight:CGFloat = 15

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func positiveHeightAdjustment(text:String, width:CGFloat, lineSpacing: CGFloat, minimumLineHeight: CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont(name: "Helvetica", size: minimumLineHeight)
        label.attributedText = attributedString(text: text, lineSpacing: lineSpacing, minimumLineHeight: minimumLineHeight)
        label.sizeToFit()
        
        return label.frame.height
    }
    
    func attributedString(text: String, lineSpacing: CGFloat, minimumLineHeight: CGFloat)  -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.minimumLineHeight = minimumLineHeight
        attrString.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: NSRange(location: 0, length: text.characters.count))
        return attrString
    }
}
