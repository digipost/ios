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
        
    @IBOutlet weak var invoiceBankLogo: UIImageView!{
        didSet{
            self.invoiceBankLogo.image = UIImage(named:"\(invoiceBank.logo)-large")
        }
    }
    
    @IBOutlet weak var invoiceBankContent: UILabel!{
        didSet{
            let invoiceBankContentString = invoiceBank.activeType2Agreement ? "invoice bank enabled content" : "invoice bank disabled content"
            self.invoiceBankContent.text = NSLocalizedString(invoiceBankContentString, comment:"invoice bank content")
            self.invoiceBankContent.sizeToFit()
            self.invoiceBankContent.lineBreakMode = NSLineBreakMode.byWordWrapping
        }
    }
    
    @IBOutlet weak var invoiceBankTitle: UILabel!{
        didSet{
            let invoiceBankTitleString = invoiceBank.activeType2Agreement ? "invoice bank enabled title" : "invoice bank disabled title"
            self.invoiceBankTitle.text = NSLocalizedString(invoiceBankTitleString, comment:"invoice bank title")
        }
    }
    
    
    @IBOutlet weak var openBankUrlButton: UIButton!{
        didSet{
            if(invoiceBank.activeType2Agreement){
                let openBankUrlButtonString = NSLocalizedString("invoice bank button link prefix", comment: "invoice bank button link") + invoiceBank.name + NSLocalizedString("invoice bank button link postfix", comment: "Invoice bank button link")
                self.openBankUrlButton.setTitle(openBankUrlButtonString, for: UIControlState())
            }else{
                self.openBankUrlButton.isHidden = true
            }
        }
    }

    @IBOutlet weak var invoiceBankReadMoreText: UIButton!{
        didSet{
            let invoiceBankReadMoreLinkString = invoiceBank.activeType2Agreement ? "invoice bank enabled read more link" : "invoice bank disabled read more link"
            self.invoiceBankReadMoreText.setTitle(NSLocalizedString(invoiceBankReadMoreLinkString, comment:"invoice bank read more link"), for:UIControlState())
        }
    }
    
    @IBAction func openBankUrl(_ sender: AnyObject) {
        InvoiceAnalytics.sendInvoiceClickedSetup20Link(invoiceBank.name)
        UIApplication.shared.openURL(URL(string:invoiceBank.url)!) //Opens external bank website, should be opened in external browser
    }
    
    @IBAction func invoiceBankReadMore(_ sender: AnyObject) {
        if(invoiceBank.activeType2Agreement){
            InvoiceAnalytics.sendInvoiceClickedDigipostOpenPagesLink(invoiceBank.name)
            openExternalUrl(url: "https://digipost.no/faktura")
        }else{
            InvoiceAnalytics.sendInvoiceClickedSetup10Link(invoiceBank.name)
            openExternalUrl(url: "https://digipost.no/app/post#/faktura")
        }
    }
    
    func openExternalUrl(url: String){
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: NSURL(string: url) as! URL)
            self.present(svc, animated: true, completion: nil)
        }
    }
}
