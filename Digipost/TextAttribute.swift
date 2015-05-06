//
//  TextAttribute.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

struct TextAttribute {

    var textAlignment : NSTextAlignment?
    var font : UIFont?

    func hasOneOrMoreMatchesWith(#textAttribute : TextAttribute) -> Bool {
        if self.textAlignment == textAttribute.textAlignment {
            return true
        }

        if self.font?.familyName == textAttribute.font?.familyName {
            return true
        }
        return false
    }

    init(font: UIFont) {
        self.font = font
    }

    init(textAlignment: NSTextAlignment) {
        self.textAlignment = textAlignment
    }

    init() {

    }
}