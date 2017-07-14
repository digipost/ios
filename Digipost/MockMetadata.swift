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
        
        mockdataArray.append(POSMetadata(type: "appointment", json: getMockAppointment()))
        mockdataArray.append(POSMetadata(type: "appointment", json: getMockAppointment()))
        
        return mockdataArray
    }
    
    func getMockAppointment() -> Dictionary<String, AnyObject> {
        var appointment = Dictionary<String, AnyObject>()
        appointment["type"] = "appointment" as AnyObject
        appointment["subTitle"] = "MR-Undersøkelse av høyre kne" as AnyObject
        appointment["startTime"] = "2017-07-14T13:08:05+02:00" as AnyObject
        appointment["endTime"] = "2017-07-14T15:08:05+02:00" as AnyObject
        appointment["arrivalTime"] = "Kom 10 minutter før" as AnyObject
        appointment["place"] = "Hovedinngangen" as AnyObject
        
        var place = Dictionary<String, String>()
        place["city"] = "Oslo"
        place["postalCode"] = "0101"
        place["streetAddress"] = "Storgata 2"
        appointment["address"] = place as AnyObject
        
        var infoList = [[String: String]]()
        
        infoList.append(["title": "Forberedelser:","text": "Husk å ta med gamle røntgen-bilder hvis du har dette lett tilgjengelig.Husk å ta med gamle røntgen-bilder hvis du har dette tilgjengelig.Husk å ta med gamle røntgen-bilder hvis du har dette tilgjengelig" ])
        
        infoList.append(["title": "Informasjon:","text": "Egenandel for undersøkelsen er kr.245,-, fritak for barn under 16 år og alle med frikort. CD med bilder av undersøkelsen koster kr.70,- pr stk. Betaling via bankterminal eller kontant ved frammøte...!"])
        
        appointment["info"] = infoList as AnyObject
        
        return appointment
    }
}
