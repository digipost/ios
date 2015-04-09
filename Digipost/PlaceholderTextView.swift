//
//  PlaceholderTextView.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class PlaceholderTextView: UITextView {
    
    var placeholderLabel: UILabel = UILabel()
    var placeholderColor: UIColor = UIColor.lightGrayColor()
    var placeholderText: String = ""
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, withPlaceholderText placeholderText: String){
        self.placeholderText = placeholderText
        let textContainer = NSTextContainer(size: frame.size)
        super.init(frame: frame, textContainer: textContainer)
        
        placeholderLabel.frame = frame
        placeholderLabel.backgroundColor = UIColor.clearColor()
        placeholderLabel.text = placeholderText
        self.addSubview(placeholderLabel)
        self.sendSubviewToBack(placeholderLabel)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange:", name: UITextViewTextDidChangeNotification, object: nil)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    func textDidChange(notification:NSNotification?) -> (Void) {
        println("Text changed")
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
