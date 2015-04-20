//
//  ComposerTextModule.swift
//  Digipost
//
//  Created by Henrik Holmsen on 14.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation
import UIKit

class TextComposerModule: ComposerModule {
    
    let font: UIFont
    var textAlignment: NSTextAlignment
    var text: String?
    
    init(moduleWithFont font: UIFont) {
        self.font = font
        textAlignment = .Left
        super.init()
    }
    
    override func htmlRepresentation() -> String {
        
        var openingTag = ""
        var closeingTag = ""
        var alignment = ""
        
        switch textAlignment{
        case NSTextAlignment.Left:
            alignment = "left"
        case NSTextAlignment.Center:
            alignment = "center"
        case NSTextAlignment.Right:
            alignment = "right"
        default:
            alignment = "left"
        }
        
        switch font{
        case UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline):
            let cssClass = ""
            openingTag = "<H1 class=\"\(cssClass)\" style=\"text-align: \(alignment)\">"
            closeingTag = "</H1>"
        case UIFont.preferredFontForTextStyle(UIFontTextStyleBody):
            let cssClass = ""
            openingTag = "<p class=\"\(cssClass)\"  style=\"text-align: \(alignment)\">"
            closeingTag = "</p>"
        case UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline):
            let cssClass = ""
            openingTag = "<H2 class=\"\(cssClass)\"  style=\"text-align: \(alignment)\">"
            closeingTag = "</H2>"
        default:
            let cssClass = ""
            openingTag = "<p>"
            closeingTag = "</p>"
        }
        
        
        var html = openingTag
        
        if let text = self.text {
            
            for c in text{
                if c == "\n"{
                    html += "<br>"
                } else {
                    html += "\(c)"
                }
            }
        }
        
        html += closeingTag
        
        return html
    }
    
}