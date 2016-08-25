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

import UIKit

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha:CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: alpha)
    }
    
    class func digipostSpaceGrey () -> UIColor {
        return UIColor(r: 64, g: 66, b: 69)
    }
    
    class func digipostGreyOne () -> UIColor {
        return UIColor(r: 239, g: 66, b: 69)
    }
    
    class func digipostDocumentListBackground() -> UIColor{
        return UIColor(r: 248,g: 248, b: 248)
    }
    class func digipostDocumentListDivider() -> UIColor{
        return UIColor(r: 222,g: 222, b: 222)
    }
    
    class func digipostProfileViewBackground () -> UIColor {
        return UIColor(r: 232, g: 232, b: 232)
    }
    
    class func digipostProfileViewInitials () -> UIColor {
        return UIColor(r: 141, g: 141, b: 141)
    }
    
    class func digipostProfileTextColor () -> UIColor {
        return UIColor(r: 77, g: 79, b: 83)
    }
    
    class func digipostAccountViewBackground () -> UIColor {
        return UIColor(r: 248, g: 248, b: 248)
    }
    
    class func digipostAccountCellSelectBackground () -> UIColor {
        return UIColor(r: 230, g: 230, b: 230)
    }
    
    class func digipostLogoutButtonTextColor () -> UIColor {
        return UIColor(r: 255, g: 235, b: 235, alpha: 0.85)
    }
    
}
