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

extension APIClient {
    
    func changeName(document: POSDocument, newName name: String, success: () -> Void , failure: (error: APIError) -> ()) {
        let documentFolder = document.folder
        let parameters : Dictionary<String,String> = {
            if documentFolder.name.lowercaseString == Constants.FolderName.inbox.lowercaseString {
                return [Constants.APIClient.AttributeKey.location : Constants.FolderName.inbox, Constants.APIClient.AttributeKey.subject : name]
            } else {
                return [Constants.APIClient.AttributeKey.location : Constants.FolderName.folder, Constants.APIClient.AttributeKey.subject : name, Constants.APIClient.AttributeKey.folderId: documentFolder.folderId.stringValue]
            }
            }()

        validateFullScope {
            let task = self.urlSessionTask(httpMethod.post, url: document.updateUri, parameters: parameters, success: success,failure: failure)
            task.resume()
        }
    }
    
    func deleteDocument(uri: String, success: () -> Void , failure: (error: APIError) -> ()) {
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.delete, url: uri, success: success, failure: failure)
            task.resume()
        }
    }

    func moveDocument(document: POSDocument, toFolder folder: POSFolder, success: () -> Void , failure: (error: APIError) -> ()) {
        let firstAttachment = document.attachments.firstObject as! POSAttachment
        let parameters : Dictionary<String,String> = {
            if folder.name.lowercaseString == Constants.FolderName.inbox.lowercaseString {
                return [Constants.APIClient.AttributeKey.location : Constants.FolderName.inbox, Constants.APIClient.AttributeKey.subject : firstAttachment.subject]
            } else {
                return [Constants.APIClient.AttributeKey.location: Constants.FolderName.folder, Constants.APIClient.AttributeKey.subject : firstAttachment.subject, Constants.APIClient.AttributeKey.folderId : folder.folderId.stringValue]
            }
            }()
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.post, url: document.updateUri, parameters:parameters, success: success, failure: failure)
            task.resume()
        }
    }

    func updateDocumentsInFolder(name name: String, mailboxDigipostAdress: String, folderUri: String, token: OAuthToken, success: (Dictionary<String,AnyObject>) -> Void, failure: (error: APIError) -> ()) {
        validate(token: token) { () -> Void in
            let task = self.urlSessionJSONTask(url: folderUri,  success: success, failure: failure)
            task.resume()
        }
    }

    func updateDocument(document: POSDocument, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        validateFullScope {
            let task = self.urlSessionJSONTask(url: document.updateUri, success: success, failure: failure)
            task.resume()
        }
    }
 
}
