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
    
    func changeName(_ folder: POSFolder, newName name: String, newIconName iconName: String, success: () -> Void , failure: (_ error: APIError) -> ()) {
        let parameters = [ Constants.APIClient.AttributeKey.identifier : folder.folderId, Constants.APIClient.AttributeKey.name : name, Constants.APIClient.AttributeKey.icon : iconName] as [String : Any]
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.put, url: folder.changeFolderUri, parameters: parameters as Dictionary<String, AnyObject>? , success: success, failure: failure)
            task.resume()
        }
    }
    
    func createFolder(_ name: String, iconName: String, mailBox: POSMailbox, success: () -> Void , failure: (_ error: APIError) -> ()) {
        let parameters = [Constants.APIClient.AttributeKey.name : name, Constants.APIClient.AttributeKey.icon : iconName]
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.post, url: mailBox.createFolderUri, parameters: parameters as Dictionary<String, AnyObject>?, success: success, failure: failure)
            task.resume()
        }
    }
    
    func moveFolder(_ folderArray: Array<POSFolder>, mailbox: POSMailbox, success: () -> Void , failure: (_ error: APIError) -> ()) {
        let folders = folderArray.map({ (folder: POSFolder) -> Dictionary<String,String> in
            return [ Constants.APIClient.AttributeKey.identifier : folder.folderId.stringValue, Constants.APIClient.AttributeKey.name : folder.name, Constants.APIClient.AttributeKey.icon: folder.iconName ]
        })
        let parameters = [Constants.APIClient.AttributeKey.folder : folders]
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.put, url: mailbox.updateFoldersUri, parameters: parameters as Dictionary<String, AnyObject>?, success: success, failure: failure)
            task.resume()
        }
    }
    
    func delete(folder: POSFolder, success: () -> Void , failure: (_ error: APIError) -> ()) {
        let parameters = [ Constants.APIClient.AttributeKey.identifier : folder.folderId, Constants.APIClient.AttributeKey.name : folder.name, Constants.APIClient.AttributeKey.icon : folder.iconName] as [String : Any]
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.delete, url: folder.deletefolderUri, parameters: parameters as Dictionary<String, AnyObject>?, success: success, failure: failure)
            task.resume()
        }
    }
}
