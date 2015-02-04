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
            if documentFolder.name == "Inbox" {
                return ["location":"INBOX", "subject" : name]
            } else {
                return ["location":"FOLDER", "subject" : name, "folderId" : documentFolder.folderId.stringValue]
            }
            }()
        let task = urlSessionTask(httpMethod.post, url: document.updateUri, parameters: parameters, success: success) { (error) -> () in
            if (error.code == Constants.Error.Code.oAuthUnathorized ) {
                self.changeName(document, newName: name, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
    
    func deleteDocument(uri: String, success: () -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionTask(httpMethod.delete, url: uri, success: success) { (error) -> Void in
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue {
                self.deleteDocument(uri, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        // only do task if validated
        validateTokensThenPerformTask(task!)
    }
    
    func moveDocument(document: POSDocument, toFolder folder: POSFolder, success: () -> Void , failure: (error: APIError) -> ()) {
        let firstAttachment = document.attachments.firstObject as POSAttachment
        let parameters : Dictionary<String,String> = {
            if folder.name == "Inbox" {
                return ["location":"INBOX", "subject" : firstAttachment.subject]
            } else {
                return ["location":"FOLDER", "subject" : firstAttachment.subject, "folderId" : folder.folderId.stringValue]
            }
            }()
        let task = urlSessionTask(httpMethod.post, url: document.updateUri, parameters:parameters, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue {
                self.moveDocument(document, toFolder: folder, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
    
    func updateDocumentsInFolder(#name: String, mailboxDigipostAdress: String, folderUri: String, success: (Dictionary<String,AnyObject>) -> Void, failure: (error: APIError) -> ()) {
        let task = urlSessionJSONTask(url: folderUri,  success: success) { (error) -> () in
            if (error.code == Constants.Error.Code.oAuthUnathorized ) {
                self.updateDocumentsInFolder(name: name, mailboxDigipostAdress: mailboxDigipostAdress, folderUri: folderUri, success: success, failure: failure)
            } else {
                println("failure")
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
    
    func updateDocument(document:POSDocument, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionJSONTask(url: document.updateUri, success: success)  { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized {
                self.updateDocument(document, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
}
