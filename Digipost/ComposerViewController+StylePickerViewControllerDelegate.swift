//
//  ComposerViewController+StylePickerViewControllerDelegate.swift
//  Digipost
//
//  Created by Håkon Bogen on 09/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
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

        var setAttributes : [NSObject : AnyObject]? = nil

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
