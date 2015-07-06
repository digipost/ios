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

    let type : HTMLTagBlockType

    var tags = [HTMLTag]()

    var content : String

    init(font : UIFont, content : String) {
        switch font {
        case UIFont.headlineH1():
            type = .H1
            break
        case UIFont.paragraph():
            type = .Paragraph
        default:
            type = .Unknown
            break
        }
        self.content = content
    }
    
    mutating func addAttribute(attribute : NSObject, value : AnyObject, atRange range: Range<Int>) {
        let tag = HTMLTag(attribute: attribute, value: value, range: range)
        self.tags.append(tag)
    }

    func htmlRepresentation() -> String {
        var representation = (self.content as NSString).mutableCopy() as! NSMutableString
        var index = 0

        var newContent = ""


        let regex = NSRegularExpression(pattern: "</?[a-z][a-z0-9]*[^<>]*>", options: NSRegularExpressionOptions.allZeros, error: nil)

//        regex?.stringByReplacingMatchesInString(representation, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, representation.length), withTemplate: "OIM")

        for tag in tags {
            let tagLength = lengthOfAllTagsBeforeIndex(index, inString: representation as String)
            let startTagIndex = tag.range.startIndex + tagLength
            let endTagIndex = tag.range.endIndex + tagLength
            representation.insertString(tag.endTag, atIndex: endTagIndex)
            representation.insertString(tag.startTag, atIndex: startTagIndex)
            index = index + tag.startTag.length + tag.endTag.length
        }
        return (representation as String)

    }

    func lengthOfAllTagsBeforeIndex(index: Int, inString string: String) -> Int {
        let regex = NSRegularExpression(pattern: "</?[a-z][a-z0-9]*[^<>]*>", options: NSRegularExpressionOptions.allZeros, error: nil)
        let allMatches = regex!.matchesInString(string, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, index))
        var totalLength = 0
        for match in allMatches as! [NSTextCheckingResult] {
            totalLength += match.range.length
        }

        return totalLength
    }


}
