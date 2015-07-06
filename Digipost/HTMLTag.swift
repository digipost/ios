//
//  HTMLTag.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

enum HTMLTagType : String {
    case Bold = "<b>"
    case Italic = "<i>"
    case H1   = "<h1>"
    case Paragraph   = "<p>"
    case Unknown   = ""
}

struct HTMLTag {

    let type : HTMLTagType
    let range : Range<Int>

    init(attribute: NSObject, value : AnyObject, range : Range<Int>) {

        let aFont = UIFont()
        self.type = {

            switch attribute {

            case NSFontAttributeName:
                if let actualFont = value as? UIFont {
                    let symbolicTraits = actualFont.fontDescriptor().symbolicTraits
                    if symbolicTraits == .TraitItalic {
                        return HTMLTagType.Italic
                    } else if symbolicTraits == .TraitBold {
                        return HTMLTagType.Bold
                    }
                    return HTMLTagType.Paragraph
                }
                return HTMLTagType.Unknown
            default:
                return HTMLTagType.Paragraph
            }}()

        self.range = range
    }


    var startTag : String {
        return type.rawValue
    }
    
    var endTag : String {
        var tag = type.rawValue
        tag.insert("/", atIndex: type.rawValue.startIndex.successor())
        return tag
    }

}