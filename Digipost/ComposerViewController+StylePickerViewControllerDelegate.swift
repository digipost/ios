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

extension ComposerViewController : StylePickerViewControllerDelegate {

    func stylePickerViewControllerDidSelectStyle(stylePickerViewController: StylePickerViewController, textStyleModel: TextStyleModel, enabled: Bool) {
        if let (composerModule, textView) = self.currentEditingComposerModuleAndTextView() {
            self.setStyle(textStyleModel, forComposerModule: composerModule, textView: textView)
        }
    }

    func setStyle(textStyleModel: TextStyleModel, forComposerModule composerModule: TextComposerModule, textView: UITextView, var range : NSRange? = nil) {
        if range == nil {
            range = textView.selectedRange
        } else {

        }

        var setAttributes : [String : AnyObject]? = nil

        switch textStyleModel.value {
        case let symbolicTrait as UIFontDescriptorSymbolicTraits:
            setAttributes = composerModule.setFontTrait(symbolicTrait, enabled: textStyleModel.enabled, atRange: range!)
            textView.attributedText = composerModule.attributedText
            textView.selectedRange = range!

            break
        default:
            break
        }
        if range!.length == 0 {
            if let actualSetAttributes = setAttributes {
                textView.typingAttributes = actualSetAttributes
            }
        }
    }
}
