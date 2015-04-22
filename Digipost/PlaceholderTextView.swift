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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange:", name: UITextViewTextDidChangeNotification, object: self)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textDidChange(notification: NSNotification?) -> (Void) {
        if let object = notification?.object as? PlaceholderTextView{
            if object == self {
                
                if text.isEmpty {
                    addPlaceholder()
                } else if text.hasSuffix(placeholder){
                    text = text.firstLetter()
                    textColor = UIColor.blackColor()
                }
            }
        }

    }
    
    func addPlaceholder(){
        textColor = UIColor.lightGrayColor()
        text = placeholder
        let markerStartPosition = NSMakeRange(0, 0)
        selectedRange = markerStartPosition
    }

}
