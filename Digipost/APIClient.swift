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
import MobileCoreServices
import Darwin
import AFNetworking

class APIClient : NSObject, NSURLSessionTaskDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate {


    var stylepickerViewController : StylePickerViewController!

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

    lazy var fileTransferSessionManager : AFHTTPSessionManager = {
        let manager = AFHTTPSessionManager(baseURL: nil)
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        #if __ACCEPT_SELF_SIGNED_CERTIFICATES__
            manager.securityPolicy.allowInvalidCertificates = true
        #endif
        return manager
        }()

    lazy var queue = NSOperationQueue()
    var session : NSURLSession!
    var uploadProgress : NSProgress?
    var taskCounter = 0
    var isUploadingFile = false
    var uploadFolderName : NSString = "Inbox"
    var taskWasUnAuthorized : Bool  = false
    var lastPerformedTask : NSURLSessionTask?
    var additionalHeaders = Dictionary<String, String>()
    var lastSetOauthTokenForAuthorizationHeader : OAuthToken?

    override init() {
        super.init()
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfiguration.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        let contentType = "application/vnd.digipost-\(k__API_VERSION__)+json"
        additionalHeaders = [Constants.HTTPHeaderKeys.accept: contentType, "Content-type" : contentType]
        let theSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)

        self.session = theSession
    }

    func removeAccessTokenUsedInLastRequest() {
        lastSetOauthTokenForAuthorizationHeader?.accessToken = nil
    }

    func checkForOAuthUnauthroizedOauthStatus(failure: (error: APIError) -> ()) -> (error: APIError) -> () {
        return failure
    }

    func updateAuthorizationHeader(scope: String) {
        let oAuthToken = OAuthToken.oAuthTokenWithScope(scope)
        if (oAuthToken?.accessToken != nil) {
            self.additionalHeaders["Authorization"] = "Bearer \(oAuthToken!.accessToken!)"
            fileTransferSessionManager.requestSerializer.setValue("Bearer \(oAuthToken!.accessToken!)", forHTTPHeaderField: "Authorization")
            self.lastSetOauthTokenForAuthorizationHeader = oAuthToken
        } else {
            oAuthToken?.removeFromKeyChainIfNotValid()
            assert(false, "no access token to validate tokens with")
        }
    }

    func updateAuthorizationHeader(oAuthToken oAuthToken: OAuthToken) {
        if let accessToken = oAuthToken.accessToken {
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
                let escapedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                urlString = "\(urlString)&\(escapedKey)=\(value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)"
            }
        }
        return urlString
    }

    private func validateFullScope(success success: () -> Void, failure: ((error: NSError) -> Void)?) {
        let fullToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        validate(oAuthToken: fullToken, validationSuccess: { (chosenToken) -> Void in
            self.updateAuthorizationHeader(oAuthToken: chosenToken)
            success()
        }, failure:failure )
    }

    func validateFullScope(then then: () -> Void) {
        let fullToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        validate(oAuthToken: fullToken, validationSuccess: { (chosenToken) -> Void in
            self.updateAuthorizationHeader(oAuthToken: chosenToken)
            then()
        },failure: nil)
    }

    func validate(token token: OAuthToken?, then: () -> Void) {
        validate(oAuthToken: token, validationSuccess: { (chosenToken) -> Void in
            self.updateAuthorizationHeader(oAuthToken: chosenToken)
            then()
        }, failure: nil)
    }

    func updateRootResource(success success: (Dictionary<String, AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let highestToken = OAuthToken.oAuthTokenWithHigestScopeInStorage()
        self.updateAuthorizationHeader(oAuthToken: highestToken!)
        let rootResource = k__ROOT_RESOURCE_URI__
        validate(token: highestToken) {
            let task = self.urlSessionJSONTask(url: rootResource, success: success, failure: failure)
            task.resume()
        }
    }

    func updateRootResource(scope scope: String, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let rootResource = k__ROOT_RESOURCE_URI__
        self.updateAuthorizationHeader(scope)
        validateFullScope {
            let task = self.urlSessionJSONTask(url: rootResource, success: success, failure: failure)
            task.resume()
        }
    }

    func updateBankAccount(uri uri : String, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        validateFullScope {
            let task = self.urlSessionJSONTask(url: uri, success: success, failure: failure)
            task.resume()
        }
    }

    func sendInvoideToBank(invoice: POSInvoice , success: () -> Void , failure: (error: APIError) -> ()) {
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.post, url: invoice.sendToBankUri, success: success, failure: failure)
            task.resume()
        }
    }

    func updateReceiptsInMailboxWithDigipostAddress(digipostAddress: String, uri: String, parameters: [String : AnyObject]? = nil, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        validateFullScope {
            
            let task = self.urlSessionJSONTask(url: uri, parameters: parameters, success: success, failure: failure)
            task.resume()
        }
    }
    
    // mock data function
    func updateReceiptsInMailboxWithDigipostAddress2(digipostAddress: String, uri: String, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        
        
        // mock receipt
        var sampleReceipt = Dictionary<String,AnyObject>()
        sampleReceipt["amount"] = 1333337
        sampleReceipt["franchiseName"] = "Topppris"
        sampleReceipt["storeName"] = "Askeladdens Hemmelige Butikk"
        sampleReceipt["timeOfPurchase"] = "2016-02-29T13:33:37"
        sampleReceipt["deleteUri"] = "deleteUri"
        sampleReceipt["uri"] = "uri"

        var mockReceiptArray = []
        for _ in 1...200 {
            mockReceiptArray = mockReceiptArray.arrayByAddingObject(sampleReceipt)
        }

        success(["receipt" : mockReceiptArray])
    }

    func deleteReceipt(receipt: POSReceipt , success: () -> Void , failure: (error: APIError) -> ()) {
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.delete, url: receipt.deleteUri, success: success, failure: failure)
            task.resume()
        }
    }

    func validateOpeningReceipt(attachment: POSAttachment, success: () -> Void , failure: (error: APIError) -> ()) {
        let scope = OAuthToken.oAuthScopeForAuthenticationLevel(attachment.authenticationLevel)
        let highestToken = OAuthToken.oAuthTokenWithScope(scope)
        validate(token: highestToken) { () -> Void in
            let task = self.urlSessionTask(httpMethod.post, url:attachment.openingReceiptUri, success: success, failure: failure)
            task.resume()
        }
    }

    func logoutThenDeleteAllStoredData() {
        cancelAllRunningTasks { () -> Void in
            self.logout(success: { () -> Void in
                // get run for every time a sucessful scope logs out
                }) { (error) -> () in
                // gets run for every failed request
            }
        }
    }

    /**
    success and failure blocks are run multiple times depending on how many requests are done
    logs out OAuth tokens for all scopes in storage

    */
    private func logout(success success: () -> Void, failure: (error: APIError) -> ()) {
        let rootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext)
        if rootResource == nil {
            success()
            return
        }
        let logoutURI = rootResource.logoutUri
        // if validation fails, just delete everything to make sure user will get correctly logged out in app
        POSModelManager.sharedManager().deleteAllObjects()
        validateFullScope(success: {
            let task = self.urlSessionTask(httpMethod.post, url: logoutURI, success: success, failure: failure)
            task.resume()
            
            self.logoutHigherLevelTokens(logoutURI, success: success, failure: failure)
            
            OAuthToken.removeAllTokens()
            POSModelManager.sharedManager().deleteAllObjects()
            POSFileManager.sharedFileManager().removeAllFiles()
            
            }) { (error) -> Void in
                
                self.logoutHigherLevelTokens(logoutURI, success: success, failure: failure)
                
                OAuthToken.removeAllTokens()
                POSModelManager.sharedManager().deleteAllObjects()
                POSFileManager.sharedFileManager().removeAllFiles()
        }
    }

    private func logoutHigherLevelTokens(logoutUri: String, success: () -> Void, failure: (error: APIError) -> ()) {
        if let fullHighAuthToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFullHighAuth) {
            self.validate(token: fullHighAuthToken, then: {
                let task = self.urlSessionTask(httpMethod.post, url: logoutUri, success: success, failure: failure)
                task.resume()
            })
        }
        if let idPorten3Token = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull_Idporten3) {
            self.validate(token: idPorten3Token, then: {
                let task = self.urlSessionTask(httpMethod.post, url: logoutUri, success: success, failure: failure)
                task.resume()
            })
        }
        if let idPorten4Token = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull_Idporten4) {
            self.validate(token: idPorten4Token, then: {
                let task = self.urlSessionTask(httpMethod.post, url: logoutUri, success: success, failure: failure)
                task.resume()
            })
        }
    }

    func cancelAllRunningTasks(then: () -> Void) {
        self.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
            self.cancelTasks(dataTasks)
            self.cancelTasks(uploadTasks)
            self.cancelTasks(downloadTasks)
            then()
        }
    }

    private func cancelTasks(tasks: [AnyObject]) {
        for object in tasks {
            if let task = object as? NSURLSessionTask {
                task.cancel()
            }
        }
    }

    func cancelLastDownloadingBaseEncryptionModel() {
        self.fileTransferSessionManager.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
            self.cancelTasks(downloadTasks)
        }
    }

    func downloadBaseEncryptionModel(baseEncryptionModel: POSBaseEncryptedModel, withProgress progress: NSProgress, success: () -> Void , failure: (error: APIError) -> ()) {
        var didChooseHigherScope = false
        var highestScope : String?
        if let attachment = baseEncryptionModel as? POSAttachment {
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
            let attachment = baseEncryptionModel as! POSAttachment
            attachmentScope  = OAuthToken.oAuthScopeForAuthenticationLevel(attachment.authenticationLevel)
            oAuthToken = OAuthToken.oAuthTokenWithScope(attachmentScope!)
        }

        if oAuthToken == nil {
            let attachment = baseEncryptionModel as! POSAttachment
            attachmentScope  = OAuthToken.oAuthScopeForAuthenticationLevel(attachment.authenticationLevel)
            failure(error: APIError.HasNoOAuthTokenForScopeError(attachmentScope!))
            return
        }
        let mimeType = APIClient.mimeType(fileType: baseEncryptionModel.fileType)
        OAuthToken.oAuthTokenWithScope(highestScope!)

        validate(token: oAuthToken) { () -> Void in
            let task = self.urlSessionDownloadTask(httpMethod.get, encryptionModel: baseEncryptionModel, acceptHeader: mimeType, progress: progress, success: { (url) -> Void in
                success()
                }, failure: { (error) -> () in
                    failure(error: error)
            })
            task.resume()
        }
    }

    func send(htmlContent: String, recipients: [Recipient], uri: String, success: (() -> Void) , failure: (error: APIError) -> ()) {
//        let url = NSURL(string: uri)
//        let oauthToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
//        let sendableDocument = SendableDocument(recipients: recipients)
//        let parameters = sendableDocument.draftParameters()
//        validate(token: oauthToken) { () -> Void in
//            let task = self.urlSessionJSONTask(httpMethod.post, url: uri, parameters: parameters , success: { (responseJSON) -> Void in
//                sendableDocument.setupWithJSONContent(responseJSON)
//                sendableDocument.recipients = recipients
//                let fileURL = sendableDocument.urlForHTMLContentOnDisk(htmlContent)
//                self.uploadFile(sendableDocument.addContentUri!, fileURL: fileURL!, success: { () -> Void in
//                    self.getUpdatedSendableDocument(sendableDocument, success: { (responseDictionary) -> Void in
//                        sendableDocument.setupWithJSONContent(responseDictionary)
//                        println(responseDictionary)
//                        let task = self.urlSessionTask(httpMethod.post, url: sendableDocument.sendUri!, success: { () -> Void in
//                            success()
//                            }, failure: { (error) -> () in
//                                failure(error: error)
//                        })
//                        task!.resume()
//
//                        }, failure: { (error) -> () in
//                            failure(error: error)
//                    })
//                    }, failure: { (error) -> () in
//                        failure(error: error)
//                })
//                }, failure: { (error) -> () in
//                    failure(error: error)
//            })
//            task!.resume()
//        }
    }

    func getDrafts(uri: String, success: (responseDictionary: [String : AnyObject]) -> Void, failure: (error: APIError) -> ()) {
//        let offset = 0
//        let length = 50000

//        validateOAuthToken(kOauth2ScopeFull, validationSuccess: {
//            let task = self.urlSessionJSONTask(url: uri, success: { (responseDictionary) -> Void in
//                success(responseDictionary: responseDictionary)
//            }, failure: { (error) -> () in
//                failure(error: error)
//            })
//        })
    }

    func getUpdatedSendableDocument(sendableDocument: SendableDocument, success: (responseDictionary: [String : AnyObject]) -> Void, failure: (error: APIError) -> ()) {
        let oauthToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        validate(token: oauthToken) { () -> Void in
//            let task = self.urlSessionJSONTask(url: sendableDocument.updateMessageUri!, success: { (responseDictionary) -> Void in
//                success(responseDictionary: responseDictionary)
//                }, failure: { (error) -> () in
//                    failure(error: error)
//            })
//            task!.resume()
        }
    }

    func uploadFile(uploadUri: String, fileURL: NSURL, success: (() -> Void)? , failure: (error: APIError) -> ()) {
        let urlRequest = fileTransferSessionManager.requestSerializer.multipartFormRequestWithMethod(httpMethod.post.rawValue, URLString: uploadUri, parameters: nil,  constructingBodyWithBlock: { (formData) -> Void in

            let data = "test".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            formData.appendPartWithFormData(data!, name:"subject")

            let fileData = NSData(contentsOfURL: fileURL)
            formData.appendPartWithFileData(fileData!, name: "file", fileName: "test.html", mimeType:"text/html")
            },error: nil)
        
        urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")

        fileTransferSessionManager.setTaskDidCompleteBlock { (session, task, error) -> Void in

        }

        fileTransferSessionManager.setTaskDidSendBodyDataBlock { (session, task, bytesSent, totalBytesSent, totalBytesExcpectedToSend) -> Void in
        }

        let task = self.fileTransferSessionManager.dataTaskWithRequest(urlRequest, completionHandler: { (response, anyObject, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.removeTemporaryUploadFiles()
                self.isUploadingFile = false
                //let s = NSString(data: anyObject as! NSData, encoding: NSASCIIStringEncoding)
                
//                if self.isUnauthorized(response as! NSHTTPURLResponse?) {
//                    self.removeAccessTokenUsedInLastRequest()
                    //                    self.uploadFile(url: url, folder: folder, success: success, failure: failure)
//                } else if (error != nil ){
//                    failure(error: APIError(error: error!))
//                }

                if success != nil {
                    success!()
                }
            })
        })
        task.resume()
    }

    func uploadFile(url url: NSURL, folder: POSFolder, success: (() -> Void)? , failure: (error: APIError) -> ()) {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(url.path!) == false {
            let error = APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.uploadFileDoesNotExist.rawValue, userInfo: nil)
            failure(error: error)
        }
        let fileAttributes : [String:AnyObject]? = {
            do {
                return try fileManager.attributesOfItemAtPath(url.path!)
            }catch let error as NSError{
                failure(error: APIError(error: error))
                return nil
            }
        }()

        let maxFileSize = pow(Float(2),Float(20)) * 100
        let fileSize = fileAttributes![NSFileSize] as! Float

        if (fileSize > maxFileSize) {
            let tooBigError = APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.uploadFileTooBig.rawValue, userInfo: nil)
            failure(error: tooBigError)
            return
        }

        let rootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext)
        if rootResource.uploadDocumentUri.characters.count <= 0 {
            let noUploadLinkError = APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.uploadLinkNotFoundInRootResource.rawValue, userInfo: nil)
            failure(error: noUploadLinkError)
            return
        }

        removeTemporaryUploadFiles()

        let uploadsFolderPath = POSFileManager.sharedFileManager().uploadsFolderPath()
        let fileName = url.lastPathComponent
        let uploadURL = uploadsFolderPath.urlRepresentation().URLByAppendingPathComponent(fileName!)

        do{
            try fileManager.moveItemAtURL(url, toURL: uploadURL)
        }catch let error as NSError{
            failure(error: APIError(error: error))
        }

        let serverUploadURL = NSURL(string: folder.uploadDocumentUri)
        var userInfo = Dictionary <NSObject,AnyObject>()
        userInfo["fileName"] = fileName
        let progress = NSProgress(parent: nil, userInfo:userInfo)
        progress.totalUnitCount = Int64(fileSize)
        self.uploadProgress = progress
        let lastPathComponent : NSString = uploadURL.lastPathComponent as NSString!
        let pathExtension = lastPathComponent.pathExtension
        
        let urlRequest = fileTransferSessionManager.requestSerializer.multipartFormRequestWithMethod(httpMethod.post.rawValue, URLString: (serverUploadURL?.absoluteString)!, parameters: nil, constructingBodyWithBlock: { (formData) -> Void in
            var subject : String?
            if let rangeOfExtension = fileName!.rangeOfString(".\(pathExtension)")  {
                subject = fileName?.substringToIndex(rangeOfExtension.startIndex)
            } else {
                subject = fileName
            }

            let data = subject?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            formData.appendPartWithFormData(data!, name:"subject")

            let fileData = NSData(contentsOfURL: uploadURL)
            formData.appendPartWithFileData(fileData!, name:"file", fileName: fileName!, mimeType:"application/pdf")
        }, error: nil)
        
        urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")
        fileTransferSessionManager.setTaskDidCompleteBlock { (session, task, error) -> Void in
        }

        fileTransferSessionManager.setTaskDidSendBodyDataBlock { (session, task, bytesSent, totalBytesSent, totalBytesExcpectedToSend) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                let totalSent = totalBytesSent as Int64
                if let actualProgress = self.uploadProgress {
                    actualProgress.completedUnitCount = totalSent
                }
            })
        }
        validateFullScope { () -> Void in
            let task = self.fileTransferSessionManager.dataTaskWithRequest(urlRequest, completionHandler: { (response, anyObject, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.removeTemporaryUploadFiles()
                    self.isUploadingFile = false
                    if (error != nil ){
                        failure(error: APIError(error: error!))
                    }

                    if success != nil {
                        success!()
                    }
                })
            })
            task.resume()
        }
        self.uploadFolderName = folder.name
        self.isUploadingFile = true
    }

    func postLog(uri uri: String, parameters: [String : AnyObject]) {
        let baseUri = k__SERVER_URI__
        let completeUri = "\(baseUri)\(uri)"
        let task = self.urlSessionTaskWithNoAuthorizationHeader(httpMethod.post, url: completeUri, parameters: parameters, success: { () -> Void in
            DLog("Successfully sent log with parameters: \(parameters)")
        }) { (error) -> Void in
            DLog("Could not send log with parameters: \(parameters), got error: \(error)")
        }
        task.resume()
    }

    func removeTemporaryUploadFiles () {
        let uploadsPath = POSFileManager.sharedFileManager().uploadsFolderPath()
        POSFileManager.sharedFileManager().removeAllFilesInFolder(uploadsPath)
    }

    private func validate(oAuthToken oAuthToken: OAuthToken?, validationSuccess: (chosenToken: OAuthToken) -> Void, failure: ((error: NSError) -> Void)?) {
        if oAuthToken?.hasExpired() == false {
            validationSuccess(chosenToken: oAuthToken!)
            return
        }

        if (oAuthToken?.refreshToken != nil && oAuthToken?.refreshToken != "") {
            POSOAuthManager.sharedManager().refreshAccessTokenWithRefreshToken(oAuthToken?.refreshToken, scope: oAuthToken!.scope, success: {
                let newToken = OAuthToken.oAuthTokenWithScope(oAuthToken!.scope!)
                validationSuccess(chosenToken: newToken!)
                }, failure: { (error) -> Void in
                    if error.code == Int(SHCOAuthErrorCode.InvalidRefreshTokenResponse.rawValue) {
                        self.deleteRefreshTokensAndLogoutUser()
                    } else {
                        failure?(error: error)
                    }
            })
        } else {
            // if oauthoken does not have a refreshtoken, it means its a higher level token
            // delete the token and "jump" to a higher or lower level based on if you have valid tokens for that scope
            // for example when refreshing list with idporten 4, then jumping down to full scope if the idporten 4 token was expired

            if let actualOAuthToken = oAuthToken {
                if actualOAuthToken.hasExpired() {
                    actualOAuthToken.accessToken = nil
                }
            }
            oAuthToken?.removeFromKeychainIfNoAccessToken()
            let lowerLevelOAuthToken = OAuthToken.oAuthTokenWithHigestScopeInStorage()
            if (lowerLevelOAuthToken != nil) {
                validate(oAuthToken: lowerLevelOAuthToken, validationSuccess: validationSuccess, failure: failure)
            } else {
                Logger.dpostLogError("User revoked OAuth token and had no lower level token to fall back on", location: "Unknown, anywhere where there is a request to digipost API", UI: "User gets logged out", cause: "Lower level token was revoked, because of a http 401 from server")
                failure?(error: NSError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.NoOAuthTokenPresent.rawValue, userInfo: nil))
            }
        }
    }

    /**
    Called when refresh tokens are invalidated server side
    */
    private func deleteRefreshTokensAndLogoutUser() {
        let appDelegate: SHCAppDelegate = UIApplication.sharedApplication().delegate as! SHCAppDelegate
        if let letterViewController: POSLetterViewController = appDelegate.letterViewController {
            letterViewController.attachment = nil
            letterViewController.receipt = nil
        }

        let fullToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        fullToken?.accessToken = nil
        fullToken?.refreshToken = nil

        APIClient.sharedClient.logoutThenDeleteAllStoredData()
        let alertController = UIAlertController.forcedLogoutAlertController()
        let userInfo  : [NSObject : AnyObject] = [ "alert" as NSObject : alertController as AnyObject]
        NSNotificationCenter.defaultCenter().postNotificationName(kShowLoginViewControllerNotificationName, object: nil, userInfo: userInfo)
    }

    func responseCodeForOAuthRefreshTokenRenewaIsUnauthorized(response: NSURLResponse) -> Bool {
        let HTTPResponse = response as! NSHTTPURLResponse
        switch HTTPResponse.statusCode {
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

    func responseCodeForOAuthIsUnauthorized(response: NSURLResponse) -> Bool {
        let HTTPResponse = response as! NSHTTPURLResponse
        switch HTTPResponse.statusCode {
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
        APIClient.sharedClient.taskCounter += 1
        APIClient.sharedClient.didChangeValueForKey(Constants.APIClient.taskCounter)
    }

    private class func decrementTaskCounter() {
        APIClient.sharedClient.willChangeValueForKey(Constants.APIClient.taskCounter)
        APIClient.sharedClient.taskCounter -= 1
        APIClient.sharedClient.didChangeValueForKey(Constants.APIClient.taskCounter)
    }
    
    private class func mimeType(fileType fileType:String) -> String {
        let type  = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileType, nil)!.takeUnretainedValue()
        let findTag  = UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType)
        if findTag != nil {
            let mimeType = findTag!.takeRetainedValue()
            return mimeType as String
        }else {
            return ""
        }
    }
}
