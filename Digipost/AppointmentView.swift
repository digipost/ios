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
import EventKit

@objc class AppointmentView: UIView{

    var appointment: POSAppointment = POSAppointment()

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var infoTitle1: UILabel!
    @IBOutlet weak var infoText1: UILabel!
    @IBOutlet weak var infoTitle2: UILabel!
    @IBOutlet weak var infoText2: UILabel!
    
    let eventStore = EKEventStore()
    var calendars = [EKCalendar]()
    var pickedCalenderIdentifier: String = ""
    let permissionsErrorMessage = "For å kunne legge til en hendelse i kalender må du gi Digipost tilgang til Kalendere, under Personvern i Innstillinger"

    func instanceWithData(appointment: POSAppointment) -> UIView{
        let view = UINib(nibName: "AppointmentView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AppointmentView
        view.appointment = appointment
        view.title.text = appointment.title
        view.subTitle.text = appointment.subTitle
        view.arrivalTime.text = appointment.arrivalTime
        view.place.text = appointment.place
        view.address.text = appointment.address
        view.infoTitle1.text = appointment.infoTitle1
        view.infoText1.text = appointment.infoText1
        view.infoTitle2.text = appointment.infoTitle2
        view.infoText2.text = appointment.infoText2
        view.title.text = appointment.title
        return view
    }
    
    func initWithPermissions() {
        
    }
    
    @IBAction func addToCalendar(_ sender: Any) {
        calendarPermissionsGranted()
        
        let eventTitle = "Innkalling til røntgentime"
        let sender = "Unilabs Røntgen Majorstua"
        let time = "kl 09:00 - 25.07.2017"
        let address = "Kirkeveien 29B, 0555 Oslo"
        let info = "Ikke spis 3 timer før timen. Ta med MR-bilder hvis du har dette tilgjengelig. Etter timen må du vente 30 minutter for eventuelle bivirkninger"
        
        let message = calendarPermissionsGranted() ? getEventMessage(sender:sender, time: time, address: address, info: info) : permissionsErrorMessage
        
        let alertController = UIAlertController(title: "Legg til i kalender", message: message, preferredStyle: .alert)
        
        if calendarPermissionsGranted() {
            let calendar = self.eventStore.defaultCalendarForNewEvents
            alertController.addAction(UIAlertAction(title: "Legg i kalender", style: .default) { (action) in
                self.createEventInCalendar(calendar: calendar, start: self.day(diff: -1), end: self.day(diff: 0), title: eventTitle, address: address, info: info)
                
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Avbryt", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: {})
        })
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func getEventMessage(sender: String, time: String, address:String, info: String) -> String {
        var message = "Fra: \n \(sender)\n\n"
        message.append(time.isEmpty ? "" : "Tid: \n \(time) \n\n")
        message.append(address.isEmpty ? "" : "Hvor: \n \(address) \n\n")
        message.append(info.isEmpty ? "" : "Informasjon: \n \(info)\n\n")
        message.append("\n\n\n")
        return message
    }
    
    @discardableResult func calendarPermissionsGranted() -> Bool {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized: return true
        default: return requestPermissions()
        }
    }
    
    func requestPermissions() -> Bool{
        var permissionsGranted = false 
        eventStore.requestAccess(to: .event, completion: 
            {(granted: Bool, error: Error?) -> Void in
                permissionsGranted = granted
                print("granted: \(granted)")
        })
        return permissionsGranted;
    }
    
    func createEventInCalendar(calendar: EKCalendar, start: Date, end: Date, title: String, address: String, info:String){
        let event = EKEvent(eventStore: eventStore)
        
        event.calendar = calendar
        event.title = title
        event.startDate = start
        event.endDate = end
        event.location = address
        event.notes = info
        
        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
            print("✅ - Event created!")
        } catch {
            print("⛔️ - ERROR! Event failed!")
        }
    }
    
    func day(diff: Int) -> Date {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let day = calendar.date(byAdding: .day, value: diff, to: NSDate() as Date, options: [])!
        return day
    }
    
    private  func instanceFromNib() -> UIView {
        return UINib(nibName: "AppointmentView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
