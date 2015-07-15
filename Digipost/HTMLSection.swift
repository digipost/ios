//
//  HTMLSection.swift
//  Digipost
//
//  Created by Håkon Bogen on 15/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class HTMLSection: HTMLRepresentable {

    let content: String
    let tagBlocks: [HTMLTagBlock]


    init(content: String, tagBlocks: [HTMLTagBlock]){
        self.content = content
        self.tagBlocks = tagBlocks
    }

    func htmlRepresentation(inString: NSString) -> NSString {
        var representation = (inString as NSString).mutableCopy() as! NSMutableString
        var index = 0
        var newContent = ""
        println(representation)

        let regex = NSRegularExpression(pattern: "</?[a-å][a-å0-9]*[^<>]*>", options: NSRegularExpressionOptions.allZeros, error: nil)
        for tagBlock in tagBlocks {
            let tagLength = lengthOfAllTagsBeforeIndex(index, inString: representation as NSString)

            let startTagIndex = tagBlock.range.location + tagLength
            let endTagIndex =  tagBlock.range.length + tagBlock.range.location + tagLength

            if tagBlock.tag.type != .Paragraph {
                representation.insertString(tagBlock.tag.endTag, atIndex: endTagIndex)
                representation.insertString(tagBlock.tag.startTag, atIndex: startTagIndex)
                index = index + tagBlock.range.location + tagBlock.tag.startTag.length + tagBlock.range.length + tagBlock.tag.endTag.length
            } else {
                index += tagBlock.range.length
            }
        }

        return "<p>\(representation)</p>"
    }

    func lengthOfAllTagsBeforeIndex(index: Int, inString string: NSString) -> Int {
        var error : NSError?
        let regex = NSRegularExpression(pattern: "</?[a-å][a-å0-9]*[^<>]*>", options: NSRegularExpressionOptions.AllowCommentsAndWhitespace, error: &error)
        let allMatches = regex!.matchesInString(string as String, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, index))
        var totalLength = 0
        for match in allMatches as! [NSTextCheckingResult] {
            totalLength += match.range.length
        }

        return totalLength
    }
}
