//
//  APIClient.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation
import MobileCoreServices

class APIClient : NSObject, NSURLSessionTaskDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate {
    
    enum httpMethod : String {
        case post = "POST"
        case delete = "DELETE"
        case update = "UPDATE"
        case put = "PUT"
        case get = "GET"
    }
    
   
    lazy var queue = NSOperationQueue()
    var session : NSURLSession!
    
    
    var taskCounter              = 0
    
    class var sharedClient: APIClient {
        struct Singleton {
            static let sharedClient = APIClient()
        }
        
        return Singleton.sharedClient
    }
    
    
    var taskWasUnAuthorized : Bool  = false
    var lastPerformedTask : NSURLSessionTask?
    
    override init() {
        super.init()
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfiguration.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        let contentType = "application/vnd.digipost-\(__API_VERSION__)+json"
        sessionConfiguration.HTTPAdditionalHeaders = [Constants.HTTPHeaderKeys.accept: contentType, "Content-type" : contentType]
        let theSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        self.session = theSession
        println(" The delegate: \(theSession.delegate)")
        println(theSession.delegateQueue)
        dispatch(after:3) {
            println(" The delegate: \(theSession.delegate)")
            println(theSession.delegateQueue)
        }
        updateAuthorizationHeader(kOauth2ScopeFull)
        RACObserve(self, Constants.APIClient.taskCounter).subscribeNext({
            (anyObject) in
            if let taskCounter = anyObject as? Int {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = (taskCounter > 0)
            }
        })
        
        RACObserve(self, "taskWasUnAuthorized").subscribeNext { (anyObject) -> Void in
            OAuthToken.removeAcessTokenForOAuthTokenWithScope(kOauth2ScopeFull)
            if let actualTask = self.lastPerformedTask {
                self.validateTokensThenPerformTask(actualTask)
            }
        }

    }
    
    func updateAuthorizationHeader(scope: String) {
        let athing = self.session.delegate! as NSURLSessionDelegate
        let oAuthToken = OAuthToken.oAuthTokenWithScope(scope)
        println(self.session.configuration.HTTPAdditionalHeaders)
        if let accessToken = oAuthToken?.accessToken {
            self.session.configuration.HTTPAdditionalHeaders!["Authorization"] = "Bearer \(oAuthToken!.accessToken!)"
            println(self.session.configuration.HTTPAdditionalHeaders)
        }
    }
    
    class func stringFromArguments(arguments: Dictionary<String,AnyObject>?) -> String? {
        var urlString: String = ""
        if let actualArguments  = arguments {
            for (key,value) in actualArguments {
                let escapedKey = key.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
                urlString = "\(urlString)&\(escapedKey)=\(value.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!)"
            }
        }
        return urlString
    }

    private func validateTokensThenPerformTask(task: NSURLSessionTask) {
        println("\(task.originalRequest.allHTTPHeaderFields)")
        println(self.session.configuration.HTTPAdditionalHeaders)
        validateOAuthToken(kOauth2ScopeFull) {
            println(self.session.configuration.HTTPAdditionalHeaders)
            println("\(task.originalRequest.allHTTPHeaderFields)")
            task.resume()
        }
    }
    
    func changeName(folder: POSFolder, newName name: String, newIconName iconName: String, success: () -> Void , failure: (error: APIError) -> ()) {
        let parameters = [ "id" : folder.folderId, "name" : name, "icon" : iconName]
        let task = urlSessionTask(httpMethod.put, url: folder.changeFolderUri, parameters: parameters, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func changeName(document: POSDocument, newName name: String, success: () -> Void , failure: (error: APIError) -> ()) {
        let documentFolder = document.folder
        let parameters : Dictionary<String,String> = {
            if documentFolder.name == "Inbox" {
                return ["location":"INBOX", "subject" : name]
            } else {
                return ["location":"FOLDER", "subject" : name, "folderId" : documentFolder.folderId.stringValue]
            }
            }()
        
        let task = urlSessionTask(httpMethod.post, url: document.updateUri, parameters: parameters, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func createFolder(name: String, iconName: String, mailBox: POSMailbox, success: () -> Void , failure: (error: APIError) -> ()) {
        let parameters = ["name" : name, "icon" : iconName]
        let task = urlSessionTask(httpMethod.post, url: mailBox.createFolderUri, parameters: parameters, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func deleteDocument(uri: String, success: () -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionTask(httpMethod.delete, url: uri, success: success, failure: failure)
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
        let task = urlSessionTask(httpMethod.post, url: document.updateUri, parameters:parameters, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func moveFolder(folderArray: Array<POSFolder>, mailbox: POSMailbox, success: () -> Void , failure: (error: APIError) -> ()) {
        let folders = folderArray.map({ (folder: POSFolder) -> Dictionary<String,String> in
            return [ "id" : folder.folderId.stringValue, "name" : folder.name, "icon" : folder.iconName]
        })
        let parameters = ["folder" : folders]
        let task = urlSessionTask(httpMethod.put, url: mailbox.updateFoldersUri, parameters: parameters, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func delete(#folder: POSFolder, success: () -> Void , failure: (error: APIError) -> ()) {
        let parameters = [ "id" : folder.folderId, "name" : folder.name, "icon" : folder.iconName]
        let task = urlSessionTask(httpMethod.delete, url: folder.deletefolderUri, parameters: parameters, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }

    func updateRootResource(#success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        println("update root resource")
        let rootResource = __ROOT_RESOURCE_URI__
        let task = urlSessionJSONTask(url: rootResource, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func updateBankAccount(#uri : String, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionJSONTask(url: uri, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func sendInvoideToBank(invoice: POSInvoice , success: () -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionTask(httpMethod.post, url: invoice.sendToBankUri, success: success, failure: failure);
        validateTokensThenPerformTask(task!)
    }
    
    func updateDocumentsInFolder(#name: String, mailboxDigipostAdress: String, folderUri: String, success: (Dictionary<String,AnyObject>) -> Void, failure: (error: APIError) -> ()) {
        let task = urlSessionJSONTask(url: folderUri, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func updateDocument(document:POSDocument, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionJSONTask(url: document.updateUri, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func updateReceiptsInMailboxWithDigipostAddress(digipostAddress: String, uri: String, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionJSONTask(url: uri, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func deleteReceipt(receipt: POSReceipt , success: () -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionTask(httpMethod.delete, url: receipt.deleteUri, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func downloadBaseEncryptionModel(baseEncryptionModel: POSBaseEncryptedModel, withProgress progress: NSProgress, success: () -> Void , failure: (error: APIError) -> ()) {
        var didChooseHigherScope = false
        var highestScope : String?
        var baseEncryptedModelIsAttachment = false
        if let attachment = baseEncryptionModel as? POSAttachment {
            baseEncryptedModelIsAttachment = true
            let scope = OAuthToken.oAuthScopeForAuthenticationLevel(attachment.authenticationLevel)
           if scope == kOauth2ScopeFull {
                highestScope = kOauth2ScopeFull
            } else {
                highestScope = OAuthToken.highestScopeInStorageForScope(scope)
                if highestScope != scope {
                    didChooseHigherScope = true
                }
            }
        } else {
            highestScope = kOauth2ScopeFull
        }
        println(self.session.delegate)
        println(self.session.delegateQueue)
        
        var oAuthToken = OAuthToken.oAuthTokenWithScope(highestScope!)
        
        // if we dont have token for the higher scope required
        if oAuthToken == nil && didChooseHigherScope {
            let attachment = baseEncryptionModel as POSAttachment
            let scope = OAuthToken.oAuthScopeForAuthenticationLevel(attachment.authenticationLevel)
            oAuthToken = OAuthToken.oAuthTokenWithScope(scope)
        }
        
        if oAuthToken == nil {
            let error = NSError(domain: "apiManagerErrorDomain", code: 100, userInfo: nil)
            failure(error: APIError(error: error))
            return
        }
        
        //        let task = urlSessionTask(httpMethod.get, url: baseEncryptionModel.uri, success: success, failure: failure)
//        let signal = rac_signalForSelector(Selector("URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:"), fromProtocol:NSURLSessionDownloadDelegate.self ).subscribeNext { (ractuple) -> Void in
//            println(ractuple)
//            println("Heloo world")
//        }
        
        let mimeType = APIClient.mimeType(fileType: baseEncryptionModel.fileType)
        let baseEncryptedModelUri = baseEncryptionModel.uri
        
        let task = urlSessionDownloadTask(httpMethod.get, url: baseEncryptionModel.uri, acceptHeader: mimeType, progress: progress, success: { (url) -> Void in
        
            var changedBaseEncryptedModel : POSBaseEncryptedModel?
            if baseEncryptedModelIsAttachment {
                changedBaseEncryptedModel = POSAttachment.existingAttachmentWithUri(baseEncryptedModelUri, inManagedObjectContext: POSModelManager.sharedManager().managedObjectContext)
            }else {
                changedBaseEncryptedModel = POSReceipt.existingReceiptWithUri(baseEncryptedModelUri, inManagedObjectContext: POSModelManager.sharedManager().managedObjectContext)
            }
            let filePath = changedBaseEncryptedModel?.decryptedFilePath()
            if (filePath == nil) {
                // do return nil
            }
            let fileURL = NSURL(fileURLWithPath: filePath!)
            
            var error : NSError?
            NSFileManager.defaultManager().copyItemAtURL(url, toURL: fileURL!, error: &error)
            if let actualError = error {
                println("file error \(error) ")
            }
            
            success()
            }
    , failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    private func validateOAuthToken(scope: String, success: () -> Void)  {
        let oAuthToken = OAuthToken.oAuthTokenWithScope(scope)
        if (oAuthToken?.accessToken != nil) {
            success()
            return
        }
        
        if (oAuthToken?.refreshToken != nil) {
            POSOAuthManager.sharedManager().refreshAccessTokenWithRefreshToken(oAuthToken?.refreshToken, scope: scope, success: {
                success()
                }, failure: { (error) -> Void in
                    // TODO handle failure
                    println(error)
            })
        }else if (oAuthToken == nil && scope == kOauth2ScopeFull) {
            
        } else {
            
        }
    }
    
    func cancelUpdatingReceipts() {
        
    }
    
    func cancelDownloadingBaseEncryptionModels() {
        
    }
    
    func cancelUpdatingRootResource () {
//        - (void)cancelUpdatingRootResource
//            {
//                NSURL *URL = [NSURL URLWithString:__ROOT_RESOURCE_URI__];
//                NSString *pathSuffix = [URL lastPathComponent];
//                [self cancelRequestsWithPathSuffix:pathSuffix];
//                
//                self.state = SHCAPIManagerStateUpdatingRootResourceFailed;
//        }
    }
    func responseCodeForOAuthIsUnauthorized(response: NSURLResponse) -> Bool {
        let HTTPResponse = response as NSHTTPURLResponse
        switch HTTPResponse {
        case 400:
            return true
        case 401:
            return true
        case 403:
            return true
        default:
            return false
        }
    }
    
    private class func incrementTaskCounter() {
        APIClient.sharedClient.willChangeValueForKey(Constants.APIClient.taskCounter)
        APIClient.sharedClient.taskCounter++
        APIClient.sharedClient.didChangeValueForKey(Constants.APIClient.taskCounter)
    }
    
    private class func decrementTaskCounter() {
        APIClient.sharedClient.willChangeValueForKey(Constants.APIClient.taskCounter)
        APIClient.sharedClient.taskCounter--
        APIClient.sharedClient.didChangeValueForKey(Constants.APIClient.taskCounter)
    }
    
    private class func mimeType(#fileType:String) -> String {
        let type  = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileType, nil).takeUnretainedValue()
        let mimeType = UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType).takeUnretainedValue()
        return mimeType
    }
}
