//
//  APIClient.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

class APIClient : NSObject {
    
    enum httpMethod : String {
        case post = "POST"
        case delete = "DELETE"
        case update = "UPDATE"
        case put = "PUT"
        case get = "GET"
    }
    
    var session:                 NSURLSession?
    var queue:                   NSOperationQueue?
    var taskCounter              = 0
    
    class var sharedClient: APIClient {
        struct Singleton {
            static let sharedClient = APIClient()
        }
        
        return Singleton.sharedClient
    }
    
    override init() {
        super.init()
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfiguration.requestCachePolicy = .ReloadIgnoringLocalCacheData
        let contentType = "application/vnd.digipost-\(__API_VERSION__)+json"
        sessionConfiguration.HTTPAdditionalHeaders = ["Accept": contentType, "Content-type" : contentType]
        self.queue = NSOperationQueue()
        self.session = NSURLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: self.queue)
        RACObserve(self, Constants.APIClient.taskCounter).subscribeNext({
            (anyObject) in
            if let taskCounter = anyObject as? Int {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = (taskCounter > 0)
            }
        })
    }
    
    func updateAuthorizationHeader(scope: String) {
        let oAuthToken = OAuthToken.oAuthTokenWithScope(scope)
        self.session?.configuration.HTTPAdditionalHeaders!["Authorization"] = "Bearer \(oAuthToken!.accessToken!)"
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
    
    /*

    */
    // http DELETE
    
    
    //    func DELETE() -> void {
    //
    //    }
    
    //    func
    
    //    - (void)validateTokensForScope:(NSString *)scope success:(void (^)(void))success failure:(void (^)(NSError *error))failure
    //    {
    //    self.state = SHCAPIManagerStateValidatingAccessToken;
    //
    //    POSOAuthManager *OAuthManager = [POSOAuthManager sharedManager];
    //    OAuthToken *oAuthToken = [OAuthToken oAuthTokenWithScope:scope];
    //    // If the OAuth manager already has its access token, we'll go ahead and try an API request using this.
    //    self.lastOAuth2Scope = scope;
    //    if (oAuthToken.accessToken) {
    //    self.lastSuccessBlock = success;
    //    self.state = SHCAPIManagerStateValidatingAccessTokenFinished;
    //    return;
    //    }
    //
    //    // If the OAuth manager has its refresh token, ask it to update its access token first,
    //    // and then go ahead and try an API request.
    //
    //    if (oAuthToken.refreshToken) {
    //    self.state = SHCAPIManagerStateRefreshingAccessToken;
    //    NSAssert(self.lastOAuth2Scope != nil, @"no scope set!");
    //    [OAuthManager refreshAccessTokenWithRefreshToken:oAuthToken.refreshToken scope:self.lastOAuth2Scope
    //    success:^{
    //    self.lastSuccessBlock = success;
    //    self.lastOAuth2Scope = scope;
    //    self.state = SHCAPIManagerStateRefreshingAccessTokenFinished;
    //    }
    //    failure:^(NSError *error) {
    //    NSLog(@"Error %@",error);
    //    self.lastFailureBlock = failure;
    //    self.lastError = error;
    //    self.lastOAuth2Scope = scope;
    //    self.state = SHCAPIManagerStateRefreshingAccessTokenFailed;
    //    }];
    //
    //    } else if (oAuthToken == nil && scope == kOauth2ScopeFull) {
    //    NSLog(@"Error  No login token");
    //    // if no oauthtoken  and the scope is full, means user has not yet logged in, ask user to log in
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewControllerNotificationName object:nil];
    //    self.lastFailureBlock = failure;
    //    self.lastOAuth2Scope = scope;
    //    self.state = SHCAPIManagerStateRefreshingAccessTokenFailed;
    //    } else {
    //    NSLog(@"Error unknown error, could not refresh refresh token");
    //    // refresh
    //    self.lastFailureBlock = failure;
    //    self.lastOAuth2Scope = scope;
    //    self.state = SHCAPIManagerStateRefreshingAccessTokenFailed;
    //    }
    
    private func validateTokensThenPerformTask(task: NSURLSessionTask) {
        validateOAuthToken(kOauth2ScopeFull) {
            println("performing url session task: \(task.originalRequest)")
            task.resume()
        }
    }
    
    func changeName(folder: POSFolder, newName name: String, newIconName iconName: String, completed: () -> Void , failed: (error: NSError) -> ()) {
        let parameters = [ "id" : folder.folderId, "name" : name, "icon" : iconName]
        let task = urlSessionTask(httpMethod.put, url: folder.changeFolderUri, parameters: parameters, completed: completed, failed: failed)
        validateTokensThenPerformTask(task!)
    }
    
    func changeName(document: POSDocument, newName name: String, completed: () -> Void , failed: (error: NSError) -> ()) {
        let documentFolder = document.folder
        let parameters : Dictionary<String,String> = {
            if documentFolder.name == "Inbox" {
                return ["location":"INBOX", "subject" : name]
            } else {
                return ["location":"FOLDER", "subject" : name, "folderId" : documentFolder.folderId.stringValue]
            }
            }()
        let task = urlSessionTask(httpMethod.post, url: document.updateUri, parameters: parameters, completed: completed, failed: failed)
        validateTokensThenPerformTask(task!)
    }
    
    func createFolder(name: String, iconName: String, mailBox: POSMailbox, completed: () -> Void , failed: (error: NSError) -> ()) {
        let parameters = ["name" : name, "icon" : iconName]
        let task = urlSessionTask(httpMethod.post, url: mailBox.createFolderUri, parameters: parameters, completed: completed, failed: failed)
        validateTokensThenPerformTask(task!)
    }
    
    func deleteDocument(uri: String, completed: () -> Void , failed: (error: NSError) -> ()) {
        let task = urlSessionTask(httpMethod.delete, url: uri, completed: completed, failed: failed)
        // only do task if validated
        validateTokensThenPerformTask(task!)
    }
    
    func moveDocument(document: POSDocument, toFolder folder: POSFolder, completed: () -> Void , failed: (error: NSError) -> ()) {
        let firstAttachment = document.attachments.firstObject as POSAttachment
        let parameters : Dictionary<String,String> = {
            if folder.name == "Inbox" {
                return ["location":"INBOX", "subject" : firstAttachment.subject]
            } else {
                return ["location":"FOLDER", "subject" : firstAttachment.subject, "folderId" : folder.folderId.stringValue]
            }
            }()
        let task = urlSessionTask(httpMethod.post, url: document.updateUri, parameters:parameters, completed: completed, failed: failed)
        validateTokensThenPerformTask(task!)
    }
    
    func updateRootResource(#completed: () -> Void , failed: (error: NSError) -> ()) {
        let task = urlSessionTask(httpMethod.get, url: __ROOT_RESOURCE_URI__, completed: completed, failed: failed)
        validateTokensThenPerformTask(task!)
    }
    
    func updateBankAccount(#uri : String, completed: () -> Void , failed: (error: NSError) -> ()) {
        let task = urlSessionTask(httpMethod.get, url: uri, completed: completed, failed: failed)
        validateTokensThenPerformTask(task!)
    }
    
//
//    - (void)updateBankAccountWithUri:(NSString *)uri success:(void (^)(void))success failure:(void (^)(NSError *))failure
//{
//    self.state = SHCAPIManagerStateUpdatingBankAccount;
//
//    [self validateTokensForScope:kOauth2ScopeFull success:^{
//        self.lastBankAccountUri = uri;
//        [self.sessionManager GET:uri
//                      parameters:nil
//                         success:^(NSURLSessionDataTask *task, id responseObject) {
//                             self.lastSuccessBlock = success;
//                             self.lastURLResponse = task.response;
//                             self.lastResponseObject = responseObject;
//                             self.state = SHCAPIManagerStateUpdatingBankAccountFinished;
//                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                             self.lastFailureBlock = failure;
//                             self.lastURLResponse = task.response;
//                             self.lastError = error;
//                             self.state = SHCAPIManagerStateUpdatingBankAccountFailed;
//                         }];
//    } failure:^(NSError *error) {
//        self.updatingBankAccount = NO;
//        if (failure) {
//            failure(error);
//        }
//    }];
//}
    
//    - (void)createFolderWithName:(NSString *)name iconName:(NSString *)iconName forMailBox:(POSMailbox *)mailbox success:(void (^)(void))success failure:(void (^)(NSError *))failure
//    {
//
//    NSDictionary *parameters = @{ @"name" : name,
//    @"icon" : iconName };
//    self.lastOAuth2Scope = kOauth2ScopeFull;
//    [self validateTokensForScope:self.lastOAuth2Scope success:^{
//    self.state = SHCAPIManagerStateCreatingFolder;
//    [self jsonRequestWithMethod:@"POST" oAuth2Scope:self.lastOAuth2Scope parameters:parameters
//    url:mailbox.createFolderUri
//    completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//    if (error) {
//    NSLog(@"%@",error);
//    self.lastFailureBlock = failure;
//    self.lastError = error;
//    self.lastURLResponse = response;
//    self.state = SHCAPIManagerStateCreatingFolderFailed;
//    } else {
//    self.lastSuccessBlock = success;
//    self.lastResponseObject = responseObject;
//    self.state = SHCAPIManagerStateCreatingFolderFinished;
//    }
//    }];
//    } failure:^(NSError *error) {
//    if (failure) {
//    failure(error);
//    }
//    }];
//    }
//
//
//    class func signal(endPoint: String, arguments: Dictionary<String,AnyObject>?, method: String) -> RACSignal? {
//        abort()
//        let baseURL = NSURL(string: Constants.APIClient.baseURL)!
//
//        var url: NSURL {
//            if let argumentString = APIClient.stringFromArguments(arguments) {
//                let endPointWithArguments = "\(endPoint)?\(argumentString)"
//                return NSURL(string: endPointWithArguments,relativeToURL:baseURL)!
//            } else {
//                return  NSURL(string: endPoint, relativeToURL: baseURL)!
//            }
//        }
//        
//        var urlRequest = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 50)
//        urlRequest.HTTPMethod = method
//        
//        return RACSignal.createSignal {
//            (subscriber) -> RACDisposable! in
//            println("url: \(url)")
//            
//            let task = APIClient.sharedClient.session?.dataTaskWithRequest(urlRequest, completionHandler: {
//                (data, response, error) in
//                
//                println("response : \(response)")
//                if (error != nil) {
//                    println("error was not nil : \(error)")
//                    subscriber.sendError(error)
//                } else {
//                    var jsonError: NSError?
//                    let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &jsonError)
//                    println(json)
//                    
//                    if (jsonError != nil) {
//                        println("json error not nil")
//                        println("json error \(json)")
//                        subscriber.sendError(jsonError)
//                    } else {
//                        var date: NSDate?
//                        let apiResponse = APIResponse(json: json, date: date)
//                        subscriber.sendNext(apiResponse)
//                        subscriber.sendCompleted()
//                    }
//                }
//            })
//            
//            task?.resume()
//            APIClient.incrementTaskCounter()
//            
//            return RACDisposable(block: {
//                task?.cancel()
//                APIClient.decrementTaskCounter()
//            })
//        }
//    }
    
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
    
    private func urlSessionTask(method: httpMethod, url:String, completed: () -> Void , failed: (error: NSError) -> ()) -> NSURLSessionTask? {
        let url = NSURL(string: url)
        var urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = method.rawValue
        let task = session?.dataTaskWithRequest(urlRequest, completionHandler: { (data,response, error) in
            if let actualError = error {
                failed(error: actualError)
            } else {
                let urlResponse = response as NSHTTPURLResponse
                if (urlResponse.statusCode == 400 ) {
                    failed(error:NSError(domain: "failed", code: 400, userInfo: nil))
                } else {
                    println(response)
                    completed()
                }
            }
        })
        return task
    }
    
    private func urlSessionTask(method: httpMethod, url:String, parameters: Dictionary<String,AnyObject>, completed: () -> Void , failed: (error: NSError) -> ()) -> NSURLSessionTask? {
        let url = NSURL(string: url)
        var urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = method.rawValue
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        let task = session?.dataTaskWithRequest(urlRequest, completionHandler: { (data,response, error) in
            if let actualError = error {
                failed(error: actualError)
            } else {
                let urlResponse = response as NSHTTPURLResponse
                if (urlResponse.statusCode == 400 ) {
                    failed(error:NSError(domain: "failed", code: 400, userInfo: nil))
                } else {
                    println(response)
                    completed()
                }
            }
        })
        return task
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
}
