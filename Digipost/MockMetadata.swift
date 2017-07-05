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
        
        mockdataArray.append(POSMetadata(type: "appointment", json: getMockAppointment(title: "Du har fått en innkalling fra Unilabs Røntgen Majorstua", important: "Ikke spis 6 timer før")))
        mockdataArray.append(POSMetadata(type: "appointment", json: getMockAppointment(title: "Du skal i militæret!", important: "Ikke gjør noe dumt!")))
        return mockdataArray
    }
    
    func getMockAppointment(title: String, important: String) -> Dictionary<String, AnyObject> {
        var appointment = Dictionary<String, AnyObject>()
        appointment["type"] = "appointment" as AnyObject
        appointment["title"] = title as AnyObject
        appointment["important"] = important as AnyObject
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
