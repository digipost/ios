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

class InvoiceOptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var bankTableView: UITableView!
    
    let kInvoiceBankSegue = "invoiceBankSegue"
    var banks: [InvoiceBank] = []
    var viewTitle : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bankTableView.delegate = self
        bankTableView.dataSource = self
        bankTableView.register(UINib(nibName: Constants.Invoice.InvoiceBankTableViewCellNibName, bundle: nil), forCellReuseIdentifier: Constants.Invoice.InvoiceBankTableViewCellNibName)
        addInvoiceBanks()

        self.title = viewTitle
    }
    

    func addInvoiceBanks(){
        banks.append(InvoiceBank(name:"DNB", url:"https://www.dnb.no/privat/nettbank-mobil-og-kort/betaling/elektronisk-faktura.html", logo:"invoice-bank-dnb", setupIsAvailable:true))
        banks.append(InvoiceBank(name:"KLP", url:"", logo:"invoice-bank-klp", setupIsAvailable:false))
        banks.append(InvoiceBank(name:"Skandiabanken", url:"", logo:"invoice-bank-skandia", setupIsAvailable:false))
        bankTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Invoice.InvoiceBankTableViewCellNibName, for: indexPath) as! InvoiceBankTableViewCell
        
        let invoiceBank = banks[indexPath.row]
        cell.invoiceBankLogo.image = UIImage(named: invoiceBank.logo)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == kInvoiceBankSegue{
            if let viewController = segue.destination as? InvoiceBankViewController {
                viewController.invoiceBank = banks[(sender as! IndexPath).row]
                viewController.title = self.viewTitle
                InvoiceAnalytics.sendInvoiceOpenBankViewFromListEvent(banks[(sender as! IndexPath).row].name)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: kInvoiceBankSegue, sender: indexPath)
    }
}
