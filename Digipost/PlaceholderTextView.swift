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
        case UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline):
            return NSLocalizedString("text composer module headline placeholder", comment: "placeholder for headline")
        case UIFont.preferredFont(forTextStyle: UIFontTextStyle.body):
            return NSLocalizedString("text composer module body placeholder", comment: "placeholder for body")
        case UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline):
            return NSLocalizedString("text composer module subheadline placeholder", comment: "placeholder for subheadline")
        default:
            return NSLocalizedString("text composer module body placeholder", comment: "placeholder for headline")
        }
    }
}

class PlaceholderTextView: UITextView {
    
    fileprivate var placeholderLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(UITextViewDelegate.textViewDidChange(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(UITextViewDelegate.textViewDidEndEditing(_:)), name: NSNotification.Name.UITextViewTextDidEndEditing, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(UITextViewDelegate.textViewDidBeginEditing(_:)), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: self)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    func textViewDidChange(_ notification: Notification?) {
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
    
    func textViewDidEndEditing(_ notification: Notification?){
        if let object = notification?.object as? PlaceholderTextView{
            if object == self {
                
                
            }
        }
    }
    
    func textViewDidBeginEditing(_ notification: Notification?){
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
                let cursorPosition = self.caretRect(for: self.selectedTextRange!.start)
                let label = UILabel(frame: CGRect(x: cursorPosition.origin.x, y: cursorPosition.origin.y, width: self.frame.width, height: cursorPosition.height))
                label.text = self.placeholder
                label.textColor = UIColor.lightGray
                label.font = self.font
                return label
            }()
            

            addSubview(placeholderLabel)
        }
    }

}
