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

@objc class InvoiceBankAgreement: NSObject {

    static let type1 = "AGREEMENT_TYPE_1"
    static let type2 = "AGREEMENT_TYPE_2"
    
    static func hasActiveAgreementType1() -> Bool {
        return hasActiveInvoiceAgreement(type1)
    }

    static func hasActiveAgreementType2() -> Bool {
        return hasActiveInvoiceAgreement(type2)
    }

    static func hasActiveFakturaAgreement() -> Bool {
        return hasActiveInvoiceAgreement(type1) || hasActiveInvoiceAgreement(type2)
    }

    static func hasActiveInvoiceAgreement(agreementType: String) -> Bool {
        NSUserDefaults.standardUserDefaults()
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey(agreementType)
    }

    static func storeInvoiceAgreement(agreementType: String, agreementActive: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(agreementActive, forKey: agreementType)
    }

    static func updateActiveBankAgreementStatus() {        
        if let rootResource: POSRootResource =
            POSRootResource.existingRootResourceInManagedObjectContext(
                POSModelManager.sharedManager().managedObjectContext) {
            
            if let banksUri = rootResource.banksUri {
                
                APIClient.sharedClient.getActiveBanks(banksUri, success: {(jsonData) -> Void in jsonData
                    
                    var hasFakturaAgreementType1 = false
                    var hasFakturaAgreementType2 = false
                    
                    for bank in jsonData["banks"] as! [[String: AnyObject]] {
                        
                        if let agreements = bank["agreements"] {
                            
                            for agreement in agreements as! [[String: AnyObject]] {
                                
                                if let agreementTypeActive = agreement["active"], let agreementType = agreement["agreementType"] {
                                    
                                    if agreementTypeActive as! Bool && type1 == agreementType as! String {
                                        hasFakturaAgreementType1 = true
                                    }
                                    
                                    if agreementTypeActive as! Bool && type2 == agreementType as! String {
                                        hasFakturaAgreementType2 = true
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    InvoiceBankAgreement.storeInvoiceAgreement(type1,
                        agreementActive:hasFakturaAgreementType1)
                    InvoiceBankAgreement.storeInvoiceAgreement(type2,
                        agreementActive:hasFakturaAgreementType2)
                    
                    }, failure: ({_ in }))
            }
        }
    }
}
