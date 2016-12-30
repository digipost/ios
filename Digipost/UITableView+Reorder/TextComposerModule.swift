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
        let textComposerModule = TextComposerModule()
        textComposerModule.type = .h1
        textComposerModule.attributedText = NSAttributedString(string: " ", attributes: [NSFontAttributeName : UIFont.headlineH1()])
        return textComposerModule
    }

    class func paragraphModule() -> TextComposerModule {
        let textComposerModule = TextComposerModule()
        textComposerModule.type = .paragraph
        textComposerModule.attributedText = NSAttributedString(string: " ", attributes: [NSFontAttributeName : UIFont.paragraph()])
        return textComposerModule
    }

    var placeholder: String {
        switch self.textAttribute.font! {
        case UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline):
            return "Enter a Headline"
        case UIFont.preferredFont(forTextStyle: UIFontTextStyle.body):
            return "Enter a Body"
        case UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline):
            return "Enter a Subheadline"
        default:
            return "Enter text"
        }
    }

    func appendCharactersToEndOfString(_ characters: String) {
        let shouldRemoveFirstString : Bool = {
            if self.attributedText.string == " " {
                return true
            }
            return false
            }()

        let mutableAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString
        let endOfStringAttributes = attributedText.attributes(at: attributedText.length - 1 , effectiveRange: nil)
        let appendingAttributedString = NSAttributedString(string: characters, attributes: endOfStringAttributes)
        // to keep style if whole string is deleted, string needs to be initialized with a space in start, remove it when adding actual text
        if shouldRemoveFirstString {
            mutableAttributedString.mutableString.replaceCharacters(in: NSMakeRange(0, 1), with: "")
        }
        mutableAttributedString.append(appendingAttributedString)
        attributedText = mutableAttributedString
    }

    func appendNewParagraph() {
        let mutableAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString
        let appendingAttributedString = NSAttributedString(string: "\n", attributes:[NSFontAttributeName : UIFont.paragraph()])
        // to keep style if whole string is deleted, string needs to be initialized with a space in start, remove it when adding actual text
        mutableAttributedString.append(appendingAttributedString)
        attributedText = mutableAttributedString
    }

    func setFontTrait(_ fontTrait: UIFontDescriptorSymbolicTraits, enabled: Bool, atRange range: NSRange) -> [String : AnyObject] {
        let mutableAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString
        var returnDictionary = [String : AnyObject]()
        attributedText.enumerateAttributes(in: range, options: NSAttributedString.EnumerationOptions()) { (attributes, inRange, stop) -> Void in
            if let font = attributes[NSFontAttributeName] as? UIFont {
                let newFont = self.newFont(font, newFontTrait: fontTrait, enabled: enabled)
                mutableAttributedString.addAttribute(NSFontAttributeName, value: newFont, range: inRange)
                returnDictionary[NSFontAttributeName] = newFont
            }
        }

        if range.length == 0 {
            let existingAttributes = attributedText.attributes(at: range.location - 1, effectiveRange: nil)
            if let font = existingAttributes[NSFontAttributeName] as? UIFont {
                let newFont = self.newFont(font, newFontTrait: fontTrait, enabled: enabled)
                returnDictionary[NSFontAttributeName] = newFont
            }
        }

        attributedText = mutableAttributedString
        return returnDictionary
    }

    func newFont(_ existingFont: UIFont, newFontTrait: UIFontDescriptorSymbolicTraits, enabled: Bool) -> UIFont {
        let fontDescriptor = existingFont.fontDescriptor
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
        let newFontDescriptor = fontDescriptor.withSymbolicTraits(newTraits)
        let newFont  = UIFont(descriptor: newFontDescriptor!, size: existingFont.pointSize)
        return newFont
    }

    func setTextAlignment(_ alignment: NSTextAlignment) {
        let mutableAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString
        _ = attributedText.attributes(at: attributedText.length - 1 , effectiveRange: nil)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        mutableAttributedString.addAttribute(NSParagraphStyleAttributeName , value: paragraphStyle, range:  NSMakeRange(0, attributedText.length))
        attributedText = mutableAttributedString
    }

    func openingTag() {

    }

    override init() {
        self.textAttribute = TextAttribute(font: UIFont.systemFont(ofSize: 17), textAlignment: .left)
        self.type = .unknown
        super.init()
    }

    init(moduleWithFont font: UIFont) {
        textAttribute = TextAttribute(font: font, textAlignment: .left)
        self.type = .unknown
        super.init()
    }

    override func htmlRepresentation() -> NSString {
        var htmlSections = [HTMLSection]()
        //var hadNewLine = false
        //var currentEditingTagBlock : HTMLTagBlock?
        //var currentRange : NSRange?
        var htmlContent = ""

        let stringsSplitByNewline = attributedText.string.components(separatedBy: "\n")

        var stringIndex = 0
        //var wholeString = ""

        for string in stringsSplitByNewline {
            print(string)
            if string.isEmpty {
                continue
            }
            var tagBlocksInString = [HTMLTagBlock]()
            attributedText.enumerateAttributes(in: NSMakeRange(stringIndex, string.length), options: NSAttributedString.EnumerationOptions()) { (attributeDict, range, stop) -> Void in
                for (attributeKey, attributeValue) in attributeDict {
                    if attributeKey == "NSParagraphStyle" {
                        continue
                    }

                    //let stringAtSubstring = (self.attributedText.string as NSString).substringWithRange(range)
                    let rangeInHTMLTagBlock = NSMakeRange(range.location - stringIndex, range.length)

                    let tagBlocks = HTMLTagBlock.tagBlocks(attributeKey as NSObject , value: attributeValue, range: rangeInHTMLTagBlock)
                    tagBlocksInString.append(contentsOf: tagBlocks)
                }
            }

            let section = HTMLSection(content: string, tagBlocks: tagBlocksInString)
            htmlSections.append(section)
            //currentEditingTagBlock = nil
            stringIndex += string.length + "\n".length
        }

        for htmlSection in htmlSections {
            htmlContent += htmlSection.htmlRepresentation(htmlSection.content as NSString) as String
        }

        return htmlContent as NSString
    }
    
}
