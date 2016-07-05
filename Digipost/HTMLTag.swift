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

enum HTMLTagType : String {
    case Bold = "<b>"
    case Italic = "<i>"
    case H1   = "<h1>"
    case Paragraph   = "<p>"
    case Unknown   = ""
}

struct HTMLTag {

    let type : HTMLTagType


    init(type: HTMLTagType) {
        self.type = type
    }

    init(attribute: NSObject, value: AnyObject) {

        self.type = {

            switch attribute {
            case NSFontAttributeName:
                if let actualFont = value as? UIFont {
                    if actualFont == UIFont.headlineH1() {
                        return HTMLTagType.H1
                    }

                    let symbolicTraits = actualFont.fontDescriptor().symbolicTraits
                    if symbolicTraits.contains(.TraitItalic) {
                        return HTMLTagType.Italic
                    } else if symbolicTraits.contains(.TraitBold) {
                        return HTMLTagType.Bold
                    }
                    return HTMLTagType.Paragraph
                }
                return HTMLTagType.Unknown
            default:
                return HTMLTagType.Paragraph
            }}()
    }

    static func tags(attribute: NSObject, value: AnyObject) -> [HTMLTag] {
        var tags = [HTMLTag]()

        if let actualFont = value as? UIFont {
            if actualFont == UIFont.headlineH1() {
                tags.append(HTMLTag(type: HTMLTagType.H1))
                return tags
            }
            let symbolicTraits = actualFont.fontDescriptor().symbolicTraits
            if symbolicTraits.contains(.TraitItalic) {
                tags.append(HTMLTag(type: HTMLTagType.Italic))
            }
            if symbolicTraits.contains(.TraitBold) {
                tags.append(HTMLTag(type: HTMLTagType.Bold))
            }
        }
        if tags.count == 0 {
            tags.append(HTMLTag(type: HTMLTagType.Paragraph))
        }

        return tags
    }

    var startTag : String {
        return type.rawValue
    }
    
    var endTag : String {
        var tag = type.rawValue
        tag.insert("/", atIndex: type.rawValue.startIndex.successor())
        return tag
    }

}