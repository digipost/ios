
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
        let endOfStringAttributes = textComposerModule.attributedText.attributesAtIndex(textComposerModule.attributedText.length - 1 , effectiveRange: nil)
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

    func setFontTrait(fontTrait: UIFontDescriptorSymbolicTraits, enabled: Bool, atRange range: NSRange) {
        var mutableAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString
        attributedText.enumerateAttributesInRange(range, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired) { (attributes, inRange, stop) -> Void in
            if let font = attributes[NSFontAttributeName] as? UIFont {
                var fontDescriptor = font.fontDescriptor()
                let existingTraits = fontDescriptor.symbolicTraits
                let newTraits : UIFontDescriptorSymbolicTraits =  {
                    if enabled {
                        return existingTraits | fontTrait
                    } else {

                        return existingTraits ^ fontTrait
                    }
                    }()
                let newFontDescriptor = fontDescriptor.fontDescriptorWithSymbolicTraits(newTraits)
                let newFont  = UIFont(descriptor: newFontDescriptor!, size: font.pointSize )
                mutableAttributedString.addAttribute(NSFontAttributeName, value: newFont, range: range)
            }
        }

        attributedText = mutableAttributedString
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
        var htmlTagBlock = HTMLTagBlock(type: self.type, content: self.attributedText.string)
        attributedText.enumerateAttributesInRange(NSMakeRange(0, attributedText.string.length), options: NSAttributedStringEnumerationOptions.allZeros) { (attributeDict, range, stop) -> Void in
            for (attributeKey, attributeValue) in attributeDict {
                // just skip the font attribute that is the outer main tag block
                if attributeKey == NSFontAttributeName {
                    if let attributeFont = attributeValue as? UIFont {
                        if HTMLTagBlock.isHTMLTagBlockFont(attributeFont) {
                            continue
                        }
                    }
                }

                htmlTagBlock.addAttribute(attributeKey, value: attributeValue, atRange: range.toRange()!)
            }
        }

        return htmlTagBlock.htmlRepresentation()

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