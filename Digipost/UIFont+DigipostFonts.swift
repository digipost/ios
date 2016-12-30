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
import UIKit

extension UIFont {
    
    class func commonWebFonts () -> [UIFont] {
        return [UIFont]()
    }
    
    class func digipostRegularFont() -> UIFont {
        let regularFont = UIFont(name: "HelveticaNeue", size: 17)
        return regularFont!
    }
    
    class func digipostBoldFont() -> UIFont? {
        let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 17)
        return boldFont!
    }
    
    // debug method used when you are looking for custom font names
    class func debugToFindNameOfCustomFonts(){
        let familyNamesArray : NSArray = UIFont.familyNames as NSArray
        familyNamesArray.enumerateObjects { (object , index, stop) -> Void in
            let familyName = object as! NSString
            let names : NSArray = UIFont.fontNames(forFamilyName: familyName as String)
            print(object)
            names.enumerateObjects({ (obj , i, stop) -> Void in
                print(obj)
            })
        }
    }
}
