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

@objc class APIClient : NSObject, URLSessionTaskDelegate, URLSessionDelegate, URLSessionDataDelegate {
    @objc var stylepickerViewController : StylePickerViewController!

    @objc class var sharedClient: APIClient {
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
        #if ACCEPT_SELF_SIGNED_CERTIFICATES
            manager.securityPolicy.allowInvalidCertificates = true
            manager.securityPolicy.setValidatesDomainName = false
            manager.securityPolicy.validatesCertificateChain = false
        #endif
        return manager
        }()

    lazy var queue = OperationQueue()
    var session : URLSession!
    @objc var uploadProgress : Progress?
    var taskCounter = 0
    @objc var isUploadingFile = false
    @objc var uploadFolderName : NSString = "Inbox"
    var taskWasUnAuthorized : Bool  = false
    var lastPerformedTask : URLSessionTask?
    var additionalHeaders = Dictionary<String, String>()
    var lastSetOauthTokenForAuthorizationHeader : OAuthToken?

    override init() {
        super.init()
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.requestCachePolicy = NSURLRequest.CachePolicy.returnCacheDataElseLoad
        let contentType = "application/vnd.digipost-\(k__API_VERSION__)+json"
        additionalHeaders = [Constants.HTTPHeaderKeys.accept: contentType, "Content-type" : contentType]
        let theSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)

        self.session = theSession
    }

    func removeAccessTokenUsedInLastRequest() {
        lastSetOauthTokenForAuthorizationHeader?.accessToken = nil
    }

    func checkForOAuthUnauthroizedOauthStatus(_ failure: @escaping (_ error: APIError) -> ()) -> (_ error: APIError) -> () {
        return failure
    }

    @objc func updateAuthorizationHeader(_ scope: String) {
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

    func updateAuthorizationHeader(oAuthToken: OAuthToken) {
        if let accessToken = oAuthToken.accessToken {
            self.additionalHeaders["Authorization"] = "Bearer \(accessToken)"
            fileTransferSessionManager.requestSerializer.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            self.lastSetOauthTokenForAuthorizationHeader = oAuthToken
        } else {
            oAuthToken.removeFromKeyChainIfNotValid()
        }
    }

    class func stringFromArguments(_ arguments: Dictionary<String,AnyObject>?) -> String? {
        var urlString: String = ""
        if let actualArguments  = arguments {
            for (key,value) in actualArguments {
                let escapedKey = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                urlString = "\(urlString)&\(String(describing: escapedKey))=\(value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)"
            }
        }
        return urlString
    }

    fileprivate func validateFullScope(success: @escaping () -> Void, failure: ((_ error: NSError) -> Void)?) {
        let fullToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        validate(oAuthToken: fullToken, validationSuccess: { (chosenToken) -> Void in
            self.updateAuthorizationHeader(oAuthToken: chosenToken)
            success()
        }, failure:failure )
    }

    func validateFullScope(then: @escaping () -> Void) {
        let fullToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        validate(oAuthToken: fullToken, validationSuccess: { (chosenToken) -> Void in
            self.updateAuthorizationHeader(oAuthToken: chosenToken)
            then()
        },failure: nil)
    }

    func validate(token: OAuthToken?, then: @escaping () -> Void) {
        validate(oAuthToken: token, validationSuccess: { (chosenToken) -> Void in
            self.updateAuthorizationHeader(oAuthToken: chosenToken)
            then()
        }, failure: nil)
    }

    @objc func updateRootResource(success: @escaping (Dictionary<String, AnyObject>) -> Void , failure: @escaping (_ error: APIError) -> ()) {
        let token = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        self.updateAuthorizationHeader(oAuthToken: token!)
        let rootResource = k__ROOT_RESOURCE_URI__
        validate(token: highestToken) {
            let task = self.urlSessionJSONTask(url: rootResource, success: success, failure: failure)
            task.resume()
        }
    }

    @objc func updateRootResource(scope: String, success: @escaping (Dictionary<String,AnyObject>) -> Void , failure: @escaping (_ error: APIError) -> ()) {
        let rootResource = k__ROOT_RESOURCE_URI__
        self.updateAuthorizationHeader(scope)
        validateFullScope {
            let task = self.urlSessionJSONTask(url: rootResource, success: success, failure: failure)
            task.resume()
        }
    }

    @objc func updateBankAccount(uri : String, success: @escaping (Dictionary<String,AnyObject>) -> Void , failure: @escaping (_ error: APIError) -> ()) {
        validateFullScope {
            let task = self.urlSessionJSONTask(url: uri, success: success, failure: failure)
            task.resume()
        }
    }

    @objc func sendInvoiceToBank(_ invoice: POSInvoice , success: @escaping () -> Void , failure: @escaping (_ error: APIError) -> ()) {
        validateFullScope {
            let task = self.urlSessionTask(httpMethod.post, url: invoice.sendToBankUri, success: success, failure: failure)
            task.resume()
        }
    }
    
    @objc func validateOpeningReceipt(_ attachment: POSAttachment, success: @escaping () -> Void , failure: @escaping (_ error: APIError) -> ()) {
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
    fileprivate func logout(success: @escaping () -> Void, failure: @escaping (_ error: APIError) -> ()) {
        let rootResource = POSRootResource.existingRootResource(in: POSModelManager.shared().managedObjectContext)
        if rootResource == nil {
            success()
            return
        }
        let logoutURI = rootResource?.logoutUri
        // if validation fails, just delete everything to make sure user will get correctly logged out in app
        POSModelManager.shared().deleteAllObjects()
        validateFullScope(success: {
            let task = self.urlSessionTask(httpMethod.post, url: logoutURI!, success: success, failure: failure)
            task.resume()
            
            self.logoutHigherLevelTokens(logoutURI!, success: success, failure: failure)
            
            OAuthToken.removeAllTokens()
            POSModelManager.shared().deleteAllObjects()
            POSFileManager.shared().removeAllFiles()
            
            }) { (error) -> Void in
                
                self.logoutHigherLevelTokens(logoutURI!, success: success, failure: failure)
                
                OAuthToken.removeAllTokens()
                POSModelManager.shared().deleteAllObjects()
                POSFileManager.shared().removeAllFiles()
        }
    }

    fileprivate func logoutHigherLevelTokens(_ logoutUri: String, success: @escaping () -> Void, failure: @escaping (_ error: APIError) -> ()) {
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

    func cancelAllRunningTasks(_ then: @escaping () -> Void) {
        self.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
            self.cancelTasks(dataTasks)
            self.cancelTasks(uploadTasks)
            self.cancelTasks(downloadTasks)
            then()
        }
    }

    fileprivate func cancelTasks(_ tasks: [AnyObject]) {
        for object in tasks {
            if let task = object as? URLSessionTask {
                task.cancel()
            }
        }
    }

    @objc func cancelLastDownloadingBaseEncryptionModel() {
        self.fileTransferSessionManager.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
            self.cancelTasks(downloadTasks)
        }
    }

    @objc func downloadBaseEncryptionModel(_ baseEncryptionModel: POSBaseEncryptedModel, withProgress progress: Progress, success: @escaping () -> Void , failure: @escaping (_ error: APIError) -> ()) {
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
            failure(APIError.HasNoOAuthTokenForScopeError(attachmentScope!))
            return
        }
        let mimeType = APIClient.mimeType(fileType: baseEncryptionModel.fileType)

        validate(token: oAuthToken) { () -> Void in
            let task = self.urlSessionDownloadTask(httpMethod.get, encryptionModel: baseEncryptionModel, acceptHeader: mimeType, progress: progress, success: { (url) -> Void in
                success()
                }, failure: { (error) -> () in
                    failure(error)
            })
            task.resume()
        }
    }

    func uploadFile(_ uploadUri: String, fileURL: URL, success: (() -> Void)? , failure: (_ error: APIError) -> ()) {
        let urlRequest = fileTransferSessionManager.requestSerializer.multipartFormRequest(withMethod: httpMethod.post.rawValue, urlString: uploadUri, parameters: nil,  constructingBodyWith: { (formData) -> Void in

            let data = "test".data(using: String.Encoding.utf8, allowLossyConversion: false)
            formData.appendPart(withForm: data!, name:"subject")

            let fileData = try? Data(contentsOf: fileURL)
            formData.appendPart(withFileData: fileData!, name: "file", fileName: "test.html", mimeType:"text/html")
            },error: nil)
        
        urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")

        fileTransferSessionManager.setTaskDidComplete { (session, task, error) -> Void in

        }

        fileTransferSessionManager.setTaskDidSendBodyDataBlock { (session, task, bytesSent, totalBytesSent, totalBytesExcpectedToSend) -> Void in
        }

        let task = self.fileTransferSessionManager.dataTask(with: urlRequest as URLRequest, completionHandler: { (response, anyObject, error) -> Void in
            DispatchQueue.main.async(execute: {
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

    @objc func uploadFile(url: URL, folder: POSFolder, success: (() -> Void)? , failure: @escaping (_ error: APIError) -> ()) {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: url.path) == false {
            let error = APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.uploadFileDoesNotExist.rawValue, userInfo: nil)
            failure(error)
        }

        let maxFileSize = Double(pow(Float(2),Float(20)) * 100)
        let fileSize: Double = {
            do{
                let attr:NSDictionary? = try fileManager.attributesOfItem(atPath: url.path) as NSDictionary?
                
                if let _attr = attr {
                    return Double(_attr.fileSize())
                }
            }catch let error as NSError{
                failure(APIError(error: error))
                return 0
            }
        }()

        if (fileSize > maxFileSize) {
            let tooBigError = APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.uploadFileTooBig.rawValue, userInfo: nil)
            failure(tooBigError)
            return
        }

        let rootResource = POSRootResource.existingRootResource(in: POSModelManager.shared().managedObjectContext)
        if (rootResource?.uploadDocumentUri.count)! <= 0 {
            let noUploadLinkError = APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.uploadLinkNotFoundInRootResource.rawValue, userInfo: nil)
            failure(noUploadLinkError)
            return
        }

        removeTemporaryUploadFiles()

        let uploadsFolderPath = POSFileManager.shared().uploadsFolderPath()
        let fileName = url.lastPathComponent
        let uploadURL = uploadsFolderPath?.urlRepresentation().appendingPathComponent(fileName)

        do{
            try fileManager.moveItem(at: url, to: uploadURL!)
        }catch let error as NSError{
            failure(APIError(error: error))
        }

        let serverUploadURL = URL(string: folder.uploadDocumentUri)
        var userInfo = Dictionary <ProgressUserInfoKey, String>()
        userInfo[ProgressUserInfoKey("fileName")] = fileName
        let progress = Progress(parent: nil, userInfo:userInfo)
        progress.totalUnitCount = Int64(fileSize)
        self.uploadProgress = progress
        let lastPathComponent : NSString = uploadURL!.lastPathComponent as NSString!
        let pathExtension = lastPathComponent.pathExtension
        
        let urlRequest = fileTransferSessionManager.requestSerializer.multipartFormRequest(withMethod: httpMethod.post.rawValue, urlString: (serverUploadURL?.absoluteString)!, parameters: nil, constructingBodyWith: { (formData) -> Void in
            var subject : String?
            if let rangeOfExtension = fileName.range(of: ".\(pathExtension)")  {
                subject = String(fileName[..<rangeOfExtension.lowerBound])
            } else {
                subject = fileName
            }

            let data = subject?.data(using: String.Encoding.utf8, allowLossyConversion: false)
            formData.appendPart(withForm: data!, name:"subject")
            if let fileData = try? Data.init(contentsOf: uploadURL!) {
                formData.appendPart(withFileData: fileData, name:"file", fileName: fileName, mimeType:"application/pdf")
            }
            
        }, error: nil)
        
        urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")
        fileTransferSessionManager.setTaskDidComplete { (session, task, error) -> Void in
        }

        fileTransferSessionManager.setTaskDidSendBodyDataBlock { (session, task, bytesSent, totalBytesSent, totalBytesExcpectedToSend) -> Void in
            DispatchQueue.main.async(execute: {
                let totalSent = totalBytesSent as Int64
                if let actualProgress = self.uploadProgress {
                    actualProgress.completedUnitCount = totalSent
                }
            })
        }
        validateFullScope { () -> Void in
            let task = self.fileTransferSessionManager.dataTask(with: urlRequest as URLRequest, completionHandler: { (response, anyObject, error) -> Void in
                DispatchQueue.main.async(execute: {
                    self.removeTemporaryUploadFiles()
                    self.isUploadingFile = false
                    if (error != nil ){
                        failure(APIError(error: error! as NSError))
                    }

                    if success != nil {
                        success!()
                    }
                })
            })
            task.resume()
        }
        self.uploadFolderName = folder.name as NSString
        self.isUploadingFile = true
    }

    func postLog(uri: String, parameters: [String : AnyObject]) {
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
        let uploadsPath = POSFileManager.shared().uploadsFolderPath()
        POSFileManager.shared().removeAllFiles(inFolder: uploadsPath)
    }

    fileprivate func validate(oAuthToken: OAuthToken?, validationSuccess: @escaping (_ chosenToken: OAuthToken) -> Void, failure: ((_ error: NSError) -> Void)?) {
        if oAuthToken?.hasExpired() == false {
            validationSuccess(oAuthToken!)
            return
        }

        if (oAuthToken?.refreshToken != nil && oAuthToken?.refreshToken != "") {
            POSOAuthManager.shared().refreshAccessToken(withRefreshToken: oAuthToken?.refreshToken, scope: oAuthToken!.scope, success: {
                let newToken = OAuthToken.oAuthTokenWithScope(oAuthToken!.scope!)
                validationSuccess(newToken!)
                }, failure: { (error) -> Void in
                    if error?._code == Int(SHCOAuthErrorCode.invalidRefreshTokenResponse.rawValue) {
                        self.deleteRefreshTokensAndLogoutUser()
                    } else {
                        failure?(error! as NSError)
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
                failure?(NSError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.noOAuthTokenPresent.rawValue, userInfo: nil))
            }
        }
    }

    /**
    Called when refresh tokens are invalidated server side
    */
    fileprivate func deleteRefreshTokensAndLogoutUser() {
        let appDelegate: SHCAppDelegate = UIApplication.shared.delegate as! SHCAppDelegate
        if let letterViewController: POSLetterViewController = appDelegate.letterViewController {
            letterViewController.attachment = nil
        }

        let fullToken = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
        fullToken?.accessToken = nil
        fullToken?.refreshToken = nil

        APIClient.sharedClient.logoutThenDeleteAllStoredData()
        let alertController = UIAlertController.forcedLogoutAlertController()
        let userInfo  : [AnyHashable: Any] = [ "alert" as NSObject : alertController as AnyObject]
        NotificationCenter.default.post(name: Notification.Name(rawValue: kShowLoginViewControllerNotificationName), object: nil, userInfo: userInfo)
    }

    @objc func responseCodeForOAuthRefreshTokenRenewaIsUnauthorized(_ response: URLResponse) -> Bool {
        let HTTPResponse = response as! HTTPURLResponse
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

    @objc func responseCodeForOAuthIsUnauthorized(_ response: URLResponse) -> Bool {
        let HTTPResponse = response as! HTTPURLResponse
        switch HTTPResponse.statusCode {
        case 401:
            return true
        case 403:
            return true
        default:
            return false
        }
    }

    fileprivate class func incrementTaskCounter() {
        APIClient.sharedClient.willChangeValue(forKey: Constants.APIClient.taskCounter)
        APIClient.sharedClient.taskCounter += 1
        APIClient.sharedClient.didChangeValue(forKey: Constants.APIClient.taskCounter)
    }

    fileprivate class func decrementTaskCounter() {
        APIClient.sharedClient.willChangeValue(forKey: Constants.APIClient.taskCounter)
        APIClient.sharedClient.taskCounter -= 1
        APIClient.sharedClient.didChangeValue(forKey: Constants.APIClient.taskCounter)
    }
    
    fileprivate class func mimeType(fileType:String) -> String {
        let type  = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileType as CFString, nil)!.takeUnretainedValue()
        let findTag  = UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType)
        if findTag != nil {
            let mimeType = findTag!.takeRetainedValue()
            return mimeType as String
        }else {
            return ""
        }
    }
}
