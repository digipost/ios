//
//  ComposerModuleParser.swift
//  Digipost
//
//  Created by Henrik Holmsen on 15.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

class ComposerModuleParser {
    
    class func parseComposerModuleContentToHTML(modules: [ComposerModule], response: (htmlString: String?)->()){
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            
            var internalStylesheet:NSString = ""
            if let stylesheetPath = NSBundle.mainBundle().pathForResource("stylesheet", ofType: "css"){
                do{
                    let stylesheetContent = try NSString(contentsOfFile: stylesheetPath, encoding: NSASCIIStringEncoding)
                    internalStylesheet = stylesheetContent
                }catch let error{
                    
                }
            }
            
            var html = "<html><head><style>\(internalStylesheet)</style></head><body><div>"
            
            for module in modules {
                html += module.htmlRepresentation() as String
            }
            
            html += "</div></body></html>"
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                response(htmlString: html)
            })
            
        })
        
    }
    
}