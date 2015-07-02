//
//  APIClient+URLSessionTask.swift
//  Digipost
//
//  Created by Håkon Bogen on 14/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit


extension APIClient {

    private func dataTask(urlRequest: NSURLRequest, success: () -> Void , failure: (error: APIError) -> () ) -> NSURLSessionTask {
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
            let serializedResponse : Dictionary<String,AnyObject>? = {
                if let data = data {
                    return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? Dictionary<String,AnyObject>
                }
                return nil
            }()
            if let actualError = error as NSError!  {
                dispatch_async(dispatch_get_main_queue(), {
                    let error = APIError(error: actualError)
                    error.responseText = serializedResponse?.description
                    failure(error: error)
                })
            } else if NSHTTPURLResponse.isUnathorized(response as? NSHTTPURLResponse) {
                let error = APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.oAuthUnathorized.rawValue, userInfo: nil)
                failure(error:error)
            }  else if (response as! NSHTTPURLResponse).didFail()  {
                let err = APIError(urlResponse: (response as! NSHTTPURLResponse), jsonResponse: serializedResponse)
                dispatch_async(dispatch_get_main_queue(), {
                    failure(error:err)
                })
            }else {
                dispatch_async(dispatch_get_main_queue(), {
                    success()
                })
            }
        })
        lastPerformedTask = task
        return task
    }

    private func jsonDataTask(urlrequest: NSURLRequest, success: (Dictionary <String, AnyObject>) -> Void , failure: (error: APIError) -> () ) -> NSURLSessionTask {
        let task = session.dataTaskWithRequest(urlrequest, completionHandler: { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                let httpResponse = response as? NSHTTPURLResponse
                let string = NSString(data: data, encoding: NSASCIIStringEncoding)
                // if error happens in client, for example no internet, timeout ect.
                if let actualError = error as NSError! {
                    let error = APIError(error: actualError)
                    error.responseText = string as? String
                    failure(error: error)
                } else {
                    var jsonError : NSError?
                    let code : Int = {
                        if httpResponse == nil {
                            return Constants.Error.Code.UnknownError.rawValue
                        } else {
                            return httpResponse!.statusCode
                        }
                        }()
                    if NSHTTPURLResponse.isUnathorized(httpResponse) {
                        let error = APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.oAuthUnathorized.rawValue, userInfo: nil)
                        failure(error:error)
                    } else {
                        if let actualData = data as NSData? {
                            if actualData.length == 0 {
                                failure(error:APIError(error: NSError(domain: Constants.Error.apiClientErrorDomain, code: code, userInfo: nil)))
                            } else if (response as! NSHTTPURLResponse).didFail()  {
                                let err = APIError(domain: Constants.Error.apiClientErrorDomain, code: httpResponse!.statusCode, userInfo: nil)
                                failure(error:err)
                            } else {
                                let serializer = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as! Dictionary<String, AnyObject>
                                success(serializer)
                            }
                        }
                    }
                }
            })
        })
        lastPerformedTask = task
        return task
    }

    func urlSessionDownloadTask(method: httpMethod, encryptionModel: POSBaseEncryptedModel, acceptHeader: String, progress: NSProgress?, success: (url: NSURL) -> Void , failure: (error: APIError) -> ()) -> NSURLSessionTask {
        var completedURL : NSURL?
        let encryptedModelUri = encryptionModel.uri
        let urlRequest = fileTransferSessionManager.requestSerializer.requestWithMethod("GET", URLString: encryptionModel.uri, parameters: nil, error: nil)
        urlRequest.allHTTPHeaderFields![Constants.HTTPHeaderKeys.accept] = acceptHeader
        fileTransferSessionManager.setDownloadTaskDidWriteDataBlock { (session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExptextedToWrite) -> Void in
            progress?.completedUnitCount = totalBytesWritten
        }

        let isAttachment = encryptionModel is POSAttachment

        let task = fileTransferSessionManager.downloadTaskWithRequest(urlRequest, progress: nil, destination: { (url, response) -> NSURL! in
            let changedBaseEncryptionModel : POSBaseEncryptedModel? = {
                if isAttachment {
                    return POSAttachment.existingAttachmentWithUri(encryptedModelUri, inManagedObjectContext: POSModelManager.sharedManager().managedObjectContext)
                } else {
                    return POSReceipt.existingReceiptWithUri(encryptedModelUri, inManagedObjectContext: POSModelManager.sharedManager().managedObjectContext)
                }
            }()

            if let filePath = changedBaseEncryptionModel?.decryptedFilePath() {
                return NSURL.fileURLWithPath(filePath)
            } else {
                return nil
            }

            }, completionHandler: { (response, fileURL, error) -> Void in
                if let actualError = error {
                    if (error.code != NSURLErrorCancelled) {
                        if NSHTTPURLResponse.isUnathorized(response as? NSHTTPURLResponse) {
                            OAuthToken.removeAccessTokenForOAuthTokenWithScope(kOauth2ScopeFull)
                            Logger.dpostLogWarning("accesstoken was invalid, will try to fetch a new using refresh token", location: "downloading a file", UI: "User waiting for file to complete download", cause: "might be a problem with clock on users device, or token was revoked")
                            self.validateFullScope {
                                failure(error: APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.UnknownError.rawValue, userInfo: nil))
                            }
                        } else {
                            failure(error: APIError(error: error))
                        }
                    }
                } else if let actualFileUrl = fileURL {
                    success(url:actualFileUrl)
                }
                // we get here if the request was canceled, should do nothing.
        })
        return task
    }

    private func isUnauthorized(urlResponse: NSHTTPURLResponse?) -> Bool {
        if let actualResponse = urlResponse as NSHTTPURLResponse! {
            if (actualResponse.statusCode == 403 || actualResponse.statusCode == 401) {
                return true
            }
        }
        return false
    }

    /**
    GET a request to server that fetches json structures, like list of documents, list of folders.

    :param: url       url to fetch data from
    :param: success   block with json data that has to be inserted to database
    :param: failure   failure block with error that should be sent to present a UIAlertcontroller with API error

    :returns: a task to resume when the request should be started
    */
    func urlSessionJSONTask(#url: String,  success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) -> NSURLSessionTask {
        let fullURL = NSURL(string: url, relativeToURL: NSURL(string: __SERVER_URI__))
        var urlRequest = NSMutableURLRequest(URL: fullURL!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = httpMethod.get.rawValue
        for (key, value) in self.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let task = jsonDataTask(urlRequest, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue {
                OAuthToken.removeAccessTokenForOAuthTokenWithScope(kOauth2ScopeFull)
                Logger.dpostLogWarning("accesstoken was invalid, will try to fetch a new using refresh token", location: "somewhere a jsonDataTask is performed, ex: downloading list of documents, list of folders", UI: "User waiting for the request to finish", cause: "might be a problem with clock on users device, or token was revoked")
                self.validateFullScope {
                    failure(error: APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.UnknownError.rawValue, userInfo: nil))
                }
            } else {
                failure(error: error)
            }
        }

        return task
    }

    func urlSessionTask(method: httpMethod, url:String, parameters: Dictionary<String,AnyObject>? = nil, success: () -> Void , failure: (error: APIError) -> ()) -> NSURLSessionTask {
        let url = NSURL(string: url)
        var urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = method.rawValue
        if let actualParameters = parameters {
            urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(actualParameters, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        }
        for (key, value) in self.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let task = dataTask(urlRequest, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue {
                OAuthToken.removeAccessTokenForOAuthTokenWithScope(kOauth2ScopeFull)
                Logger.dpostLogWarning("accesstoken was invalid, will try to fetch a new using refresh token", location: "doing a data task, ex renaming file, moving a document or folder", UI: "User is waiting for a data task to finish", cause: "might be a problem with clock on users device, or token was revoked")
                self.validateFullScope {
                    failure(error: APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.UnknownError.rawValue, userInfo: nil))
                }
            } else {
                failure(error: error)
            }
        }

        return task
    }

    func urlSessionTaskWithNoAuthorizationHeader(method: httpMethod, url:String, parameters: Dictionary<String,AnyObject>, success: () -> Void , failure: (error: APIError) -> ()) -> NSURLSessionTask {
        let url = NSURL(string: url)
        var urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = method.rawValue
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        urlRequest.setValue(nil, forHTTPHeaderField: "Authorization")
        let contentType = "application/vnd.digipost-\(__API_VERSION__)+json"
        urlRequest.setValue(contentType, forHTTPHeaderField: Constants.HTTPHeaderKeys.contentType)

        let task = dataTask(urlRequest, success: success, failure: failure)
        return task
    }
}
