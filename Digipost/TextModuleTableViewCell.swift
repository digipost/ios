//
//  TextModuleTableViewCell
//  ModuleSendEditor
//
//  Created by Henrik Holmsen on 20.02.15.
//  Copyright (c) 2015 Nettbureau AS. All rights reserved.
//

import UIKit

class TextModuleTableViewCell: UITableViewCell {
    var composerInputAccessoryView: ComposerInputAccessoryView!
    
    @IBOutlet var moduleTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        moduleTextView.layer.borderWidth = 0.5
//        moduleTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        composerInputAccessoryView = NSBundle.mainBundle().loadNibNamed("ComposerInputAccesoryView", owner: self, options: nil)[0] as! ComposerInputAccessoryView
        
        composerInputAccessoryView.textView = moduleTextView
        
        moduleTextView.inputAccessoryView = composerInputAccessoryView
        
    }
    
    func setLabel(font: UIFont) {
        println(font)
        switch font{
        case UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline):
            composerInputAccessoryView.nameLabel.text = "Headline"
        case UIFont.preferredFontForTextStyle(UIFontTextStyleBody):
            composerInputAccessoryView.nameLabel.text = "Body"
        case UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline):
            composerInputAccessoryView.nameLabel.text = "Subheader"
        default:
            composerInputAccessoryView.nameLabel.text = "Boaaady"
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
