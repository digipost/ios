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
    @IBOutlet weak var startTimeTitle: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var arrivalTimeTitle: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var infoTitle1: UILabel!
    @IBOutlet weak var infoText1: UILabel!
    @IBOutlet weak var infoTitle2: UILabel!
    @IBOutlet weak var infoText2: UILabel!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var calendarButton: UIButton!
    
    var extraHeight = CGFloat(0)
    let eventStore = EKEventStore()
    var calendars = [EKCalendar]()
    var pickedCalenderIdentifier: String = ""
    let permissionsErrorMessage = "For å legge til hendelser i kalenderen din, må du gi Digipost tilgang til Kalendere. Dette kan du endre under Personvern i Innstillinger."

    func instanceWithData(appointment: POSAppointment) -> UIView{
        let view = UINib(nibName: "AppointmentView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AppointmentView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.appointment = appointment
        view.title.text = appointment.title
        
        if appointment.subTitle.characters.count > 1 {
            view.subTitle.text = appointment.subTitle
        }

        view.startTimeTitle.text = NSLocalizedString("metadata start time title", comment:"Time:")
        view.startDate.text = appointment.startTime.dateOnly()
        view.startTime.text = "kl \(appointment.startTime.timeOnly())"
        
        view.arrivalTimeTitle.text = NSLocalizedString("metadata arrival time title", comment:"Oppmøte:")
        if appointment.arrivalTime.characters.count > 0 {
            view.arrivalTime.text = appointment.arrivalTime
        }else{
            view.arrivalTime.text = "kl \(appointment.arrivalTimeDate.timeOnly())"
        }
                
        view.placeTitle.text = NSLocalizedString("metadata location title", comment:"Sted:")
        view.place.text = appointment.place
        view.address.text = appointment.address
    
        var infoTextHeight = CGFloat(0)
        if appointment.infoText1.length > 1 {
            view.infoTitle1.text = appointment.infoTitle1
            view.infoText1.text = appointment.infoText1
            infoTextHeight += positiveHeightAdjustment(text: appointment.infoText1, width: view.infoText1.frame.width)
        }else{
            infoTextHeight += negativeHeightAdjustment()
        }
        
        if appointment.infoText2.length > 1 {
            view.infoTitle2.text = appointment.infoTitle2
            view.infoText2.text = appointment.infoText2
            infoTextHeight += positiveHeightAdjustment(text: appointment.infoText2, width: view.infoText2.frame.width)
        }
        
        view.containerViewHeight.constant += infoTextHeight + positiveHeightAdjustment(text: appointment.subTitle, width: view.subTitle.frame.width)
        extraHeight += infoTextHeight
        view.layoutIfNeeded()
        
        return view
    }
    
    func negativeHeightAdjustment() -> CGFloat{
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        if screenHeight < 600.0 {
            return CGFloat(-200)
        }else if screenHeight < 700 {
            return CGFloat(-100)
        }else if screenHeight > 700 {
           return CGFloat(-30)
        }else{
            return CGFloat(0)
        }
    }
    
    func positiveHeightAdjustment(text:String, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont(name: "Helvetica", size: 13.0)
        label.text = text
        label.sizeToFit()
        
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        if screenHeight < 600.0 {
            return label.frame.height*0.4
        }else if screenHeight < 700 {
            return label.frame.height*0.8
        }else if screenHeight > 700 {
            return label.frame.height*1.3
        }
        
        return label.frame.height
    }

    
    @IBAction func addToCalendar(_ sender: Any) {
        calendarPermissionsGranted()
        
        let eventTitle = "Innkalling til røntgentime"
        let sender = appointment.creatorName
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
