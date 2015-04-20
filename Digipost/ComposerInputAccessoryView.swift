//
//  ComposerInputAccessoryView.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-16.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class ComposerInputAccessoryView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        setBackground(leftView)
    }
    
    @IBAction func alignContentLeft(sender: AnyObject) {
        textView.textAlignment = .Left
        setBackground(leftView)
    }
    
    @IBAction func alignContentCenter(sender: AnyObject) {
        textView.textAlignment = .Center
        setBackground(centerView)

    }

    @IBAction func alignContentRight(sender: AnyObject) {
        textView.textAlignment = .Right
        setBackground(rightView)
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        textView.resignFirstResponder()
    }
    
    func setBackground(view: UIView) {
        leftView.backgroundColor = .clearColor()
        centerView.backgroundColor = .clearColor()
        rightView.backgroundColor = .clearColor()
        
        view.backgroundColor = 	UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    }
    
    func setLabel() {
        let font = textView.font
        switch font {
        case UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline):
            nameLabel.text = "Headline"
        case UIFont.preferredFontForTextStyle(UIFontTextStyleBody):
            nameLabel.text = "Body"
        case UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline):
            nameLabel.text = "Subheader"
        default:
            nameLabel.text = "Body"
        }
    }
}
