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

@objc class AppointmentView: UIView, UIPickerViewDataSource, UIPickerViewDelegate{

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
    
    var appointment: POSAppointment = POSAppointment()
    
    var extraHeight = CGFloat(0)
    let eventStore = EKEventStore()
    var calendars = [EKCalendar]()
    static var pickedCalenderIdentifier: String = ""
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
        
        let calendarButtonTitle = NSLocalizedString("metadata add to calendar", comment:"Legg til i kalender")
        view.calendarButton.setTitle(calendarButtonTitle, for: UIControlState.normal)
    
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
        let subtitleHeight = positiveHeightAdjustment(text: appointment.subTitle, width: view.subTitle.frame.width)
        if subtitleHeight > 18 {
            infoTextHeight += subtitleHeight
        }
        view.containerViewHeight.constant += infoTextHeight
        extraHeight += infoTextHeight
    
        calendarPermissionsGranted()
        calendars = eventStore.calendars(for: EKEntityType.event).filter { $0.allowsContentModifications}
        view.layoutIfNeeded()
        return view
    }
        
    func negativeHeightAdjustment() -> CGFloat{
        return CGFloat(-150)
    }
    
    func positiveHeightAdjustment(text:String, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont(name: "Helvetica", size: 15.0)
        label.text = text
        label.sizeToFit()
        
        var heightAdjustment = label.frame.height
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            heightAdjustment -= 20  
        }
        
        return heightAdjustment
    }
    
    @IBAction func addToCalendar(_ sender: Any) {
        let eventTitle = title.text!
        
        let message = calendarPermissionsGranted() ? getEventMessage() : permissionsErrorMessage
        let modalAction = NSLocalizedString("metadata add to calendar", comment:"Legg til i kalender")
        let alertController = UIAlertController(title: modalAction, message: message, preferredStyle: .alert)
        
        if calendarPermissionsGranted() {
            self.calendars = eventStore.calendars(for: EKEntityType.event).filter { $0.allowsContentModifications}
            if self.calendars.count > 1 {
                let frame = CGRect(x: 0, y: 120, width: 270, height: 80)
                let calendarPicker = UIPickerView(frame: frame)
                alertController.message?.append("\n\n\n\n\n\n\n")
                calendarPicker.delegate = self
                calendarPicker.showsSelectionIndicator = true
                alertController.view.addSubview(calendarPicker)
            }
            
            alertController.addAction(UIAlertAction(title: modalAction, style: .default) { (action) in
                let calendar = AppointmentView.pickedCalenderIdentifier.characters.count > 1 && self.calendars.count > 1 ? self.getSelectedCalendar() : self.eventStore.defaultCalendarForNewEvents
                self.createEventInCalendar(calendar: calendar, title: eventTitle)
                
            })
        }
        
        let modalCancel = NSLocalizedString("metadata calendar cancel", comment:"Avbryt")
        alertController.addAction(UIAlertAction(title: modalCancel, style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: {})
        })
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func getSelectedCalendar() -> EKCalendar {
        return calendars.filter { $0.calendarIdentifier == AppointmentView.pickedCalenderIdentifier}.first!
    }
    
    func getEventMessage() -> String {
        var message = ""
        message.append("\(title.text!)\n\(subTitle.text!)\n\n")
        message.append("\(startDate.text!) - \(startTime.text!)")
        return message
    }
    
    @discardableResult func calendarPermissionsGranted() -> Bool {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized: return true
        default: return AppointmentView.requestPermissions()
        }
    }
    
    static func requestPermissions() -> Bool{
        var permissionsGranted = false 
        EKEventStore().requestAccess(to: .event, completion: 
            {(granted: Bool, error: Error?) -> Void in
                permissionsGranted = granted
        })
        return permissionsGranted;
    }
    
    func createEventInCalendar(calendar: EKCalendar, title: String){
        let event = EKEvent(eventStore: self.eventStore)
    
        event.calendar = calendar
        event.title = title
        event.startDate = appointment.startTime
        event.endDate = appointment.endTime
        event.location = appointment.address
        event.notes = "\(arrivalTime.text!) \n\n\(infoTitle1.text!) \n\(infoText1.text!) \n\n\(infoTitle2.text!) \n\(infoText2.text!) "
                
        do {try self.eventStore.save(event, span: .thisEvent, commit: true)} catch {}
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.calendars.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.calendars[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        AppointmentView.pickedCalenderIdentifier = self.calendars[row].calendarIdentifier
    }
    
    private func instanceFromNib() -> UIView {
        return UINib(nibName: "AppointmentView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
