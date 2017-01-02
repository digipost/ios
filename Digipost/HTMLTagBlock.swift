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

enum HTMLTagBlockType {
    case paragraph
    case h1
    case h2
    case h3
    case unknown
}

struct HTMLTagBlock : HTMLRepresentable {
    
    let tag : HTMLTag
    var range : NSRange
    
    init(tag: HTMLTag, range: NSRange) {
        self.tag = tag
        self.range = range
    }
    
    init(key: NSObject, value: AnyObject, range: NSRange) {
        self.tag = HTMLTag(attribute: key as! String, value: value)
        self.range = range
    }
    
    func htmlRepresentation(_ inString: NSString) -> NSString {
    //    var representation = (inString as NSString).mutableCopy() as! NSMutableString
    //    var newContent = ""
    //    let regex = try! NSRegularExpression(pattern: "</?[a-å][a-å0-9]*[^<>]*>", options: NSRegularExpressionOptions())
        
        if range.location + range.length < inString.length {
            let subString = inString.substring(with: range)
            return "\(tag.startTag)\(subString)\(tag.endTag)" as NSString
        }
        return "\(tag.startTag)\(tag.endTag)" as NSString
    }
    
    
    static func tagBlocks(_ key: NSObject, value: AnyObject, range: NSRange) -> [HTMLTagBlock] {
        var tagBlocks = [HTMLTagBlock]()
        
        let tags = HTMLTag.tags(key, value: value)
        for tag in tags {
            let tagBlock = HTMLTagBlock(tag: tag, range: range)
            tagBlocks.append(tagBlock)
        }
        
        return tagBlocks
    }
    
    static func isHTMLTagBlockFont(_ font: UIFont) -> Bool {
        if font.isEqual(UIFont.headlineH1()) {
            return true
        } else if font.isEqual(UIFont.paragraph()) {
            return true
        }
        
        return false
    }
    
    
    
    
}
