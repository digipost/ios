//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import UIKit

class TextComposerModule: ComposerModule {


    var textAttribute : TextAttribute
    var type : HTMLTagBlockType
    var attributedText: NSAttributedString!
    var styling = [TextAttribute]()

    class func headlineModule() -> TextComposerModule {
        var textComposerModule = TextComposerModule()
        textComposerModule.type = .H1
        textComposerModule.attributedText = NSAttributedString(string: " ", attributes: [NSFontAttributeName : UIFont.headlineH1()])
        return textComposerModule
    }

    class func paragraphModule() -> TextComposerModule {
        var textComposerModule = TextComposerModule()
        textComposerModule.type = .Paragraph
        textComposerModule.attributedText = NSAttributedString(string: " ", attributes: [NSFontAttributeName : UIFont.paragraph()])
        return textComposerModule
    }

    var placeholder: String {
        switch self.textAttribute.font! {
        case UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline):
            return "Enter a Headline"
        case UIFont.preferredFontForTextStyle(UIFontTextStyleBody):
            return "Enter a Body"
        case UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline):
            return "Enter a Subheadline"
        default:
            return "Enter text"
        }
    }

    func appendCharactersToEndOfString(characters: String) {
        let shouldRemoveFirstString : Bool = {
            if self.attributedText.string == " " {
                return true
            }
            return false
            }()

        var mutableAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString
        let endOfStringAttributes = attributedText.attributesAtIndex(attributedText.length - 1 , effectiveRange: nil)
        let appendingAttributedString = NSAttributedString(string: characters, attributes: endOfStringAttributes)
        // to keep style if whole string is deleted, string needs to be initialized with a space in start, remove it when adding actual text
        if shouldRemoveFirstString {
            mutableAttributedString.mutableString.replaceCharactersInRange(NSMakeRange(0, 1), withString: "")
        }
        mutableAttributedString.appendAttributedString(appendingAttributedString)
        attributedText = mutableAttributedString
    }

    func appendNewParagraph() {
        var mutableAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString
        let appendingAttributedString = NSAttributedString(string: "\n", attributes:[NSFontAttributeName : UIFont.paragraph()])
        // to keep style if whole string is deleted, string needs to be initialized with a space in start, remove it when adding actual text
        mutableAttributedString.appendAttributedString(appendingAttributedString)
        attributedText = mutableAttributedString
    }

    func setFontTrait(fontTrait: UIFontDescriptorSymbolicTraits, enabled: Bool, atRange range: NSRange) -> [String : AnyObject] {
        var mutableAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString
        var returnDictionary = [String : AnyObject]()
        attributedText.enumerateAttributesInRange(range, options: NSAttributedStringEnumerationOptions()) { (attributes, inRange, stop) -> Void in
            if let font = attributes[NSFontAttributeName] as? UIFont {
                let newFont = self.newFont(font, newFontTrait: fontTrait, enabled: enabled)
                mutableAttributedString.addAttribute(NSFontAttributeName, value: newFont, range: inRange)
                returnDictionary[NSFontAttributeName] = newFont
            }
        }

        if range.length == 0 {
            let existingAttributes = attributedText.attributesAtIndex(range.location - 1, effectiveRange: nil)
            if let font = existingAttributes[NSFontAttributeName] as? UIFont {
                let newFont = self.newFont(font, newFontTrait: fontTrait, enabled: enabled)
                returnDictionary[NSFontAttributeName] = newFont
            }
        }

        attributedText = mutableAttributedString
        return returnDictionary
    }

    func newFont(existingFont: UIFont, newFontTrait: UIFontDescriptorSymbolicTraits, enabled: Bool) -> UIFont {
        let fontDescriptor = existingFont.fontDescriptor()
        let existingTraits = fontDescriptor.symbolicTraits
        let newTraits : UIFontDescriptorSymbolicTraits =  {
            if enabled {
                 let result = existingTraits.rawValue | newFontTrait.rawValue
                return UIFontDescriptorSymbolicTraits(rawValue: result)
            } else {
                let result = existingTraits.rawValue ^ newFontTrait.rawValue
                return UIFontDescriptorSymbolicTraits(rawValue: result)
            }
            }()
        let newFontDescriptor = fontDescriptor.fontDescriptorWithSymbolicTraits(newTraits)
        let newFont  = UIFont(descriptor: newFontDescriptor, size: existingFont.pointSize)
        return newFont
    }

    func setTextAlignment(alignment: NSTextAlignment) {
        var mutableAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString
        let endOfStringAttributes = attributedText.attributesAtIndex(attributedText.length - 1 , effectiveRange: nil)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        mutableAttributedString.addAttribute(NSParagraphStyleAttributeName , value: paragraphStyle, range:  NSMakeRange(0, attributedText.length))
        attributedText = mutableAttributedString
    }

    func openingTag() {

    }

    override init() {
        self.textAttribute = TextAttribute(font: UIFont.systemFontOfSize(17), textAlignment: .Left)
        self.type = .Unknown
        super.init()
    }

    init(moduleWithFont font: UIFont) {
        textAttribute = TextAttribute(font: font, textAlignment: .Left)
        self.type = .Unknown
        super.init()
    }

    override func htmlRepresentation() -> NSString {
        var htmlSections = [HTMLSection]()
        var hadNewLine = false
        var currentEditingTagBlock : HTMLTagBlock?
        var currentRange : NSRange?
        var htmlContent = ""

        let stringsSplitByNewline = attributedText.string.componentsSeparatedByString("\n")

        var stringIndex = 0
        var wholeString = ""

        for string in stringsSplitByNewline {
            print(string)
            if string.isEmpty {
                continue
            }
            var tagBlocksInString = [HTMLTagBlock]()
            attributedText.enumerateAttributesInRange(NSMakeRange(stringIndex, string.length), options: NSAttributedStringEnumerationOptions()) { (attributeDict, range, stop) -> Void in
                for (attributeKey, attributeValue) in attributeDict {
                    if attributeKey == "NSParagraphStyle" {
                        continue
                    }

                    let stringAtSubstring = (self.attributedText.string as NSString).substringWithRange(range)
                    let rangeInHTMLTagBlock = NSMakeRange(range.location - stringIndex, range.length)

                    let tagBlocks = HTMLTagBlock.tagBlocks(attributeKey , value: attributeValue, range: rangeInHTMLTagBlock)
                    tagBlocksInString.appendContentsOf(tagBlocks)
                }
            }

            let section = HTMLSection(content: string, tagBlocks: tagBlocksInString)
            htmlSections.append(section)
            currentEditingTagBlock = nil
            stringIndex += string.length + "\n".length
        }

        for htmlSection in htmlSections {
            htmlContent += htmlSection.htmlRepresentation(htmlSection.content) as String
        }

        return htmlContent
    }
    
}