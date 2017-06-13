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

@objc class POSMetadataMapper : NSObject{
    
    static func get(metadata : POSMetadata) -> Any? {
        if metadata.type == POSMetadata.TYPE.APPOINTMENT {
            return appointment(metadata: metadata)
        }
        return POSMetadataObject(type: POSMetadata.TYPE.NIL)
    }
    
    static func appointment(metadata :POSMetadata) -> POSAppointment {
        if metadata.json.count > 0 {
            let title = metadata.json["title"] as! String
            let important = metadata.json["important"] as! String
            let textDescription = metadata.json["description"] as! String
            let startTime = stringToDate(timeString: metadata.json["start_time"] as! String)
            let endTime = stringToDate(timeString: metadata.json["end_time"] as! String)

            var city = ""
            var postalCode = ""
            var streetAddress = ""
            
            if let location = metadata.json["place"] as? Dictionary<String, String> {
                city = location["city"]!
                postalCode = location["postalCode"]!
                streetAddress = location["streetAddress"]!
            }
                        
            return POSAppointment(title: title, important: important, textDescription: textDescription, startTime: startTime, endTime: endTime, city:city, postalCode:postalCode, streetAddress:streetAddress)
        }
        return POSMetadataObject(type: POSMetadata.TYPE.NIL) as! POSAppointment
    }
    
    static func stringToDate(timeString: String) -> Date{
        return Date()
    }
}
