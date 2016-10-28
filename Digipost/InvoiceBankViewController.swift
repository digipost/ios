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

class InvoiceBankViewController: UIViewController{
    
    var invoiceBank : InvoiceBank = InvoiceBank()
    
    @IBOutlet weak var invoiceBankHeader: UIView!
    @IBOutlet weak var invoiceBankTitle: UILabel!
    @IBOutlet weak var openBankUrlButton: UIButton!
    @IBOutlet weak var invoiceBankLogo: UIImageView!
    
    @IBAction func openBankUrl(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:invoiceBank.url)!)
    }
    override func viewDidLoad() {
        self.invoiceBankLogo.image = UIImage(named:invoiceBank.logo)
        
        let bankUrlButtonTitle = NSLocalizedString("invoice bank button link prefix", comment: "Invoice bank button link") 
            + invoiceBank.name
            + NSLocalizedString("invoice bank button link postfix", comment: "Invoice bank button link")
        self.openBankUrlButton.setTitle(bankUrlButtonTitle, forState: UIControlState.Normal)
        
        let invoiceBankTitleString = NSLocalizedString("invoice bank title prefix", comment:"invoice bank title") 
            + invoiceBank.name
        self.invoiceBankTitle.text = invoiceBankTitleString
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
