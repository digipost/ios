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
            let range = textView.selectedRange
            switch textStyleModel.value {
            case let symbolicTrait as UIFontDescriptorSymbolicTraits:
                println(symbolicTrait)
                composerModule.setFontTrait(symbolicTrait, enabled: enabled, atRange: range)
                textView.attributedText = composerModule.attributedText
                textView.selectedRange = range
                break
            default:
                break
            }

        }

    }
}
