//
//  TextAttribute.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

struct TextAttribute : HTMLRepresentable, DebugPrintable {

    var textAlignment : NSTextAlignment?
    var font : UIFont?

    func hasOneOrMoreMatchesWith(#textAttribute : TextAttribute) -> Bool {
        if self.textAlignment == textAttribute.textAlignment && self.textAlignment != nil  {
            return true
        }

        if self.font?.familyName == textAttribute.font?.familyName && self.font != nil {
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

    init(font: UIFont, textAlignment aTextAligntment : NSTextAlignment) {
        self.font = font
        self.textAlignment = aTextAligntment
    }

    init() {

    }

    func htmlRepresentation() -> String {
        return ""
    }

    var debugDescription : String {
        return "font : \(font) textAlignment: \(textAlignment?.rawValue)"
    }
}