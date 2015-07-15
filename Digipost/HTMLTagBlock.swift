//
//  HTMLTag.swift
//  Digipost
//
//  Created by Håkon Bogen on 03/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

enum HTMLTagBlockType {
    case Paragraph
    case H1
    case H2
    case H3
    case Unknown

}

struct HTMLTagBlock : HTMLRepresentable {

    let tag : HTMLTag
    var range : NSRange

    init(key: NSObject, value: AnyObject, range: NSRange) {
        self.tag = HTMLTag(attribute: key, value: value)
        self.range = range
    }

    func htmlRepresentation(inString: NSString) -> NSString {
        var representation = (inString as NSString).mutableCopy() as! NSMutableString
        var index = 0
        var newContent = ""

        let regex = NSRegularExpression(pattern: "</?[a-å][a-å0-9]*[^<>]*>", options: NSRegularExpressionOptions.allZeros, error: nil)

        if range.location + range.length < inString.length {
            let subString = inString.substringWithRange(range)
            return "\(tag.startTag)\(subString)\(tag.endTag)"
        }

        return "\(tag.startTag)\(tag.endTag)"
    }

    static func isHTMLTagBlockFont(font: UIFont) -> Bool {
        if font.isEqual(UIFont.headlineH1()) {
            return true
        } else if font.isEqual(UIFont.paragraph()) {
            return true
        }

        return false
    }

    


}
