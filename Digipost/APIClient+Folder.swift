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
        let parameters = [ "id" : folder.folderId, "name" : name, "icon" : iconName]
        let task = urlSessionTask(httpMethod.put, url: folder.changeFolderUri, parameters: parameters, success: success) { (error) -> Void in
            if (error.code == Constants.Error.Code.oAuthUnathorized ) {
                self.changeName(folder, newName: name, newIconName: iconName, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        self.validateTokensThenPerformTask(task!)
    }
    
    func createFolder(name: String, iconName: String, mailBox: POSMailbox, success: () -> Void , failure: (error: APIError) -> ()) {
        let parameters = ["name" : name, "icon" : iconName]
        let task = urlSessionTask(httpMethod.post, url: mailBox.createFolderUri, parameters: parameters, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue {
                self.createFolder(name, iconName: iconName, mailBox: mailBox, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
    
    func moveFolder(folderArray: Array<POSFolder>, mailbox: POSMailbox, success: () -> Void , failure: (error: APIError) -> ()) {
        let folders = folderArray.map({ (folder: POSFolder) -> Dictionary<String,String> in
            return [ "id" : folder.folderId.stringValue, "name" : folder.name, "icon" : folder.iconName]
        })
        let parameters = ["folder" : folders]
        let task = urlSessionTask(httpMethod.put, url: mailbox.updateFoldersUri, parameters: parameters, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue {
                self.moveFolder(folderArray, mailbox: mailbox, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
    
    func delete(#folder: POSFolder, success: () -> Void , failure: (error: APIError) -> ()) {
        let parameters = [ "id" : folder.folderId, "name" : folder.name, "icon" : folder.iconName]
        let task = urlSessionTask(httpMethod.delete, url: folder.deletefolderUri, parameters: parameters, success: success) { (error) -> Void in
            if error.code == Constants.Error.Code.oAuthUnathorized {
                self.delete(folder: folder, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
}
