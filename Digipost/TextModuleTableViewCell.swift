//
//  TextModuleTableViewCell
//  ModuleSendEditor
//
//  Created by Henrik Holmsen on 20.02.15.
//  Copyright (c) 2015 Nettbureau AS. All rights reserved.
//

import UIKit

class TextModuleTableViewCell: UITableViewCell {

    @IBOutlet var moduleTextView: PlaceholderTextView!

    weak var composerInputAccessoryView : ComposerInputAccessoryView?

   override func awakeFromNib() {
        super.awakeFromNib()
        moduleTextView.inputAccessoryView = composerInputAccessoryView
        
    }
    
//    func setLabel(font: UIFont) {
//        switch font{
//        case UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline):
//            composerInputAccessoryView.nameLabel.text = NSLocalizedString("headline title", comment: "headline title")
//        case UIFont.preferredFontForTextStyle(UIFontTextStyleBody):
//            composerInputAccessoryView.nameLabel.text = NSLocalizedString("normal text title", comment: "headline title")
//        case UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline):
//            composerInputAccessoryView.nameLabel.text = NSLocalizedString("subheadline title", comment: "headline title")
//        default:
//            composerInputAccessoryView.nameLabel.text = NSLocalizedString("headline title", comment: "headline title")
//        }
//    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
