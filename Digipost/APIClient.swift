//
//  APIClient.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation
import MobileCoreServices
import Darwin

class APIClient : NSObject, NSURLSessionTaskDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate {
    
    class var sharedClient: APIClient {
        struct Singleton {
            static let sharedClient = APIClient()
        }
        
        return Singleton.sharedClient
    }
    
    enum httpMethod : String {
        case post = "POST"
        case delete = "DELETE"
        case update = "UPDATE"
        case put = "PUT"
        case get = "GET"
    }
    
    var disposable : RACDisposable?
    
    lazy var fileTransferSessionManager : AFHTTPSessionManager = {
        let manager = AFHTTPSessionManager(baseURL: nil)
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        return manager
    }()
    
    lazy var queue = NSOperationQueue()
    var session : NSURLSession!
    var uploadProgress : NSProgress?
    var taskCounter = 0
    var isUploadingFile = false
    var taskWasUnAuthorized : Bool  = false
    var observerTask : RACDisposable?
    var lastPerformedTask : NSURLSessionTask?
    var additionalHeaders = Dictionary<String, String>()
    
    override init() {
        super.init()
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfiguration.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        let contentType = "application/vnd.digipost-\(__API_VERSION__)+json"
        additionalHeaders = [Constants.HTTPHeaderKeys.accept: contentType, "Content-type" : contentType]
        let theSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        self.session = theSession
        updateAuthorizationHeader(kOauth2ScopeFull)
    }
    
    func removeAccessToken() {
        OAuthToken.removeAcessTokenForOAuthTokenWithScope(kOauth2ScopeFull)
    }
    
    func checkForOAuthUnauthroizedOauthStatus(failure: (error: APIError) -> ()) -> (error: APIError) -> () {
        return failure
    }
    
    func updateAuthorizationHeader(scope: String) {
        let athing = self.session.delegate! as NSURLSessionDelegate
        let oAuthToken = OAuthToken.oAuthTokenWithScope(scope)
        if let accessToken = oAuthToken?.accessToken {
            self.additionalHeaders["Authorization"] = "Bearer \(oAuthToken!.accessToken!)"
            fileTransferSessionManager.requestSerializer.setValue("Bearer \(oAuthToken!.accessToken!)", forHTTPHeaderField: "Authorization")
        } else {
            println("FATAL")
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
        validateOAuthToken(kOauth2ScopeFull) {
            self.updateAuthorizationHeader(kOauth2ScopeFull)
            task.resume()
        }
    }
    
    private func validateTokensWithHigherScopeThenPerformTak(scope: String, task: NSURLSessionTask) {
        validateOAuthToken(scope) {
            self.updateAuthorizationHeader(scope)
            task.resume()
        }
    }
    
    func changeName(folder: POSFolder, newName name: String, newIconName iconName: String, success: () -> Void , failure: (error: APIError) -> ()) {
        let parameters = [ "id" : folder.folderId, "name" : name, "icon" : iconName]
        let task = urlSessionTask(httpMethod.put, url: folder.changeFolderUri, parameters: parameters, success: success) { (error) -> Void in
            if (error.code == Constants.Error.Code.oAuthUnathorized ) {
                self.changeName(folder, newName: name, newIconName: iconName, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
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
        let task = urlSessionTask(httpMethod.post, url: document.updateUri, parameters: parameters, success: success) { (error) -> () in
            if (error.code == Constants.Error.Code.oAuthUnathorized ) {
                self.changeName(document, newName: name, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
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
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue {
                self.delete(folder: folder, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
    
    func updateRootResource(#success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let rootResource = __ROOT_RESOURCE_URI__
        let task = urlSessionJSONTask(url: rootResource, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue {
                self.updateRootResource(success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
    
    func updateBankAccount(#uri : String, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionJSONTask(url: uri, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue {
                self.updateBankAccount(uri: uri, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
    
    func sendInvoideToBank(invoice: POSInvoice , success: () -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionTask(httpMethod.post, url: invoice.sendToBankUri, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized {
                self.sendInvoideToBank(invoice, success: success, failure: failure)
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
    
    func updateReceiptsInMailboxWithDigipostAddress(digipostAddress: String, uri: String, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionJSONTask(url: uri, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue  {
                self.updateReceiptsInMailboxWithDigipostAddress(digipostAddress, uri: uri, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
    
    func deleteReceipt(receipt: POSReceipt , success: () -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionTask(httpMethod.delete, url: receipt.deleteUri, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue  {
                self.deleteReceipt(receipt, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
    
    func validateOpeningReceipt(attachment: POSAttachment, success: () -> Void , failure: (error: APIError) -> ()) {
        let task  = urlSessionTask(httpMethod.post, url:attachment.openingReceiptUri, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue  {
                self.validateOpeningReceipt(attachment, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
    
    func logout () {
        
        logout(success: { () -> Void in
            OAuthToken.removeAllTokens()
            POSModelManager.sharedManager().deleteAllObjects()
        }) { (error) -> () in
            OAuthToken.removeAllTokens()
            POSModelManager.sharedManager().deleteAllObjects()
        }
    }
    
    private func logout(#success: () -> Void, failure: (error: APIError) -> ()) {
        let rootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext)
        if rootResource == nil {
            success()
            return
        }
        let task = urlSessionTask(httpMethod.post, url: rootResource.logoutUri, success: success, failure: failure)
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
                return
            }
            let fileURL = NSURL(fileURLWithPath: filePath!)
            
            var error : NSError?
            NSFileManager.defaultManager().copyItemAtURL(url, toURL: fileURL!, error: &error)
            if let actualError = error {
                println("file error \(error) ")
            }
            
            success()
            }, failure: failure)
        validateTokensWithHigherScopeThenPerformTak(highestScope!, task: task!)
    }
    
    func uploadFile(#url: NSURL, folder: POSFolder, success: () -> Void , failure: (error: APIError) -> ()) {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(url.path!) == false {
            let error = APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.uploadFileDoesNotExist.rawValue, userInfo: nil)
            failure(error: error)
        }
        var error : NSError?
        let fileAttributes = fileManager.attributesOfItemAtPath(url.path!, error: &error)
        if let actualError = error {
            failure(error: APIError(error: actualError))
            return
        }
        
        let maxFileSize = pow(Float(2),Float(20)) * 10
        let fileSize = fileAttributes![NSFileSize] as Float
        
        if (fileSize > maxFileSize) {
            let tooBigError = APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.uploadFileTooBig.rawValue, userInfo: nil)
            failure(error: tooBigError)
            return
       }
        
        let rootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext)
        if (rootResource.uploadDocumentUri.utf16Count) <= 0 {
            let noUploadLinkError = APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.uploadLinkNotFoundInRootResource.rawValue, userInfo: nil)
            failure(error: noUploadLinkError)
            return
        }
        // TODO CANCEL UPLOADING FILES && DELETE TEMP FILES
 //
//    // We're good to go - let's cancel any ongoing uploads and delete any previous temporary files
//    if (self.isUploadingFile) {
//    [self cancelUploadingFiles];
//    }
//    
//    [self removeTemporaryUploadFiles];
       
        removeTemporaryUploadFiles()
        
        let uploadsFolderPath = POSFileManager.sharedFileManager().uploadsFolderPath()
        let fileName = url.lastPathComponent
        let filePath = uploadsFolderPath.stringByAppendingPathComponent(fileName!)
        let uploadURL = NSURL(fileURLWithPath: filePath)
        
        if fileManager.moveItemAtURL(url, toURL: uploadURL!, error: &error) == false {
            failure(error: APIError(error: error!))
        }
        
        let serverUploadURL = NSURL(string: folder.uploadDocumentUri)
        var userInfo = Dictionary<NSObject,AnyObject>()
        userInfo["fileName"] = fileName
        self.uploadProgress = NSProgress(parent: nil, userInfo:userInfo)
        self.uploadProgress!.totalUnitCount = Int64(fileSize)
        let lastPathComponent : NSString = uploadURL?.lastPathComponent as NSString!
        let pathExtension = lastPathComponent.pathExtension
        let urlRequest = fileTransferSessionManager.requestSerializer.multipartFormRequestWithMethod(httpMethod.post.rawValue, URLString: serverUploadURL?.absoluteString, parameters: nil, constructingBodyWithBlock: { (formData) -> Void in
            
            let rangeOfExtension = fileName!.rangeOfString(".\(pathExtension)")
            var subject = fileName?.substringToIndex(rangeOfExtension!.startIndex)
            subject = subject?.stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding)
            formData.appendPartWithFormData(subject?.dataUsingEncoding(NSASCIIStringEncoding), name:"subject")
            let fileData = NSData(contentsOfURL: uploadURL!)
            formData.appendPartWithFileData(fileData, name:"file", fileName: fileName, mimeType:"application/pdf")
        }, error: nil)
        urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")
        
        fileTransferSessionManager.setTaskDidCompleteBlock { (session, task, error) -> Void in
            self.removeTemporaryUploadFiles()
            self.isUploadingFile = false
            if (error != nil ){
                failure(error: APIError(error: error!))
            } else {
                success()
            }
        }
        
        fileTransferSessionManager.setTaskDidSendBodyDataBlock { (session, task, bytesSent, totalBytesSent, totalBytesExcpectedToSend) -> Void in
            let totalSent = totalBytesSent as Int64
            self.uploadProgress?.completedUnitCount = totalSent
        }
        
        let task = self.fileTransferSessionManager.dataTaskWithRequest(urlRequest, completionHandler: { (response, anyObject, error) -> Void in
           self.removeTemporaryUploadFiles()
            self.isUploadingFile = false
            if (error != nil ){
                failure(error: APIError(error: error!))
            } else {
                success()
            }
        })
        self.isUploadingFile = true
        validateTokensThenPerformTask(task)
    }
    
    func removeTemporaryUploadFiles () {
        let uploadsPath = POSFileManager.sharedFileManager().uploadsFolderPath()
        POSFileManager.sharedFileManager().removeAllFilesInFolder(uploadsPath)
    }
   
    private func validateOAuthToken(scope: String, validationSuccess: () -> Void)  {
        let oAuthToken = OAuthToken.oAuthTokenWithScope(scope)
        if (oAuthToken?.accessToken != nil) {
            validationSuccess()
            return
        }
        
        if (oAuthToken?.refreshToken != nil) {
            POSOAuthManager.sharedManager().refreshAccessTokenWithRefreshToken(oAuthToken?.refreshToken, scope: scope, success: {
                validationSuccess()
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
        let findTag  = UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType)
        if findTag != nil {
            let mimeType = findTag.takeRetainedValue()
            return mimeType
        }else {
            return ""
        }
    }
}
