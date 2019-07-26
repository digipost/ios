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
    @IBOutlet weak var descriptionText: UILabel!
    
    @IBOutlet weak var place: UILabel!
    
    @IBOutlet weak var timeframes: UILabel!
    @IBOutlet weak var calendarButton: UIButton!
    
    @IBOutlet weak var topDivider: UIView!
    
    @IBOutlet weak var barcodeTitle: UILabel!
    @IBOutlet weak var barcode: UIImageView!
    @IBOutlet weak var barcodeDescription: UILabel!
    
    @IBOutlet weak var bottomDivider: UIView!
    
    @IBOutlet weak var infoText: UILabel!
    
    @objc var parentViewController: POSLetterViewController? = nil
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!

    var event: POSEvent = POSEvent()

    let eventStore = EKEventStore()
    var calendars = [EKCalendar]()
    static var pickedCalenderIdentifier: String = ""
    let permissionsErrorMessage = "For å legge til hendelser i kalenderen din, må du gi Digipost tilgang til Kalendere. Dette kan du endre under Personvern i Innstillinger."

    @objc func instanceWithData(event: POSEvent, title: String) -> UIView{
        let view = UINib(nibName: "EventView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EventView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.event = event
        view.title.text = title
        view.subTitle.text = event.subTitle
        view.descriptionText.text = event.descriptionText
        
        let placeAndAddress = event.place + "\n" + event.address
        view.place.attributedText = attributedString(text: placeAndAddress,  lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        
        var timeframes = ""
        for timeframe in event.timeframes {
            timeframes += timeframe.startTime.dateOnly() + " - " + timeframe.startTime.timeOnly()+"\n"
        }
        view.timeframes.attributedText = attributedString(text: timeframes, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        setupCalendars()
        
        let boldAttribute = [
            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 15)!,
            NSAttributedStringKey.foregroundColor: UIColor.black
        ]
        
        let regularAttribute = [
            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 15)!,
            NSAttributedStringKey.foregroundColor: UIColor.black
        ]
        let infoTexts = NSMutableAttributedString()
        for info in event.info{
             infoTexts.append(NSAttributedString(string: info.title+"\n", attributes: boldAttribute))
             infoTexts.append( NSAttributedString(string: info.text+"\n\n", attributes: regularAttribute))
        }
        view.infoText.attributedText = infoTexts
        
        
        
        var extraTextViewHeight = positiveHeightAdjustment(text: event.descriptionText, width: view.infoText.frame.width, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        extraTextViewHeight += positiveHeightAdjustment(text: placeAndAddress, width: view.infoText.frame.width, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        extraTextViewHeight += positiveHeightAdjustment(text: timeframes, width: view.infoText.frame.width, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        extraTextViewHeight += positiveHeightAdjustment(text: infoTexts.mutableString as String, width: view.infoText.frame.width, lineSpacing: customTextLineSpacing, minimumLineHeight: minimumTextLineHeight)
        view.containerViewHeight.constant += extraTextViewHeight
        
        view.layoutIfNeeded()
        return view
    }
    
    func setupCalendars() {
        calendarPermissionsGranted()
        calendars = eventStore.calendars(for: EKEntityType.event).filter { $0.allowsContentModifications}
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
                if let calendar = EventView.pickedCalenderIdentifier.count > 1 && self.calendars.count > 1 ? self.getSelectedCalendar() : self.eventStore.defaultCalendarForNewEvents {
                    
                    for timeframe in self.event.timeframes {
                        self.createEventInCalendar(calendar: calendar, title: eventTitle, startTime: timeframe.startTime, endTime: timeframe.endTime)
                    }
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
        
        ekEvent.notes = "\(infoText.text!)"
                
        do {
            try self.eventStore.save(ekEvent, span: .thisEvent, commit: true)
            self.addedToCalender()
        } catch {}
    }
    
    @IBAction func openLink(_ sender: Any) {
        
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
    
    @objc func setParentViewController(parentViewController: POSLetterViewController) {
        self.parentViewController = parentViewController
    }
}
