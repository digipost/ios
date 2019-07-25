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
    
    static func get(metadata : POSMetadata, creatorName: String) -> Any? {
        if metadata.type == POSMetadata.TYPE.APPOINTMENT {
            return parseAppointment(metadata: metadata, creatorName: creatorName)
        }else if metadata.type == POSMetadata.TYPE.EXTERNAL_LINK {
            return parseExternalLink(metadata: metadata)
        }else if metadata.type == POSMetadata.TYPE.EVENT {
            return parseEvent(metadata: metadata)
        }
        
        return POSMetadataObject(type: POSMetadata.TYPE.NIL)
    }
    
    
    static func parseExternalLink(metadata: POSMetadata) -> POSExternalLink {
        let externalLink = POSExternalLink() 
        
        if let desc = metadata.json["description"] as? String {
            externalLink.text = desc
        }
        
        if let buttonText = metadata.json["buttonText"] as? String {
            externalLink.buttonText = buttonText
        }else{
            externalLink.buttonText = NSLocalizedString("metadata externalink default button", comment: "Gå videre")
        }
        
        if let url = metadata.json["url"] as? String {
            externalLink.url = url
        }

        if let urlIsActive = metadata.json["urlIsActive"] as? Bool {
            externalLink.urlIsActive = urlIsActive
        }
        
        if let deadline =  metadata.json["deadline"] as? String {
            if let deadlineDate = stringToDate(timeString: deadline) {
                externalLink.deadline = deadlineDate
                externalLink.deadlineText = deadlineDate.dateOnly()
            }
        }
        
        return externalLink        
    }
    
    private static func parseEvent(metadata: POSMetadata) -> POSEvent {
        let event = POSEvent()
        
        if let place = metadata.json["place"] as? String {
            event.place = place
        }
        
        if let location = metadata.json["address"] as? Dictionary<String, Any> {
            if let streetAdress = location["streetAddress"] as? String {
                event.streetAddress = streetAdress
            }
            if let postalCode = location["postalCode"] as? String {
                event.postalCode = postalCode
            }
            if let city = location["city"] as? String {
                event.city = city
            }
            event.address = "\(event.streetAddress) \n\(event.postalCode) \(event.city)"
        }
        
        if let timeframes = metadata.json["time"] as? [Dictionary<String, Any>]{
            for timeframe in timeframes {
                if let startTime = timeframe["startTime"] as? String, let endTime = timeframe["endTime"] as? String {
                    if let startTimeDate = stringToDate(timeString: startTime), let endTimeDate = stringToDate(timeString: endTime) {
                        event.timeframes.append(POSTimeframe(startTime: startTimeDate, endTime:endTimeDate ))
                    }
                }
            }
        }
        
        if let infoList = metadata.json["info"] as? [[String: Any]] {
            for info in infoList {
                event.info.append(POSMetadataInfo(title: info["title"] as! String, text: info["text"] as! String))
            }
        }
        
        
        return event
    }
    
    private static func parseAppointment(metadata: POSMetadata, creatorName: String) -> POSAppointment {            
        let appointment = POSAppointment()
        appointment.creatorName = creatorName
        appointment.title = "Du har fått en innkalling fra \(creatorName)"
        
        if let subTitle = metadata.json["subTitle"] as? String {
            appointment.subTitle = subTitle
        }
        
        if let startTime = metadata.json["startTime"] as? String {
            if let startTimeDate = stringToDate(timeString: startTime) {
                appointment.startTime = startTimeDate
            }
        }
        
        if let endTime = metadata.json["endTime"] as? String {
            if let endTimeDate = stringToDate(timeString: endTime) {
                appointment.endTime = endTimeDate
            }
        }
        
        if let arrivalTime = metadata.json["arrivalTime"] as? String {
            if let arrivalTimeDate = stringToDate(timeString: arrivalTime) {
                appointment.arrivalTimeDate = arrivalTimeDate
            }else{
                appointment.arrivalTime = arrivalTime
            }
        }
        
        if let place = metadata.json["place"] as? String {
            appointment.place = place
        }
        
        if let location = metadata.json["address"] as? Dictionary<String, String> {
            if let streetAdress = location["streetAddress"] {
                appointment.streetAddress = streetAdress
            }
            
            if let postalCode = location["postalCode"] {
                appointment.postalCode = postalCode
            }
            
            if let city = location["city"] {
                appointment.city = city
            }
            
            appointment.address = "\(appointment.streetAddress) \n\(appointment.postalCode) \(appointment.city)"
        }
        
        if let infoList = metadata.json["info"] as? [[String: String]] {
            if infoList.count > 0 {
                if let infoTitle = infoList[0]["title"], let infoText = infoList[0]["text"] {
                    appointment.infoTitle1 = infoTitle
                    appointment.infoText1 = infoText
                }
            }
            
            if infoList.count > 1 {
                if let infoTitle = infoList[1]["title"], let infoText = infoList[1]["text"] {
                    appointment.infoTitle2 = infoTitle
                    appointment.infoText2 = infoText
                }
            }
        }
        
        return appointment
    }
    
    static func stringToDate(timeString: String) -> Date?{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
        if let date = formatter.date(from: timeString) {
            return date
        }
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        if let date = formatter.date(from: timeString) {
            return date
        }
        return nil
    }
}
