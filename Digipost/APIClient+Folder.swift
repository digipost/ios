//
//  APIClient+Folders.swift
//  Digipost
//
//  Created by Håkon Bogen on 04/02/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension APIClient {
    
    func changeName(folder: POSFolder, newName name: String, newIconName iconName: String, success: () -> Void , failure: (error: APIError) -> ()) {
        let parameters = [ Constants.APIClient.AttributeKey.identifier : folder.folderId, Constants.APIClient.AttributeKey.name : name, Constants.APIClient.AttributeKey.icon : iconName]
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.put, url: folder.changeFolderUri, parameters: parameters, success: success, failure: failure)
            task.resume()
        }
    }
    
    func createFolder(name: String, iconName: String, mailBox: POSMailbox, success: () -> Void , failure: (error: APIError) -> ()) {
        let parameters = [Constants.APIClient.AttributeKey.name : name, Constants.APIClient.AttributeKey.icon : iconName]
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.post, url: mailBox.createFolderUri, parameters: parameters, success: success, failure: failure)
            task.resume()
        }
    }
    
    func moveFolder(folderArray: Array<POSFolder>, mailbox: POSMailbox, success: () -> Void , failure: (error: APIError) -> ()) {
        let folders = folderArray.map({ (folder: POSFolder) -> Dictionary<String,String> in
            return [ Constants.APIClient.AttributeKey.identifier : folder.folderId.stringValue, Constants.APIClient.AttributeKey.name : folder.name, Constants.APIClient.AttributeKey.icon: folder.iconName ]
        })
        let parameters = [Constants.APIClient.AttributeKey.folder : folders]
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.put, url: mailbox.updateFoldersUri, parameters: parameters, success: success, failure: failure)
            task.resume()
        }
    }
    
    func delete(folder folder: POSFolder, success: () -> Void , failure: (error: APIError) -> ()) {
        let parameters = [ Constants.APIClient.AttributeKey.identifier : folder.folderId, Constants.APIClient.AttributeKey.name : folder.name, Constants.APIClient.AttributeKey.icon : folder.iconName]
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.delete, url: folder.deletefolderUri, parameters: parameters, success: success, failure: failure)
            task.resume()
        }
    }
}
