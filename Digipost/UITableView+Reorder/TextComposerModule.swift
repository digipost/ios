
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
    var attributedText: NSAttributedString!
    var styling = [TextAttribute]()

    class func headlineModule() -> TextComposerModule {
        var textComposerModule = TextComposerModule()
        textComposerModule.attributedText = NSAttributedString(string: " ", attributes: [NSFontAttributeName : UIFont.headlineH1()])
        return textComposerModule
    }

    class func paragraphModule() -> TextComposerModule {
        var textComposerModule = TextComposerModule()
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
        var mutableAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString
        let endOfStringAttributes = attributedText.attributesAtIndex(attributedText.length - 1 , effectiveRange: nil)
        let appendingAttributedString = NSAttributedString(string: characters, attributes: endOfStringAttributes)
        mutableAttributedString.appendAttributedString(appendingAttributedString)
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
        super.init()
    }

    init(moduleWithFont font: UIFont) {
        textAttribute = TextAttribute(font: font, textAlignment: .Left)
        super.init()
    }

    override func htmlRepresentation() -> String {

        var (htmlTagBlock, font) : (HTMLTagBlock, UIFont) = {
            var htmlTagBlock : HTMLTagBlock?
            var htmlTagBlockFont : UIFont?
            self.attributedText.enumerateAttribute(NSFontAttributeName, inRange: NSMakeRange(0, self.attributedText.string.length), options: NSAttributedStringEnumerationOptions.allZeros) { (font, range, stop) -> Void in
                if let actualFont = font as? UIFont {
                    let textAtRange = (self.attributedText.string as NSString).substringWithRange(range)
                    htmlTagBlock = HTMLTagBlock(font: actualFont, content: textAtRange)
                    htmlTagBlockFont = actualFont
                }
            }
            return (htmlTagBlock!, htmlTagBlockFont!)
        }()

        attributedText.enumerateAttributesInRange(NSMakeRange(0, attributedText.string.length), options: NSAttributedStringEnumerationOptions.allZeros) { (attributeDict, range, stop) -> Void in
            for (attributeKey, attributeValue) in attributeDict {
                // just skip the font attribute that is the outer main tag block
                if attributeKey == NSFontAttributeName {
                    if attributeValue.isEqual(font) {
                        continue
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

//            if let text = self.text {
//
//                for c in text{
//                    if c == "\n"{
//                        html += "<br>"
//                    } else {
//                        html += "\(c)"
//                    }
//                }
//            }

            html += closeingTag
            
            return html
        }
    
    }
    
}