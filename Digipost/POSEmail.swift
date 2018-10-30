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

@objc class POSEmail : NSObject, NSCoding{

    var email: String = ""
    var verified: Bool = false
    
    init(email: String, verified: Bool) {
        self.email = email
        self.verified = verified
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let email = aDecoder.decodeObject(forKey: "email") as! String
        let verified = aDecoder.decodeObject(forKey: "verified") as! Bool
        
        self.init(email: email, verified: verified)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(email, forKey: "email")
        aCoder.encode(verified, forKey: "verified")
        
    }
}
