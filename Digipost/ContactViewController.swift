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

class ContactViewController: UIViewController {
    
    @IBOutlet weak var email1: SettingsTextField!
    @IBOutlet weak var email2: SettingsTextField!
    @IBOutlet weak var email3: SettingsTextField!
    @IBOutlet weak var countryCode: SettingsTextField!
    @IBOutlet weak var phonenumber: SettingsTextField!
    
    let ga_tag = "kontaktopplysninger"
    var lastUpdated: String = ""
    var saveButtonPressed: Bool = false
    var actuallySaved: Bool = true
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ContactViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        refreshControl.layer.zPosition = -1
        
        return refreshControl
    }()
    
    var mailboxSettings: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
    var emails: [[String: Any]] = [[String: Any]]()
    var mobilePhoneNumber: [String: Any] = [String: Any]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSaveButton()
        setupTextFields()
        getMailboxSettings()
        self.tableView.addSubview(self.refreshControl)
        GAEvents.event(category: ga_tag, action: "åpne-view", label: "mappevisning", value: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var saveState = "Lagre ikke"
        if saveButtonPressed && actuallySaved {
            saveState = "Lagret og fullførte vellykket"
        }else if saveButtonPressed {
            saveState = "Lagret, men feilet"
        }
        GAEvents.event(category: ga_tag, action: "lukke-view", label: saveState, value: nil)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getMailboxSettings()
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("GENERIC_UPDATING_TITLE", comment: "Oppdaterer"))
        refreshControl.attributedTitle = NSAttributedString(string:NSLocalizedString("GENERIC_LAST_UPDATED_TITLE", comment: "Sist oppdatert") + " \(lastUpdated)")
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func setupTextFields() {
        email1.layer.borderWidth = 2
        email2.layer.borderWidth = 2
        email3.layer.borderWidth = 2
        countryCode.layer.borderWidth = 2
        phonenumber.layer.borderWidth = 2
    }
    
    func setupSaveButton() {
        let saveButton = UIBarButtonItem(title: NSLocalizedString("Save",comment:"Lagre"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.postMailboxSettings))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func updateView(mailboxSettings: Dictionary<String, AnyObject>) {
        self.mailboxSettings = mailboxSettings
        self.emails = mailboxSettings["emailAddress"] as! [[String: Any]]
        self.mobilePhoneNumber = mailboxSettings["mobilePhoneNumber"] as! [String : Any]
        self.lastUpdated = " \(Date().timeOnly())"
        
        DispatchQueue.main.async {
            for (index, email) in self.emails.enumerated() {
                if let emailAddress = email["email"] as? String {
                    switch(index) {
                    case 0:
                        self.updateEmailView(emailView: self.email1, email: emailAddress)
                    case 1:
                        self.updateEmailView(emailView: self.email2, email: emailAddress)
                    case 2:
                        self.updateEmailView(emailView: self.email3, email: emailAddress)
                    default:
                        return
                    }
                }
            }
            self.phonenumber?.text = self.mobilePhoneNumber["phoneNumber"] as? String
            self.countryCode?.text = self.mobilePhoneNumber["countryCode"] as? String
        }
    }
    
    func updateEmail(index: Int, sender: UITextField) {
        let emailAddress = sender.text!
        if SettingsValidator.emailAppearsValid(email: emailAddress) {
            if index >= emails.count {
                var newEmail = [String: Any]()
                newEmail["email"] = emailAddress
                emails.append(newEmail)
                GAEvents.event(category: ga_tag, action: "e-post", label: "legger til ny", value: nil)
            }else{
                if emailAddress.isEmpty {
                    GAEvents.event(category: ga_tag, action: "e-post", label: "fjerner eksisterende", value: nil)
                }else{
                    GAEvents.event(category: ga_tag, action: "e-post", label: "oppdaterer eksisterende", value: nil)
                }
                emails[index].updateValue(emailAddress, forKey: "email")
            }
        }
        updateEmailView(emailView: sender, email: emailAddress)
    }
    
    func updatePhonenumber(new: String) {
        let old = (self.mobilePhoneNumber["phoneNumber"] as! String)
        
        if old.isEmpty && !new.isEmpty{
            GAEvents.event(category: ga_tag, action: "telefonnummer", label: "legger til nytt", value: nil)
        }else if !old.isEmpty && new.isEmpty {
            GAEvents.event(category: ga_tag, action: "telefonnummer", label: "fjerner eksisterende", value: nil)
        }else if !old.elementsEqual(new){
            GAEvents.event(category: ga_tag, action: "telefonnummer", label: "oppdaterer eksisterende", value: nil)
        }
        
        self.mobilePhoneNumber.updateValue(new, forKey: "phoneNumber")
    }
    
    func updateEmailView(emailView: UITextField, email: String) {
        DispatchQueue.main.async {
            let borderColor = SettingsValidator.emailAppearsValid(email: email) ? UIColor(red:0.27, green:0.27, blue:0.27, alpha:1.0).cgColor : UIColor(red:1.00, green:0.80, blue:0.00, alpha:1.0).cgColor
            emailView.layer.borderColor = borderColor
            emailView.text = email
        }
    }
    
    @IBAction func changedValue(_ sender: UITextField) {
        if sender == email1 {
            updateEmail(index: 0, sender: sender)
        }else if sender == email2 {
            updateEmail(index: 1, sender: sender)
        } else if sender == email3 {
            updateEmail(index: 2, sender: sender)
        } else if sender == phonenumber {
            updatePhonenumber(new: phonenumber.text!)
        } else if sender == countryCode {
            self.mobilePhoneNumber.updateValue(countryCode.text!, forKey: "countryCode")
        }
    }
    
    func getMailboxSettings() {
        if let rootResource: POSRootResource =
            POSRootResource.existingRootResource(in: POSModelManager.shared().managedObjectContext) {
            if let mailboxSettingsUri = rootResource.mailboxSettingsUri {
                APIClient.sharedClient.getMailboxSettings(uri: mailboxSettingsUri, success: {(mailboxSettings) -> Void in
                    self.updateView(mailboxSettings: mailboxSettings)
                }, failure: ({_ in }))
            }
        }
    }
    
    func finish() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func validInput() -> Bool{
        return SettingsValidator.emailAppearsValid(email: self.email1.text!) && SettingsValidator.emailAppearsValid(email: self.email2.text!) && SettingsValidator.emailAppearsValid(email: self.email3.text!)
    }
    
    func showAlertMessage(title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Ok"), style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc func postMailboxSettings() {
        self.saveButtonPressed = true
        if validInput() {
            
            var mailboxSettings = self.mailboxSettings
            mailboxSettings.updateValue(self.emails as AnyObject, forKey: "emailAddress")
            mailboxSettings.updateValue(self.mobilePhoneNumber as AnyObject, forKey: "mobilePhoneNumber")
            if let rootResource: POSRootResource =
                POSRootResource.existingRootResource(in: POSModelManager.shared().managedObjectContext) {
                if let mailboxSettingsUri = rootResource.mailboxSettingsUri {
                    APIClient.sharedClient.updateMailboxSettings(uri: mailboxSettingsUri,mailboxSettings: mailboxSettings ,success: {() -> Void in
                        self.actuallySaved = true
                        GAEvents.event(category: self.ga_tag, action: "lagring", label: "vellykket", value: nil)
                        self.finish()
                    }, failure: ({_ in
                        GAEvents.event(category: self.ga_tag, action: "lagring", label: "feilet", value: nil)
                        self.showAlertMessage(title: NSLocalizedString("error_contact_info_title", comment: ""), text: NSLocalizedString("error_contact_info_message", comment: ""))
                    }))
                }
            }
        } else{
            GAEvents.event(category: self.ga_tag, action: "lagring", label: "feil i inputfelter", value: nil)
            self.showAlertMessage(title: NSLocalizedString("invalid_email_title", comment: "invalid email"), text: NSLocalizedString("invalid_email_message", comment: "Please check"))
        }
    }
}
