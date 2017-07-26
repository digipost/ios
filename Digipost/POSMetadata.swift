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

@objc class POSMetadata : NSObject, NSCoding{
    
    struct TYPE {
        static let NIL = "nil"
        static let RESIDENCE = "Residence"
        static let APPOINTMENT = "Appointment"
    }
    
    var type:  String = ""
    var json: Dictionary<String, Any> = [:]
    
    init(type: String, json: Dictionary<String, Any>){
        self.type = type
        self.json = json
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let type = aDecoder.decodeObject(forKey: "type") as! String
        let json = aDecoder.decodeObject(forKey: "json") as! Dictionary<String, Any>
        self.init(type: type, json: json)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(type, forKey: "type")
        aCoder.encode(json, forKey: "json")
    }
}
