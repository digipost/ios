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

    static let TYPE1 = "AGREEMENT_TYPE_1"
    static let TYPE2 = "AGREEMENT_TYPE_2"
    static let BANKS_STATUS_KEY = "invoice_banks_status_as_json"
    
    static func hasActiveType1Agreement() -> Bool {
        return hasActiveAgreement(agreementType: TYPE1)
    }
    
    static func hasActiveType2Agreement() -> Bool {
        return hasActiveAgreement(agreementType: TYPE2)
    }
    
    static func hasAnyActiveAgreements() -> Bool {
        return hasActiveAgreement(agreementType: TYPE1) || hasActiveAgreement(agreementType: TYPE2)
    }
    
    static func hasActiveAgreement(agreementType: String) -> Bool {
        if let banks = getBanks() {
            for bank in banks {
                if agreementType == TYPE1 && bank.activeType1Agreement {
                    return true
                }else if agreementType == TYPE2 && bank.activeType2Agreement {
                    return true
                }
            }
        }
        return false
    }
    
    static func getBanks() -> [InvoiceBank]? {
        let banksJSON = UserDefaults.standard.dictionary(forKey: BANKS_STATUS_KEY) as! [String : AnyObject]
        
        var banks : [InvoiceBank] = []
        for bank in banksJSON["banks"] as! [[String: AnyObject]] {
            
            var activeType1Agreement = false
            var activeType2Agreement = false
    
            for agreement in bank["agreements"] as! [[String: AnyObject]] {
                
                if let agreementTypeActive = agreement["active"], let agreementType = agreement["agreementType"] {
                    if agreementTypeActive as! Bool && TYPE1 == agreementType as! String {
                        activeType1Agreement = true
                    }
                    
                    if agreementTypeActive as! Bool && TYPE2 == agreementType as! String {
                        activeType2Agreement = true
                    }
                }
            }
                       
            let name = bank["name"] as! String
            banks.append(InvoiceBank(name: name, url: "", activeType1Agreement: activeType1Agreement, activeType2Agreement: activeType2Agreement))
        }
        return banks
    }
    
    static func storeBanks(banksStatus: [String: AnyObject]) {
        UserDefaults.standard.set(banksStatus, forKey: BANKS_STATUS_KEY)
    }
    
    static func updateActiveBankAgreementStatus() {
        if let rootResource: POSRootResource =
            POSRootResource.existingRootResource(
                in: POSModelManager.shared().managedObjectContext) {
            
            if let banksUri = rootResource.banksUri {
                APIClient.sharedClient.getActiveBanks(banksUri: banksUri, success: {(banksStatus) -> Void in
                    storeBanks(banksStatus: banksStatus)
                }, failure: ({_ in }))
            }
        }
    }
}
