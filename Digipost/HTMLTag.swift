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

    init(tagBlockType: HTMLTagBlockType) {
        self.type = {
            switch tagBlockType {
            case HTMLTagBlockType.H1:
                return HTMLTagType.H1
            case HTMLTagBlockType.Paragraph:
                return HTMLTagType.Paragraph
            default:
                return HTMLTagType.Unknown
            }
        }()
    }

    init(attribute: NSObject, value: AnyObject) {

        let aFont = UIFont()
        self.type = {

            switch attribute {
            case NSFontAttributeName:
                if let actualFont = value as? UIFont {
                    if actualFont == UIFont.headlineH1() {
                        return HTMLTagType.H1
                    }

                    let symbolicTraits = actualFont.fontDescriptor().symbolicTraits
                    let symb = UIFontDescriptorSymbolicTraits(symbolicTraits.rawValue)
                    if symbolicTraits & .TraitItalic == .TraitItalic {
                        return HTMLTagType.Italic
                    } else if symbolicTraits & .TraitBold == .TraitBold {
                        return HTMLTagType.Bold
                    }
                    return HTMLTagType.Paragraph
                }
                return HTMLTagType.Unknown
            default:
                return HTMLTagType.Paragraph
            }}()

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