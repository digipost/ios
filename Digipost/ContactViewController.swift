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
    
    var lastUpdated: String = ""
    
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
        getMailboxSettings()
        self.tableView.addSubview(self.refreshControl)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getMailboxSettings()
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("GENERIC_UPDATING_TITLE", comment: "Oppdaterer"))
        refreshControl.attributedTitle = NSAttributedString(string:NSLocalizedString("GENERIC_LAST_UPDATED_TITLE", comment: "Sist oppdatert") + " \(lastUpdated)")
        self.tableView.reloadData()
        refreshControl.endRefreshing()
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
                    if(SettingsValidator.emailAppearsValid(email: emailAddress)){
                        switch(index) {
                        case 0:
                            self.email1?.text =  emailAddress
                        case 1:
                            self.email2?.text =  emailAddress
                        case 2:
                            self.email3?.text =  emailAddress
                        default:
                            return
                        }
                    }
                }
            }
            
            self.phonenumber?.text = self.mobilePhoneNumber["phoneNumber"] as? String
            self.countryCode?.text = self.mobilePhoneNumber["countryCode"] as? String
        }
    }
    
    func updateEmail(index: Int, emailAddress: String) {
        var email = emails[index]
        email["email"] = emailAddress
        emails[index] = email
    }
    
    @IBAction func changedValue(_ sender: UITextField) {
        if sender == email1 {
            updateEmail(index: 0, emailAddress: email1.text!)
        }else if sender == email2 {
            updateEmail(index: 1, emailAddress: email2.text!)
        } else if sender == email3 {
            updateEmail(index: 2, emailAddress: email3.text!)
        } else if sender == phonenumber {
            self.mobilePhoneNumber.updateValue(phonenumber.text!, forKey: "phoneNumber")
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
    
    @objc func postMailboxSettings() {
        var mailboxSettings = self.mailboxSettings
        mailboxSettings.updateValue(self.emails as AnyObject, forKey: "emailAddress")
        mailboxSettings.updateValue(self.mobilePhoneNumber as AnyObject, forKey: "mobilePhoneNumber")
        
        if let rootResource: POSRootResource =
            POSRootResource.existingRootResource(in: POSModelManager.shared().managedObjectContext) {
            if let mailboxSettingsUri = rootResource.mailboxSettingsUri {
                APIClient.sharedClient.updateMailboxSettings(uri: mailboxSettingsUri,mailboxSettings: mailboxSettings ,success: {() -> Void in
                    self.finish()
                }, failure: ({_ in }))
            }
        }
    }
    
}
