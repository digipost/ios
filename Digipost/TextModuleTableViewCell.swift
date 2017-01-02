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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
