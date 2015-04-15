//
//  ComposerModuleParser.swift
//  Digipost
//
//  Created by Henrik Holmsen on 15.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

class ComposerModuleParser{
    
    class func parseComposerModuleContentToHTML(modules: [ComposerModule], response: (htmlString: String?)->()){
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in

                var html = "<html><body>"
                
                for module in modules {
                    
                    if let imageModule = module as? ImageComposerModule {
                        html += imageModule.htmlRepresentation()
                    }
                    
                    if let textModule = module as? TextComposerModule {
                        html += textModule.htmlRepresentation()
                    }
                    
                }
                
                html += "</body></html>"
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    response(htmlString: html)
                })
            
        })
        
    }
    
}