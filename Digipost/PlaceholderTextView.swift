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

extension PlaceholderTextView{
    var placeholder: String {

        switch self.font! {
        case UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline):
            return NSLocalizedString("text composer module headline placeholder", comment: "placeholder for headline")
        case UIFont.preferredFontForTextStyle(UIFontTextStyleBody):
            return NSLocalizedString("text composer module body placeholder", comment: "placeholder for body")
        case UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline):
            return NSLocalizedString("text composer module subheadline placeholder", comment: "placeholder for subheadline")
        default:
            return NSLocalizedString("text composer module body placeholder", comment: "placeholder for headline")
        }
    }
}

class PlaceholderTextView: UITextView {
    
    private var placeholderLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textViewDidChange:", name: UITextViewTextDidChangeNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textViewDidEndEditing:", name: UITextViewTextDidEndEditingNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textViewDidBeginEditing:", name: UITextViewTextDidBeginEditingNotification, object: self)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textViewDidChange(notification: NSNotification?) {
        if let object = notification?.object as? PlaceholderTextView{
            if object == self {
                
                if text.characters.count > 0 {
                    if placeholderLabel != nil {
                        removePlaceholder()
                    }
                } else {
                    addPlaceholder()
                }
            }
        }

    }
    
    func textViewDidEndEditing(notification: NSNotification?){
        if let object = notification?.object as? PlaceholderTextView{
            if object == self {
                
                
            }
        }
    }
    
    func textViewDidBeginEditing(notification: NSNotification?){
        if let object = notification?.object as? PlaceholderTextView{
            if object == self {
                
                if text.characters.count == 0 {
                    addPlaceholder()
                }
            }
        }
    }

    func removePlaceholder(){
        placeholderLabel.removeFromSuperview()
        placeholderLabel = nil
    }
    
    func addPlaceholder(){
        if placeholderLabel == nil{
            
            placeholderLabel = {
                let cursorPosition = self.caretRectForPosition(self.selectedTextRange!.start)
                let label = UILabel(frame: CGRectMake(cursorPosition.origin.x, cursorPosition.origin.y, self.frame.width, cursorPosition.height))
                label.text = self.placeholder
                label.textColor = UIColor.lightGrayColor()
                label.font = self.font
                return label
            }()
            

            addSubview(placeholderLabel)
        }
    }

}
