//
//  TextModuleTableViewCell
//  ModuleSendEditor
//
//  Created by Henrik Holmsen on 20.02.15.
//  Copyright (c) 2015 Nettbureau AS. All rights reserved.
//

import UIKit

class TextModuleTableViewCell: UITableViewCell {

    @IBOutlet var moduleTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        moduleTextView.layer.borderWidth = 0.5
//        moduleTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        moduleTextView.inputAccessoryView = NSBundle.mainBundle().loadNibNamed("ComposerInputAccesoryView", owner: self, options: nil)[0] as? UIView

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
