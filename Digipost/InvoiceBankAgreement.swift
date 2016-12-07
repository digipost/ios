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

    static let type1 = "ATTACHMENT_TYPE_1"
    static let type2 = "ATTACHMENT_TYPE_1"
    static let active = "active"

    static func hasActiveAgreementType1() -> Bool {
        return hasActiveInvoiceAgreement(activeType1)
    }

    static func hasActiveAgreementType2() -> Bool {
        return hasActiveInvoiceAgreement(activeType2)
    }

    static func hasActiveFakturaAgreement() -> Bool {
        return hasActiveInvoiceAgreement(activeType1) || hasActiveInvoiceAgreement(activeType2)
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

                if let attachments = bank["attachments"] as! [[String: AnyObject]] {
                    for attachment in attachments {
                        if let agreementTypeActive = attachement[active] as! Bool {

                            if let agreementType1Available = attachement[type1] as! Bool {
                                hasFakturaAgreementType1 = true
                            }

                            if let agreementType1Available = attachement[type2] as! Bool {
                                hasFakturaAgreementType2 = true
                            }
                        }
                    }
                }

                if let bankOffersType1 = bank[offersType1], bankActiveType1 = bank[activeType1] {
                    if bankOffersType1 as! Bool && bankActiveType1 as! Bool {
                        hasFakturaAgreementType1 = true
                    }
                }

                if let bankOffersType2 = bank[offersType2], bankActiveType2 = bank[activeType2] {
                    if bankOffersType2 as! Bool && bankActiveType2 as! Bool {
                        hasFakturaAgreementType2 = true
                    }
                }
            }

            InvoiceBankAgreement.storeInvoiceAgreement(activeType1,
                agreementActive:hasFakturaAgreementType1)
            InvoiceBankAgreement.storeInvoiceAgreement(activeType2,
                agreementActive:hasFakturaAgreementType2)

            }, failure: ({_ in }))
        }
    }
    }
}
