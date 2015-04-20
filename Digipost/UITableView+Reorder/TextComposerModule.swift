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
        
        let alignment : String = {
            switch self.textAlignment{
        case NSTextAlignment.Left:
            return  "align-left"
        case NSTextAlignment.Center:
            return "align-center"
        case NSTextAlignment.Right:
            return  "align-right"
        default:
            return "align-left"
        }
        }()
        
        switch font{
        case UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline):
            let cssClass = alignment
            openingTag = "<H1 class=\"\(cssClass)\""
            closeingTag = "</H1>"
        case UIFont.preferredFontForTextStyle(UIFontTextStyleBody):
            let cssClass = alignment
            openingTag = "<p class=\"\(cssClass)\""
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