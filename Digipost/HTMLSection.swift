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
    let tag: HTMLTag


    init(content: String, tagBlocks: [HTMLTagBlock]){
        self.content = content
        self.tagBlocks = tagBlocks
        let firstTagBlock = tagBlocks.first
        if firstTagBlock?.tag.type == .Bold || firstTagBlock?.tag.type == .Italic || firstTagBlock?.tag.type == .Paragraph {
            self.tag = HTMLTag(attribute: NSFontAttributeName, value: UIFont.paragraph())
        } else {
            self.tag = firstTagBlock!.tag
        }
    }

    func htmlRepresentation(inString: NSString) -> NSString {
        var representation = (inString as NSString).mutableCopy() as! NSMutableString
        var index = 0
        var newContent = ""

        let regex = try! NSRegularExpression(pattern: "</?[a-å][a-å0-9]*[^<>]*>", options: NSRegularExpressionOptions())
        var addedRanges = [NSRange]()

        for tagBlock in tagBlocks {
            let tagLength = lengthOfAllTagsBeforeIndex(index, inString: representation as NSString)

            let (startTagIndex, endTagIndex) : (Int,Int) = {
                if (addedRanges.contains(tagBlock.range)) {
                    let startTagIndex = tagBlock.range.location + tagLength - 4
                    let endTagIndex =  tagBlock.range.length + tagBlock.range.location + tagLength
                    return (startTagIndex,endTagIndex)
                } else {
                    let startTagIndex = tagBlock.range.location + tagLength
                    let endTagIndex =  tagBlock.range.length + tagBlock.range.location + tagLength
                    return (startTagIndex,endTagIndex)
                }
            }()
            if tagBlock.tag.type != .Paragraph {
                representation.insertString(tagBlock.tag.endTag, atIndex: endTagIndex)
                representation.insertString(tagBlock.tag.startTag, atIndex: startTagIndex)

                if addedRanges.contains(tagBlock.range) {
                    index = index + tagBlock.tag.startTag.length + tagBlock.tag.endTag.length
                } else {
                    index = index + tagBlock.range.location + tagBlock.tag.startTag.length + tagBlock.range.length + tagBlock.tag.endTag.length
                }
            } else {
                index += tagBlock.range.length
            }

            addedRanges.append(tagBlock.range)
        }

        if tag.type == .Paragraph {
            return "\(tag.startTag)\(representation)\(tag.endTag)"
        } else {
            return representation
        }
    }

    func lengthOfAllTagsBeforeIndex(index: Int, inString string: NSString) -> Int {
        var error : NSError?
        let regex = try! NSRegularExpression(pattern: "</?[a-å][a-å0-9]*[^<>]*>", options: NSRegularExpressionOptions.AllowCommentsAndWhitespace)
        let range : NSRange = {
            if index > string.length {
                return NSMakeRange(0, string.length)
            }else {
                return NSMakeRange(0, index)
            }
        }()

        let allMatches = regex.matchesInString(string as String, options: NSMatchingOptions(), range: range )
        var totalLength = 0
        for match in allMatches as! [NSTextCheckingResult] {
            totalLength += match.range.length
        }

        return totalLength
    }
}
