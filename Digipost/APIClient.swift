//
//  APIClient.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation
import MobileCoreServices

class APIClient : NSObject , NSURLSessionTaskDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate,NSURLSessionDownloadDelegate {
    
    enum httpMethod : String {
        case post = "POST"
        case delete = "DELETE"
        case update = "UPDATE"
        case put = "PUT"
        case get = "GET"
    }
    
   
    var queue = NSOperationQueue()
    
    lazy var session: NSURLSession =  {
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfiguration.requestCachePolicy = .ReloadIgnoringLocalCacheData
        let contentType = "application/vnd.digipost-\(__API_VERSION__)+json"
        sessionConfiguration.HTTPAdditionalHeaders = [Constants.HTTPHeaderKeys.accept: contentType, "Content-type" : contentType]
        let theSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        println(" The delegate: \(theSession.delegate)")
        println(theSession.delegateQueue)
        dispatch(after:3) {
            
        println(" The delegate: \(theSession.delegate)")
        println(theSession.delegateQueue)
        }
        return theSession
    }()
    
    var taskCounter              = 0
    
    class var sharedClient: APIClient {
        struct Singleton {
            static let sharedClient = APIClient()
        }
        
        return Singleton.sharedClient
    }
    
    override init() {
        super.init()

        RACObserve(self, Constants.APIClient.taskCounter).subscribeNext({
            (anyObject) in
            if let taskCounter = anyObject as? Int {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = (taskCounter > 0)
            }
        })
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
    }
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {

    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        println(session,task)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
    }
    
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        println(session,task,bytesSent)

    }
    
    func updateAuthorizationHeader(scope: String) {
        let athing = self.session.delegate
        let oAuthToken = OAuthToken.oAuthTokenWithScope(scope)
        self.session.configuration.HTTPAdditionalHeaders!["Authorization"] = "Bearer \(oAuthToken!.accessToken!)"
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
            task.resume()
        }
    }
    func changeName(folder: POSFolder, newName name: String, newIconName iconName: String, success: () -> Void , failure: (error: NSError) -> ()) {
        let parameters = [ "id" : folder.folderId, "name" : name, "icon" : iconName]
        let task = urlSessionTask(httpMethod.put, url: folder.changeFolderUri, parameters: parameters, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func changeName(document: POSDocument, newName name: String, success: () -> Void , failure: (error: NSError) -> ()) {
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
    
    func createFolder(name: String, iconName: String, mailBox: POSMailbox, success: () -> Void , failure: (error: NSError) -> ()) {
        let parameters = ["name" : name, "icon" : iconName]
        let task = urlSessionTask(httpMethod.post, url: mailBox.createFolderUri, parameters: parameters, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func deleteDocument(uri: String, success: () -> Void , failure: (error: NSError) -> ()) {
        let task = urlSessionTask(httpMethod.delete, url: uri, success: success, failure: failure)
        // only do task if validated
        validateTokensThenPerformTask(task!)
    }
    
    func moveDocument(document: POSDocument, toFolder folder: POSFolder, success: () -> Void , failure: (error: NSError) -> ()) {
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
    
    func updateRootResource(#success: () -> Void , failure: (error: NSError) -> ()) {
        let task = urlSessionTask(httpMethod.get, url: __ROOT_RESOURCE_URI__, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func updateBankAccount(#uri : String, success: () -> Void , failure: (error: NSError) -> ()) {
        let task = urlSessionTask(httpMethod.get, url: uri, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func sendInvoideToBank(invoice: POSInvoice , success: () -> Void , failure: (error: NSError) -> ()) {
        let task = urlSessionTask(httpMethod.post, url: invoice.sendToBankUri, success: success, failure: failure);
        validateTokensThenPerformTask(task!)
    }
    
    func updateDocumentsInFolder(#name: String, mailboxDigipostAdress: String, folderUri: String, success: () -> Void, failure: (error: NSError) -> ()) {
        let task = urlSessionTask(httpMethod.get, url: folderUri, success: success, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    func downloadBaseEncryptionModel(baseEncryptionModel: POSBaseEncryptedModel, withProgress progress: NSProgress, success: () -> Void , failure: (error: NSError) -> ()) {
        
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
            failure(error: error)
            return
        }
        
        //        let task = urlSessionTask(httpMethod.get, url: baseEncryptionModel.uri, success: success, failure: failure)
//        let signal = rac_signalForSelector(Selector("URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:"), fromProtocol:NSURLSessionDownloadDelegate.self ).subscribeNext { (ractuple) -> Void in
//            println(ractuple)
//            println("Heloo world")
//        }
//        
        let mimeType = APIClient.mimeType(fileType: baseEncryptionModel.fileType)
        let baseEncryptedModelUri = baseEncryptionModel.uri
        
        let task = urlSessionDownloadTask(httpMethod.get, url: baseEncryptionModel.uri, acceptHeader: mimeType, success: { (url) -> Void in
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
            
            }, failure: failure)
        validateTokensThenPerformTask(task!)
    }
    
    //    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    
    //    }
    //    - (void)downloadBaseEncryptionModel:(POSBaseEncryptedModel *)baseEncryptionModel withProgress:(NSProgress *)progress success:(void (^)(void))success failure:(void (^)(NSError *))failure
    //    {
    //    self.state = SHCAPIManagerStateDownloadingBaseEncryptionModel;
    //
    //    NSString *highestScope;
    //    __block BOOL didChoseAHigherScope = NO;
    //    if ([baseEncryptionModel isKindOfClass:[POSAttachment class]]) {
    //    POSAttachment *attachment = (id)baseEncryptionModel;
    //    NSString *scope = [OAuthToken oAuthScopeForAuthenticationLevel:attachment.authenticationLevel];
    //    if ([scope isEqualToString:kOauth2ScopeFull]) {
    //    highestScope = kOauth2ScopeFull;
    //    } else {
    //    highestScope = [OAuthToken highestScopeInStorageForScope:scope];
    //    if ([highestScope isEqualToString:scope] == NO) {
    //    didChoseAHigherScope = YES;
    //    }
    //    }
    //    } else {
    //    highestScope = kOauth2ScopeFull;
    //    }
    //
    //    [self validateAndDownloadBaseEncryptionModel:baseEncryptionModel withProgress:progress scope:highestScope didChooseHigherScope:didChoseAHigherScope success:success failure:failure];
    //    }
    //
    //    - (void)validateAndDownloadBaseEncryptionModel:(POSBaseEncryptedModel *)baseEncryptionModel withProgress:(NSProgress *)progress scope:(NSString *)scope didChooseHigherScope:(BOOL)didChooseHigherScope success:(void (^)(void))success failure:(void (^)(NSError *))failure
    //    {
    //    OAuthToken *oauthToken = [OAuthToken oAuthTokenWithScope:scope];
    //
    //    if (oauthToken == nil && didChooseHigherScope) {
    //    POSAttachment *attachment = (id)baseEncryptionModel;
    //    NSString *scope = [OAuthToken oAuthScopeForAuthenticationLevel:attachment.authenticationLevel];
    //    oauthToken = [OAuthToken oAuthTokenWithScope:scope];
    //    }
    //    if (oauthToken == nil) {
    //    NSError *error = [NSError errorWithDomain:kAPIManagerErrorDomain
    //    code:SHCAPIManagerErrorCodeNeedHigherAuthenticationLevel
    //    userInfo:nil];
    //    self.lastError = error;
    //    self.state = SHCAPIManagerStateDownloadingBaseEncryptionModelFailed;
    //    if (failure) {
    //    failure(error);
    //    }
    //    return;
    //    }
    //    NSString *baseEncryptionModelUri = baseEncryptionModel.uri;
    //    [self validateTokensForScope:scope success:^{
    //
    //    NSMutableURLRequest *urlRequest = [self.fileTransferSessionManager.requestSerializer requestWithMethod:@"GET" URLString:baseEncryptionModelUri parameters:nil error:nil];
    //
    //    // Let's set the correct mime type for this file download.
    //    [urlRequest setValue:[self mimeTypeForFileType:baseEncryptionModel.fileType] forHTTPHeaderField:@"Accept"];
    //    [self.fileTransferSessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
    //    progress.completedUnitCount = totalBytesWritten;
    //    }];
    //
    //    BOOL baseEncryptionModelIsAttachment = [baseEncryptionModel isKindOfClass:[POSAttachment class]];
    //
    //    NSURLSessionDownloadTask *task = [self.fileTransferSessionManager downloadTaskWithRequest:urlRequest progress:nil destination:^NSURL * (NSURL * targetPath, NSURLResponse * response) {
    //
    //    // Because our baseEncryptionModel may have been changed while we downloaded the file, let's fetch it again
    //    POSBaseEncryptedModel *changedBaseEncryptionModel = nil;
    //    if (baseEncryptionModelIsAttachment) {
    //    changedBaseEncryptionModel = [POSAttachment existingAttachmentWithUri:baseEncryptionModelUri inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    //    } else {
    //    changedBaseEncryptionModel = [POSReceipt existingReceiptWithUri:baseEncryptionModelUri inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    //    }
    //
    //    NSString *filePath = [changedBaseEncryptionModel decryptedFilePath];
    //
    //    if (!filePath) {
    //    return nil;
    //    }
    //
    //    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    //    return fileUrl;
    //    }
    //    completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
    //
    //    BOOL downloadFailure = NO;
    //    NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
    //    if ([HTTPURLResponse isKindOfClass:[NSHTTPURLResponse class]]) {
    //    if ([HTTPURLResponse statusCode] != 200) {
    //    downloadFailure = YES;
    //    }
    //    }
    //    if (error || downloadFailure) {
    //    if (didChooseHigherScope){
    //    POSAttachment *attachment = (id)baseEncryptionModel;
    //    NSString *originalScope = [OAuthToken oAuthScopeForAuthenticationLevel:attachment.authenticationLevel];
    //    [self validateAndDownloadBaseEncryptionModel:baseEncryptionModel withProgress:progress scope:originalScope didChooseHigherScope:NO success:success failure:failure];
    //    return;
    //    }
    //
    //    // If we're getting a 401 from the server, the error object will be nil.
    //    // Let's set it to something more usable that the caller can interpret.
    //    if (!error) {
    //    error = [NSError errorWithDomain:kAPIManagerErrorDomain
    //    code:SHCAPIManagerErrorCodeUnauthorized
    //    userInfo:nil];
    //    }
    //
    //    self.lastURLResponse = response;
    //    self.lastFailureBlock = failure;
    //    self.lastError = error;
    //    self.state = SHCAPIManagerStateDownloadingBaseEncryptionModelFailed;
    //    }else {
    //    self.lastURLResponse = response;
    //    self.lastSuccessBlock = success;
    //    self.state = SHCAPIManagerStateDownloadingBaseEncryptionModelFinished;
    //    }
    //    }];
    //    [task resume];
    //    }
    //    failure:^(NSError *error) {
    //    if (error.code == 2) {
    //    if (didChooseHigherScope ) {
    //    [OAuthToken removeAcessTokenForOAuthTokenWithScope:scope];
    //    }
    //    }
    //    self.downloadingBaseEncryptionModel = NO;
    //    if (failure) {
    //    failure(error);
    //    }
    //    }];
    //    }
    //
    //
    
    private func validateOAuthToken(scope: String, success: () -> Void)  {
        let oAuthToken = OAuthToken.oAuthTokenWithScope(scope)
        if (oAuthToken?.accessToken != nil) {
            success()
        }
        
        if (oAuthToken?.refreshToken != nil) {
            POSOAuthManager.sharedManager().refreshAccessTokenWithRefreshToken(oAuthToken?.refreshToken, scope: scope, success: {
                success()
                }, failure: { (error) -> Void in
                    // TODO handle failure
            })
        }else if (oAuthToken == nil && scope == kOauth2ScopeFull) {
            
        } else {
            
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
