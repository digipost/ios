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

import UIKit

extension POSAttachment {
    
    @objc func hasValidToPayInvoice() -> Bool {
        if let actualInvoice = invoice as POSInvoice? {
            if actualInvoice.canBePaidByUser.boolValue {
                return true
            }
        }
        return false
    }
    
    @objc func needsAuthenticationToOpen() -> Bool {
        return OAuthToken.oAuthTokenWithAuthenticationLevel(self.authenticationLevel) == nil
    }

    func originIsPublicEntity() -> Bool{

        if origin == nil {
            return false
        }

        if origin == "PUBLIC_ENTITY" {
            return true
        }
        return false
    }
    
    @objc func getMetadataArray() -> [POSMetadataObject] {
        var metadataArray: [POSMetadataObject] = []
        if self.metadata != nil {
            if let json = NSKeyedUnarchiver.unarchiveObject(with: self.metadata) as? NSArray {
                for dict in json as! [[String: Any]] {
                    let metadataObject = POSMetadata(type: dict["type"] as! String, json: dict)
                    if let obj = POSMetadataMapper.get(metadata: metadataObject, creatorName: self.document.creatorName!) {
                        metadataArray.append(obj as! POSMetadataObject)
                    }
                }
            }
        }
        return metadataArray;
    }
}
