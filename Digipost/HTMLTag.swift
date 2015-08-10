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


    init(type: HTMLTagType) {
        self.type = type
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

    static func tags(attribute: NSObject, value: AnyObject) -> [HTMLTag] {
        var tags = [HTMLTag]()

        if let actualFont = value as? UIFont {
            if actualFont == UIFont.headlineH1() {
                tags.append(HTMLTag(type: HTMLTagType.H1))
                return tags
            }
            let symbolicTraits = actualFont.fontDescriptor().symbolicTraits
            let symb = UIFontDescriptorSymbolicTraits(symbolicTraits.rawValue)
            if symbolicTraits & .TraitItalic == .TraitItalic {
                tags.append(HTMLTag(type: HTMLTagType.Italic))
            }
            if symbolicTraits & .TraitBold == .TraitBold {
                tags.append(HTMLTag(type: HTMLTagType.Bold))
            }
        }
        if tags.count == 0 {
            tags.append(HTMLTag(type: HTMLTagType.Paragraph))
        }

        return tags
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