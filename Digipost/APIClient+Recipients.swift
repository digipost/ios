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

extension APIClient {

    func getRecipients(searchString: String, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let encodedSearchString:String =  searchString.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let safeString = encodedSearchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let searchUri = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext).searchUri
        let urlString = "\(searchUri)?recipientId=\(safeString!)"
        urlSessionJSONTask(url: urlString, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized {
                self.getRecipients(urlString, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
    }
}