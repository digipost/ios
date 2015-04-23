//
//  PlaceholderTextView.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension PlaceholderTextView{
    var placeholder: String {
        switch self.font {
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textViewDidChange:", name: UITextViewTextDidChangeNotification, object: self)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textViewDidChange(notification: NSNotification?) -> (Void) {
        if let object = notification?.object as? PlaceholderTextView{
            if object == self {
                
                if count(text) > 0 {
                    if placeholderLabel != nil {
                        placeholderLabel.removeFromSuperview()
                        placeholderLabel = nil
                    }
                } else {
                    addPlaceholder()
                }
            }
        }

    }
    
    func addPlaceholder(){
        let cursorPosition = self.caretRectForPosition(self.selectedTextRange?.start)
        placeholderLabel = UILabel(frame: CGRectMake(cursorPosition.origin.x, cursorPosition.origin.y, frame.width, cursorPosition.height))
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = UIColor.lightGrayColor()
        placeholderLabel.font = font
        addSubview(placeholderLabel)
    }

}
