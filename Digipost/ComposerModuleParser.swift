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

class ComposerModuleParser {
    
    class func parseComposerModuleContentToHTML(_ modules: [ComposerModule], response: @escaping (_ htmlString: String?)->()){
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
            
            var internalStylesheet:NSString = ""
            if let stylesheetPath = Bundle.main.path(forResource: "stylesheet", ofType: "css"){
                do{
                    let stylesheetContent = try NSString(contentsOfFile: stylesheetPath, encoding: String.Encoding.ascii.rawValue)
                    internalStylesheet = stylesheetContent
                }catch _{
                    
                }
            }
            
            var html = "<html><head><style>\(internalStylesheet)</style></head><body><div>"
            
            for module in modules {
                html += module.htmlRepresentation() as String
            }
            
            html += "</div></body></html>"
            
            DispatchQueue.main.async(execute: { () -> Void in
                response(html)
            })
            
        })
        
    }
    
}
