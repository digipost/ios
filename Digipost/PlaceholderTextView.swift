//
//  PlaceholderTextView.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit


class PlaceholderTextView: UITextView, UITextViewDelegate {
    
    @IBInspectable var placeholder: String!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange:", name: UITextViewTextDidChangeNotification, object: self)
        delegate = self
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        println()
    }
    
    func addPlaceholder(){
       
        placeholder = {
            switch self.font {
            case UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline):
                return "Enter a Headline"
            case UIFont.preferredFontForTextStyle(UIFontTextStyleBody):
                return "Enter a Body"
            case UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline):
                return "Enter a Subheadline"
            default:
                return "Enter text"
            }
            }()
        
        textColor = UIColor.lightGrayColor()
        text = placeholder ?? ""
        let markerStartPosition = NSMakeRange(0, 0)
        selectedRange = markerStartPosition
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
