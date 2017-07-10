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

@objc class AppointmentView: UIView {
    
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
    
    @IBAction func addToCalendar(_ sender: Any) {
        print(appointment.title)
    }
    
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
