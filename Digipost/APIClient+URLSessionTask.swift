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
            } else if (response as! NSHTTPURLResponse).didFail()  {
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

    func jsonDataTask(urlrequest: NSURLRequest, success: (Dictionary <String, AnyObject>) -> Void , failure: (error: APIError) -> () ) -> NSURLSessionTask {
        let task = session.dataTaskWithRequest(urlrequest, completionHandler: { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                let htttpURL = response as? NSHTTPURLResponse
                let string = NSString(data: data, encoding: NSASCIIStringEncoding)
                 if let actualError = error as NSError! {
                    let error = APIError(error: actualError)
                    error.responseText = string as String?
                    failure(error: error)
                } else {
                    var jsonError : NSError?
                    if let actualData = data as NSData? {
                        if actualData.length == 0 {
                            failure(error:APIError(error: NSError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.UnknownError.rawValue, userInfo: nil)))
                        } else if (response as! NSHTTPURLResponse).didFail()  {
                            let err = APIError(domain: Constants.Error.apiClientErrorDomain, code: htttpURL!.statusCode, userInfo: nil)
                            failure(error:err)
                        } else {
                            let serializer = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as! Dictionary<String, AnyObject>
                            success(serializer)
                        }
                    } else {
                        success(Dictionary<String, AnyObject>())
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

        fileTransferSessionManager.setDownloadTaskDidWriteDataBlock { (session, NSURLSessionDownloadTask, bytesWritten, totalBytesWritten, totalBytesExptextedToWrite) -> Void in
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
                    failure(error: APIError(error: error))
                } else if let actualFileUrl = fileURL {
                        success(url:actualFileUrl)
                } else {
                    // TODO dLog
                }
        })
        return task
    }

    func isUnauthorized(urlResponse: NSHTTPURLResponse?) -> Bool {
        if let actualResponse = urlResponse as NSHTTPURLResponse! {
            if (actualResponse.statusCode == 403 || actualResponse.statusCode == 401) {
                return true
            }
        }
        return false
    }

    // Only GET allowed
    func urlSessionJSONTask(#url: String,  success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) -> NSURLSessionTask {
        let fullURL = NSURL(string: url, relativeToURL: NSURL(string: __SERVER_URI__))
        var urlRequest = NSMutableURLRequest(URL: fullURL!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = httpMethod.get.rawValue
        for (key, value) in self.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let task = jsonDataTask(urlRequest, success: success, failure: failure)
        return task
    }

    func urlSessionTask(method: httpMethod, url:String, success: () -> Void , failure: (error: APIError) -> ()) -> NSURLSessionTask {
        let url = NSURL(string: url)
        var urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = method.rawValue
        for (key, value) in self.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        let task = dataTask(urlRequest, success: success, failure: failure)
        return task
    }

    func urlSessionTask(method: httpMethod, url:String, parameters: Dictionary<String,AnyObject>, success: () -> Void , failure: (error: APIError) -> ()) -> NSURLSessionTask {
        let url = NSURL(string: url)
        var urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = method.rawValue
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted, error: nil)

        for (key, value) in self.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let task = dataTask(urlRequest, success: success, failure: failure)
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
