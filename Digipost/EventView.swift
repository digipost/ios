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

@objc class EventView: MetadataView, UIPickerViewDataSource, UIPickerViewDelegate{

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var startTimeTitle: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var arrivalTimeTitle: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var infoTitle1: UILabel!
    @IBOutlet weak var infoText1: UILabel!
    @IBOutlet weak var infoTitle2: UILabel!
    @IBOutlet weak var infoText2: UILabel!
    @IBOutlet weak var infoTitle3: UILabel!
    @IBOutlet weak var infoText3: UILabel!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var buttomDivider: UIView!
    @IBOutlet weak var openMapsButton: UIButton!
    
    var event: POSEvent = POSEvent()

    @objc var extraHeight = CGFloat(0)
    let eventStore = EKEventStore()
    var calendars = [EKCalendar]()
    static var pickedCalenderIdentifier: String = ""
    let permissionsErrorMessage = "For å legge til hendelser i kalenderen din, må du gi Digipost tilgang til Kalendere. Dette kan du endre under Personvern i Innstillinger."

    @objc func instanceWithData(event: POSEvent) -> UIView{
        let view = UINib(nibName: "EventView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EventView

        view.translatesAutoresizingMaskIntoConstraints = false
        view.event = event
        view.title.attributedText = attributedString(text: event.title, lineSpacing: customTitleLineSpacing, minimumLineHeight: minimumTitleLineHeight)
        
        if event.subTitle.characters.count > 1 {
            view.subTitle.attributedText = attributedString(text: event.subTitle, lineSpacing: customTitleLineSpacing, minimumLineHeight: minimumTitleLineHeight)
        }

        view.startTimeTitle.text = NSLocalizedString("metadata start time title", comment:"Time:")
        let timeAndDateString = "kl \(event.startTime.timeOnly())"+"\n"+event.startTime.dateOnly()
        view.startTime.attributedText = attributedString(text: timeAndDateString, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        
        view.arrivalTimeTitle.text = NSLocalizedString("metadata arrival time title", comment:"Oppmøte:")
        if event.arrivalTime.characters.count > 0 {
            view.arrivalTime.attributedText = attributedString(text: event.arrivalTime,  lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        }else{
            view.arrivalTime.text = "kl \(event.arrivalTimeDate.timeOnly())"
        }
        
        view.openMapsButton.setTitle(NSLocalizedString("metadata show maps", comment:"Åpne i Kart"), for: UIControlState.normal)
        
        view.placeTitle.text = NSLocalizedString("metadata location title", comment:"Sted:")
        let placeAndAddress = event.place + "\n" + event.address
        view.place.attributedText = attributedString(text: placeAndAddress,  lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        let calendarButtonTitle = NSLocalizedString("metadata add to calendar", comment:"Legg til i kalender")
        view.calendarButton.setTitle(calendarButtonTitle, for: UIControlState.normal)
                
        var infoTextHeight = CGFloat(0)
        
        if event.infoText1.length > 1 {
            view.infoTitle1.text = event.infoTitle1
            view.infoText1.attributedText = attributedString(text: event.infoText1,  lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
            infoTextHeight += positiveHeightAdjustment(text: event.infoTitle1, width: view.infoTitle1.frame.width, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
            infoTextHeight += positiveHeightAdjustment(text: event.infoText1, width: view.infoText1.frame.width, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
            infoTextHeight += 50 //spaceBetweenDividerAndfirstInfoTitle
            view.infoImage.isHidden = false
            view.buttomDivider.isHidden = false
        }else{
            view.infoImage.isHidden = true
            view.buttomDivider.isHidden = true
        }
        
        if event.infoText2.length > 1 {
            view.infoTitle2.text = event.infoTitle2
            view.infoText2.attributedText = attributedString(text: event.infoText2,  lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
            infoTextHeight += positiveHeightAdjustment(text: event.infoTitle2, width: view.infoTitle2.frame.width, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
            infoTextHeight += positiveHeightAdjustment(text: event.infoText2, width: view.infoText2.frame.width, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
            infoTextHeight += 60 //spaceBetweenInfoText1AndInfoText2
        }
        
        infoTextHeight += positiveHeightAdjustment(text: event.title, width: view.title.frame.width, lineSpacing: customTitleLineSpacing, minimumLineHeight: minimumTitleLineHeight)
        infoTextHeight += positiveHeightAdjustment(text: event.subTitle, width: view.subTitle.frame.width, lineSpacing: customTitleLineSpacing, minimumLineHeight: minimumTitleLineHeight)
        
        view.containerViewHeight.constant += infoTextHeight
        extraHeight += infoTextHeight
    
        calendarPermissionsGranted()
        calendars = eventStore.calendars(for: EKEntityType.event).filter { $0.allowsContentModifications}
        view.layoutIfNeeded()
        return view
    }
    
    func addedToCalender() {
        calendarButton.setImage(UIImage(named: "Kalender-lagt-til")!, for: UIControlState.normal)
        calendarButton.setTitle(NSLocalizedString("metadata addedto calendar", comment:"Lagt til i kalender"), for: UIControlState.normal)
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
                alertController.message?.append("\n\n\n\n\n")
                calendarPicker.delegate = self
                calendarPicker.showsSelectionIndicator = true
                alertController.view.addSubview(calendarPicker)
            }
            
            alertController.addAction(UIAlertAction(title: modalAction, style: .default) { (action) in
                if let calendar = EventView.pickedCalenderIdentifier.characters.count > 1 && self.calendars.count > 1 ? self.getSelectedCalendar() : self.eventStore.defaultCalendarForNewEvents {
                    
                     //TOOD Loop gjennom timeframes og lag events for alle.
                    let startTime = Date()
                    let endTime = Date()
                    self.createEventInCalendar(calendar: calendar, title: eventTitle, startTime: startTime, endTime: endTime)
                }
            })
        }
        
        let modalCancel = NSLocalizedString("metadata calendar cancel", comment:"Avbryt")
        alertController.addAction(UIAlertAction(title: modalCancel, style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: {})
        })
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func getSelectedCalendar() -> EKCalendar {
        return calendars.filter { $0.calendarIdentifier == EventView.pickedCalenderIdentifier}.first!
    }
    
    func getEventMessage() -> String {
        let message = "\n" + NSLocalizedString("metadata calendar disclaimer", comment:"Obs! Innkallingen kan inneholde sensitiv informasjon som kan bli synlig for de som eventuelt har tilgang til din kalender.")
        return message
    }
    
    @discardableResult func calendarPermissionsGranted() -> Bool {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized: return true
        default: return EventView.requestPermissions()
        }
    }
    
    @discardableResult @objc static func requestPermissions() -> Bool{
        var permissionsGranted = false 
        EKEventStore().requestAccess(to: .event, completion: 
            {(granted: Bool, error: Error?) -> Void in
                permissionsGranted = granted
        })
        return permissionsGranted;
    }
    
    @IBAction func openAddressInMaps(_ sender: UIButton) {
        let addr = event.address.replacingOccurrences(of: " ", with: ",").replacingOccurrences(of: "\n", with: ",")
        let mapsUrl = URL(string: "http://maps.apple.com/?q=\(addr))")
    
       UIApplication.shared.openURL(mapsUrl!)
    }
    
    func createEventInCalendar(calendar: EKCalendar, title: String, startTime: Date, endTime: Date){
        let ekEvent = EKEvent(eventStore: self.eventStore)
    
        ekEvent.calendar = calendar
        ekEvent.title = title
        ekEvent.startDate = startTime
        ekEvent.endDate = endTime
        ekEvent.location = event.address
        ekEvent.notes = "\(arrivalTime.text!) \n\(event.subTitle) \n\n\(infoTitle1.text!) \n\(infoText1.text!) \n\n\(infoTitle2.text!) \n\(infoText2.text!) \n\n\(infoTitle3.text!) \n\(infoText3.text!) "
                
        do {
            try self.eventStore.save(ekEvent, span: .thisEvent, commit: true)
            self.addedToCalender()
        } catch {}
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
        EventView.pickedCalenderIdentifier = self.calendars[row].calendarIdentifier
    }
    
    private func instanceFromNib() -> UIView {
        return UINib(nibName: "EventView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
