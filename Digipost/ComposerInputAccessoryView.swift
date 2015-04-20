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
    
    override func awakeFromNib() {
        super.awakeFromNib()        
    }
    
    @IBAction func alignContentLeft(sender: AnyObject) {
        textView.textAlignment = .Left
    }
    
    @IBAction func alignContentCenter(sender: AnyObject) {
        textView.textAlignment = .Center
    }

    @IBAction func alignContentRight(sender: AnyObject) {
        textView.textAlignment = .Right
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
            nameLabel.text = "Boaaady"
        }
    }
}
