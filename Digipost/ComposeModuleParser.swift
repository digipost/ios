//
//  ComposeModuleParser.swift
//  Digipost
//
//  Created by Henrik Holmsen on 15.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

class ComposerModuleParser{
    
    class func parseComposerModuleContentToHTML(modules: [ComposerModule], response: (htmlString: String?)->(), error: (error: String?)->()){
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            
            if self.isValidContent(modules){
                
                var html = "<html><body>"
                
                for module in modules {
                    
                    switch module.type{
                        
                    case .ImageModule:
                        
                        if let imageModule = module as? ComposerImageModule {
                            html += self.composerImageModuleHTMLRepresentation(imageModule)
                        }
                        
                    case .TextModule:
                        if let textModule = module as? ComposerTextModule {
                            html += self.composerTextModuleHTMLRepresentation(textModule)
                        }
                    }
                    
                }
                
                html += "</body></html>"
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    response(htmlString: html)
                })
                
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    error(error: "illegal mark up found")
                })
                
            }
        })
        
    }
    
    class func composerTextModuleHTMLRepresentation(textModule: ComposerTextModule) -> String {
        
        var openingTag = ""
        var closeingTag = ""
        var alignment = ""
        
        if let textAlignment = textModule.textAlignment{
            
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
        } else {
            alignment = "left"
        }
        
        if let font = textModule.font{
            
            switch font{
            case UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline):
                openingTag = "<H1 style=\"text-align: \(alignment)\">"
                closeingTag = "</H1>"
            case UIFont.preferredFontForTextStyle(UIFontTextStyleBody):
                openingTag = "<p style=\"text-align: \(alignment)\">"
                closeingTag = "</p>"
            case UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline):
                openingTag = "<H2 style=\"text-align: \(alignment)\">"
                closeingTag = "</H2>"
            case UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote):
                openingTag = "<sup style=\"text-align: \(alignment)\">"
                closeingTag = "</sup>"
            case UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1):
                openingTag = "<caption style=\"text-align: \(alignment)\">"
                closeingTag = "</caption>"
            default:
                openingTag = "<p>"
                closeingTag = "</p>"
            }
        }
        
        var html = openingTag
        
        if let text = textModule.text {
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
    
    class func composerImageModuleHTMLRepresentation(imageModule: ComposerImageModule) -> String {
        
        if let image = imageModule.image{
            let base64ImageString = image.base64Representation
            return "<img src=\"data:image/png;base64,\(base64ImageString)\" alt=\"html_inline_image.png\" title=\"html_inline_image.png\" style=\"width:100%;\">"
        } else {
            return ""
        }
    }
    
    private class func isValidContent(module: ComposerTextModule) -> Bool{
        return true
    }
    
    private class func isValidContent(modules: [ComposerModule]) -> Bool{
        
        let invalidTags = ["<script>","<iframe>","<a href>"]
        var isValid = true
        
        for module in modules {
            
            switch module.type{
                
            case .TextModule:
                
                if let textModule = module as? ComposerTextModule{
                    
                    for invalidTag in invalidTags{
                        if textModule.text!.rangeOfString(invalidTag) != nil{
                            isValid = false
                        }
                    }
                    
                }
                
            case .ImageModule:
                continue
            }

        }
        
        return isValid
    }
    
    
}