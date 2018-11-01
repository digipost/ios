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

@objc class POSContactInfo : NSObject, NSCoding{
    
    var extendedEmail: [POSEmail]?
    var extendedPhone: POSPhone?

    init(extendedEmail: [POSEmail], extendedPhone: POSPhone) {
        self.extendedEmail = extendedEmail
        self.extendedPhone = extendedPhone
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let extendedEmail = aDecoder.decodeObject(forKey: "extendedEmail") as! [POSEmail]
        let extendedPhone = aDecoder.decodeObject(forKey: "extendedPhone") as! POSPhone
        
        self.init(extendedEmail: extendedEmail, extendedPhone: extendedPhone)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(extendedEmail, forKey: "extendedEmail")
        aCoder.encode(extendedPhone, forKey: "extendedPhone")
    }
}

