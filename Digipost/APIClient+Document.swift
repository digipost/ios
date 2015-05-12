//
//  APIClient+Document.swift
//  Digipost
//
//  Created by Håkon Bogen on 04/02/15.
//  Copyright (c) 2015 Posten. All rights reserved.
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
            task?.resume()
        }
    }
    
    func deleteDocument(uri: String, success: () -> Void , failure: (error: APIError) -> ()) {
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.delete, url: uri, success: success, failure: failure)
            task?.resume()
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
            task?.resume()
        }
    }
    
    func updateDocumentsInFolder(#name: String, mailboxDigipostAdress: String, folderUri: String, token: OAuthToken, success: (Dictionary<String,AnyObject>) -> Void, failure: (error: APIError) -> ()) {
        validate(token: token) { () -> Void in
            let task = self.urlSessionJSONTask(url: folderUri,  success: success, failure: failure)
            task?.resume()
        }
    }
    
    func updateDocument(document:POSDocument, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        validateFullScope {
            let task = self.urlSessionJSONTask(url: document.updateUri, success: success, failure: failure)
            task?.resume()
        }
    }
 
}
