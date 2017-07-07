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
        
        return mockdataArray
    }
    
    func getMockAppointment() -> Dictionary<String, AnyObject> {
        var appointment = Dictionary<String, AnyObject>()
        appointment["type"] = "appointment" as AnyObject
        appointment["subTitle"] = "MR-Undersøkelse av høyre kne" as AnyObject
        appointment["startTime"] = "2017-06-16T09:41:01.846+02:00" as AnyObject
        appointment["endTime"] = "2017-06-17T09:41:01.846+02:00" as AnyObject
        appointment["arrivalTime"] = "Kom 10 minutter før" as AnyObject
        appointment["place"] = "Hovedinngangen" as AnyObject
        
        var place = Dictionary<String, String>()
        place["city"] = "Oslo"
        place["postalCode"] = "0101"
        place["streetAddress"] = "Storgata 2"
        appointment["adress"] = place as AnyObject
        
        var infoList = [[Dictionary<String, String>]]()
        infoList.append([["title": "Forberedelse"],["text": "Husk å ta med gamle røntgen-bilder hvis du har dette tilgjengelig"]])
        infoList.append([["title": "Informasjon"],["text": "Egenandel for undersøkelsen er kr.245,-, fritak for barn under 16 år og alle med frikort. CD med bilder av undersøkelsen koster kr.70,- pr stk. Betaling via bankterminal eller kontant ved frammøte. Ønsker du å reservere deg mot SMS varsling benytt vår nettside www.unilabs.no. For undersøkelser som ikke avbestilles innen 24 timer før oppsatt time, avkreves et gebyr etter gjeldende"]])
        appointment["info"] = infoList as AnyObject
        
        return appointment
    }
}
