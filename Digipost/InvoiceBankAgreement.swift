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
    
    func hasActiveAgreement(){
        
    }
    
    func hasActive10Agreement(){
        
    }
    
    func hasActive20Agreement(){
        
    }
    
    static func updateActiveBankAgreementStatus(){
        
        let rootResource: POSRootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext)
        if let banksUri = rootResource.banksUri{
        
        APIClient.sharedClient.getActiveBanks(banksUri, success: {(jsonData) -> Void in jsonData
            print(jsonData)
           
            }, failure: ({_ in }))
        }
    }
}
