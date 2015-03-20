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
import AFNetworking
import Alamofire

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
    
    //var disposable : RACDisposable?
    
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
//    var observerTask : RACDisposable?
    var lastPerformedTask : NSURLSessionTask?
    var additionalHeaders = Dictionary<String, String>()
    var lastSetOauthTokenForAuthorizationHeader : OAuthToken?
    
    override init() {
        super.init()
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfiguration.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        let contentType = "application/vnd.digipost-\(__API_VERSION__)+json"
        additionalHeaders = [Constants.HTTPHeaderKeys.accept: contentType, "Content-type" : contentType]
        let theSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        self.session = theSession
//        updateAuthorizationHeader(kOauth2ScopeFull)
    }
    
    func removeAccessTokenUsedInLastRequest() {
        lastSetOauthTokenForAuthorizationHeader?.accessToken = nil
    }
    
    func checkForOAuthUnauthroizedOauthStatus(failure: (error: APIError) -> ()) -> (error: APIError) -> () {
        return failure
    }
    
    func updateAuthorizationHeader(scope: String) {
        let oAuthToken = OAuthToken.oAuthTokenWithScope(scope)
        if let accessToken = oAuthToken?.accessToken {
            self.additionalHeaders["Authorization"] = "Bearer \(oAuthToken!.accessToken!)"
            fileTransferSessionManager.requestSerializer.setValue("Bearer \(oAuthToken!.accessToken!)", forHTTPHeaderField: "Authorization")
            self.lastSetOauthTokenForAuthorizationHeader = oAuthToken
        } else {
            oAuthToken?.removeFromKeyChainIfNotValid()
            assert(false, "no access token to validate tokens with")
        }
    }
    
    func updateAuthorizationHeader(#oAuthToken: OAuthToken) {
        if let accessToken = oAuthToken.accessToken? {
            self.additionalHeaders["Authorization"] = "Bearer \(accessToken)"
            fileTransferSessionManager.requestSerializer.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            self.lastSetOauthTokenForAuthorizationHeader = oAuthToken
        } else {
            oAuthToken.removeFromKeyChainIfNotValid()
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
    
    func validateTokensThenPerformTask(task: NSURLSessionTask) {
        validateOAuthToken(kOauth2ScopeFull) {
            self.updateAuthorizationHeader(kOauth2ScopeFull)
            task.resume()
        }
    }
    
    func validate(#token: OAuthToken?, thenPerformTask task: NSURLSessionTask) {
        validate(oAuthToken: token) { (chosenToken) -> Void in
            self.updateAuthorizationHeader(oAuthToken: chosenToken)
            task.resume()
        }
    }
    
    func updateRootResource(#success: (Dictionary<String, AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let highestToken = OAuthToken.oAuthTokenWithHigestScopeInStorage()
        self.updateAuthorizationHeader(oAuthToken: highestToken!)
        let rootResource = __ROOT_RESOURCE_URI__
        let task = urlSessionJSONTask(url: rootResource, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized {
                self.updateRootResource(success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        println("choosing highest scope: \(highestToken)")
        
        validate(token: highestToken, thenPerformTask: task!)
    }
    
    func updateRootResource(#scope: String, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let rootResource = __ROOT_RESOURCE_URI__
        self.updateAuthorizationHeader(scope)
        let task = urlSessionJSONTask(url: rootResource, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized {
                self.updateRootResource(scope: scope, success: success, failure: failure)
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
    
    func updateReceiptsInMailboxWithDigipostAddress(digipostAddress: String, uri: String, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionJSONTask(url: uri, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized  {
                self.updateReceiptsInMailboxWithDigipostAddress(digipostAddress, uri: uri, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
    
    func deleteReceipt(receipt: POSReceipt , success: () -> Void , failure: (error: APIError) -> ()) {
        let task = urlSessionTask(httpMethod.delete, url: receipt.deleteUri, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized {
                self.deleteReceipt(receipt, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
        validateTokensThenPerformTask(task!)
    }
    
    func validateOpeningReceipt(attachment: POSAttachment, success: () -> Void , failure: (error: APIError) -> ()) {
        let task  = urlSessionTask(httpMethod.post, url:attachment.openingReceiptUri, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized  {
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
        var attachmentScope : String?
        if oAuthToken == nil && didChooseHigherScope {
            let attachment = baseEncryptionModel as POSAttachment
            attachmentScope  = OAuthToken.oAuthScopeForAuthenticationLevel(attachment.authenticationLevel)
            oAuthToken = OAuthToken.oAuthTokenWithScope(attachmentScope!)
        }
        
        if oAuthToken == nil {
            let attachment = baseEncryptionModel as POSAttachment
            attachmentScope  = OAuthToken.oAuthScopeForAuthenticationLevel(attachment.authenticationLevel)
            failure(error: APIError.HasNoOAuthTokenForScopeError(attachmentScope!))
            return
        }
        
        let mimeType = APIClient.mimeType(fileType: baseEncryptionModel.fileType)
        let baseEncryptedModelUri = baseEncryptionModel.uri
        
        let task = urlSessionDownloadTask(httpMethod.get, encryptionModel: baseEncryptionModel, acceptHeader: mimeType, progress: progress, success: { (url) -> Void in
            success()
            }, failure: { (error) -> () in
                if error.code == Constants.Error.Code.oAuthUnathorized  {
                    self.downloadBaseEncryptionModel(baseEncryptionModel, withProgress: progress, success: success, failure: failure)
                } else {
                    failure(error: error)
                }
            })
        let oAuthTokenInStorage = OAuthToken.oAuthTokenWithScope(highestScope!)
        validate(token: oAuthToken, thenPerformTask: task!)
    }
    
    func uploadFile(#url: NSURL, folder: POSFolder, success: (() -> Void)? , failure: (error: APIError) -> ()) {
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
//            self.removeTemporaryUploadFiles()
//            self.isUploadingFile = false
//            if (error != nil ){
//                failure(error: APIError(error: error!))
//            } else {
//                success?()
//            }
        }

        fileTransferSessionManager.setTaskDidSendBodyDataBlock { (session, task, bytesSent, totalBytesSent, totalBytesExcpectedToSend) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                let totalSent = totalBytesSent as Int64
                self.uploadProgress?.completedUnitCount = totalSent
            })
        }

        let task = self.fileTransferSessionManager.dataTaskWithRequest(urlRequest, completionHandler: { (response, anyObject, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.removeTemporaryUploadFiles()
                self.isUploadingFile = false
                if self.isUnauthorized(response as NSHTTPURLResponse?) {
                    self.removeAccessTokenUsedInLastRequest()
                    self.uploadFile(url: url, folder: folder, success: success, failure: failure)
                } else if (error != nil ){
                    failure(error: APIError(error: error!))
                }

                if success != nil {
                    success!()
                }
            })
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
    
    private func validate(#oAuthToken: OAuthToken?, validationSuccess: (chosenToken: OAuthToken) -> Void)  {
        if (oAuthToken?.accessToken != nil) {
            validationSuccess(chosenToken: oAuthToken!)
            return
        }
        
        if (oAuthToken?.refreshToken != nil && oAuthToken?.refreshToken != "") {
            POSOAuthManager.sharedManager().refreshAccessTokenWithRefreshToken(oAuthToken?.refreshToken, scope: oAuthToken!.scope, success: {
                let newToken = OAuthToken.oAuthTokenWithScope(oAuthToken!.scope!)
                validationSuccess(chosenToken: newToken!)
                
                }, failure: { (error) -> Void in
                    // TODO handle failure
                    println(error)
            })
        }else if (oAuthToken == nil) {
            assert(false," something wrong with oauth token")
        } else {
            oAuthToken?.removeFromKeyChain()
            let lowerLevelOAuthToken = OAuthToken.oAuthTokenWithHigestScopeInStorage()
            if (lowerLevelOAuthToken != nil) {
                validate(oAuthToken: lowerLevelOAuthToken, validationSuccess: validationSuccess)
            } else {
                assert(false, "NO oauthtoken present in app. Log out!")
            }
            // has found higher level oAuthToken that is outdated, try refreshing a lower level token
            
            
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
