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

@objc class InvoiceBankAgreement: NSObject{
        
    static func hasActive10Agreement() -> Bool{
        return hasActiveFakturaAgreement("tilbyrFakturaAvtaleType1")
    }
    
    static func hasActive20Agreement() -> Bool{
        return hasActiveFakturaAgreement("tilbyrFakturaAvtaleType2")
    }
    
    static func hasActiveFakturaAgreement(agreementType: String) -> Bool{
        NSUserDefaults.standardUserDefaults()
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey(agreementType)
    }
    
    static func storeFakturaAgreement(agreementType: String, agreementActive: Bool){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(agreementActive, forKey: agreementType)
    }
    
    static func updateActiveBankAgreementStatus(){
        
        let rootResource: POSRootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext)
        if let banksUri = rootResource.banksUri{
        
        APIClient.sharedClient.getActiveBanks(banksUri, success: {(jsonData) -> Void in jsonData
            
            var hasFakturaAgreementType1 = false
            var hasFakturaAgreementType2 = false
            
            for bank in jsonData["banks"] as! [[String: AnyObject]] {
                if bank["personHarFakturaAvtaleMedBank"] as! Bool{
                    if(bank["tilbyrFakturaAvtaleType1"] as! Bool){
                        hasFakturaAgreementType1 = true
                    }
                    
                    if(bank["tilbyrFakturaAvtaleType2"] as! Bool){
                        hasFakturaAgreementType2 = true
                    }
                    
                }
            }
            
            InvoiceBankAgreement.storeFakturaAgreement("tilbyrFakturaAvtaleType1",agreementActive:hasFakturaAgreementType1)
            InvoiceBankAgreement.storeFakturaAgreement("tilbyrFakturaAvtaleType2",agreementActive:hasFakturaAgreementType2)
            
            }, failure: ({_ in }))
        }
    }
}
