
//  ComposerTextModule.swift
//  Digipost
//
//  Created by Henrik Holmsen on 14.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation
import UIKit

class TextComposerModule: ComposerModule, HTMLRepresentable {


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

    func setFontTrait(fontTrait: UIFontDescriptorSymbolicTraits, enabled: Bool, atRange range: NSRange) -> [NSObject : AnyObject] {
        var mutableAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString
        var returnDictionary = [NSObject : AnyObject]()
        attributedText.enumerateAttributesInRange(range, options: NSAttributedStringEnumerationOptions.allZeros) { (attributes, inRange, stop) -> Void in
            if let font = attributes[NSFontAttributeName] as? UIFont {
                let newFont = self.newFont(font, newFontTrait: fontTrait, enabled: enabled)
                mutableAttributedString.addAttribute(NSFontAttributeName, value: newFont, range: range)
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
        var fontDescriptor = existingFont.fontDescriptor()
        let existingTraits = fontDescriptor.symbolicTraits
        let newTraits : UIFontDescriptorSymbolicTraits =  {
            if enabled {
                return existingTraits | newFontTrait
            } else {
                return existingTraits ^ newFontTrait
            }
            }()
        let newFontDescriptor = fontDescriptor.fontDescriptorWithSymbolicTraits(newTraits)
        let newFont  = UIFont(descriptor: newFontDescriptor!, size: existingFont.pointSize )
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

    override func htmlRepresentation() -> String {
        var htmlTagBlocks = [HTMLTagBlock]()
        var hadNewLine = false
        var currentEditingTagBlock : HTMLTagBlock?
        var currentRange : NSRange?
        var htmlContent = ""
        attributedText.enumerateAttributesInRange(NSMakeRange(0, attributedText.string.length), options: NSAttributedStringEnumerationOptions.allZeros) { (attributeDict, range, stop) -> Void in
            for (attributeKey, attributeValue) in attributeDict {
                let stringAtSubstring = (self.attributedText.string as NSString).substringWithRange(range)
                // skip ranges that are only a newline
                let stringsSplitByNewline = stringAtSubstring.componentsSeparatedByString("\n")

                if (stringAtSubstring.rangeOfString("\n", options: NSStringCompareOptions.CaseInsensitiveSearch) != nil){
                    if currentEditingTagBlock != nil {
                        htmlTagBlocks.append(currentEditingTagBlock!)
                    }
                    currentEditingTagBlock = nil
                }

                if attributeKey != "NSParagraphStyle" {
                    if stringsSplitByNewline.count == 1 {
                        if  currentEditingTagBlock == nil {
                            currentEditingTagBlock = HTMLTagBlock(key: attributeKey, value: attributeValue, content: stringAtSubstring)
                            currentEditingTagBlock!.addAttribute(attributeKey, value: attributeValue, atRange: NSMakeRange(0, stringAtSubstring.length).toRange()!)
                        } else {
                            currentEditingTagBlock!.addAttribute(attributeKey, value: attributeValue, atRange: range.toRange()!,content: stringAtSubstring)
                        }
                    } else {
                        var currentIndex = 0
                        for string in stringsSplitByNewline {
                            if string.isEmpty == false {
                                currentEditingTagBlock = HTMLTagBlock(key: attributeKey, value: attributeValue, content: string)
                                htmlTagBlocks.append(currentEditingTagBlock!)
                            }
                            currentEditingTagBlock = nil
                        }
                    }
                }
            }
        }

        if let actualEditingTagBlock = currentEditingTagBlock {
            htmlTagBlocks.append(actualEditingTagBlock)
        }

        for htmlTagBlock in htmlTagBlocks {
            htmlContent += htmlTagBlock.htmlRepresentation()
        }

        return htmlContent

        if attributedText.string == placeholder {
            return ""
        } else {
            var openingTag = ""
            var closeingTag = ""
            
            let alignment : String = {
                if let actualAlignment = self.textAttribute.textAlignment {
                    switch actualAlignment {
                    case NSTextAlignment.Left:
                        return  "align-left"
                    case NSTextAlignment.Center:
                        return "align-center"
                    case NSTextAlignment.Right:
                        return  "align-right"
                    default:
                        return "align-left"
                    }
                }
                        return "align-left"
                }()

           if let actualFont = self.textAttribute.font {
            switch actualFont {
            case UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline):
                let cssClass = alignment
                openingTag = "<H1 class=\"\(cssClass)\">"
                closeingTag = "</H1>"
            case UIFont.preferredFontForTextStyle(UIFontTextStyleBody):
                let cssClass = alignment
                openingTag = "<p class=\"\(cssClass)\">"
                closeingTag = "</p>"
            case UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline):
                let cssClass = alignment
                openingTag = "<H2 class=\"\(cssClass)\">"
                closeingTag = "</H2>"
            default:
                let cssClass = alignment
                openingTag = "<p class=\"\(cssClass)\">"
                closeingTag = "</p>"
            }

            }

            var html = openingTag
            html += closeingTag
            
            return html
        }
    
    }
    
}