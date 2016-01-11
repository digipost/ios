//
//  NSAttributedString+Attributes.swift
//  Digipost
//
//  Created by Håkon Bogen on 13/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension NSAttributedString {



    func symbolicTraits() -> UIFontDescriptorSymbolicTraits {
        var symbolicTraits = UIFontDescriptorSymbolicTraits()

        self.enumerateAttribute(NSFontAttributeName, inRange: NSMakeRange(0, self.length), options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired) { (attribute, range, stop) -> Void in
            if let font = attribute as? UIFont {
                symbolicTraits = font.fontDescriptor().symbolicTraits
                stop.memory = true
            }
        }
        return symbolicTraits
    }

    func isBold() -> Bool {
        let symbolicTraits = self.symbolicTraits()
        
        if symbolicTraits.intersect(.TraitBold) == .TraitBold {
            return true
        }
        return false
    }

    func isItalic() -> Bool {
        let symbolicTraits = self.symbolicTraits()
        if symbolicTraits.intersect(.TraitItalic) == .TraitItalic {
            return true
        }
        return false
    }
 
}
