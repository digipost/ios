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

@objc class MockMetadata : NSObject{
    
    func getMockAppointmentArray() -> [POSMetadata] {
        var mockdataArray = [POSMetadata]()
        
        var ap1 = mockAppointment(title: "Innkalling til røntgen")
        var ap2 = mockAppointment(title: "Tannlegetime")
        var ap3 = mockAppointment(title: "Kinoavtale")
        
        mockdataArray.append(POSMetadata(type: ap1["type"] as! String, json: ap1))
        mockdataArray.append(POSMetadata(type: ap2["type"] as! String, json: ap2))
        mockdataArray.append(POSMetadata(type: ap3["type"] as! String, json: ap3))
        
        return mockdataArray
    }
    
    func mockAppointment(title: String) -> Dictionary<String, Any> {
        var appointment = Dictionary<String, AnyObject>()
        
        appointment["type"] = "appointment" as AnyObject
        appointment["title"] = title as AnyObject
        appointment["important"] = "Alt er viktig, se beskrivelse" as AnyObject
        appointment["description"] = "Ikke spis 3 timer før timen. Ta med MR-bilder hvis du har dette tilgjengelig. Etter timen må du vente 30 minutter for eventuelle bivirkninger" as AnyObject
        appointment["start_time"] = "2017-06-16T09:41:01.846+02:00" as AnyObject
        appointment["end_time"] = "2017-06-17T09:41:01.846+02:00" as AnyObject
        
        var place = Dictionary<String, String>()
        place["city"] = "Oslo"
        place["postalCode"] = "0101"
        place["streetAddress"] = "Storgata 2"
        appointment["place"] = place as AnyObject

        return appointment
    }
}
