//
//  APIClient+URLSessionTask.swift
//  Digipost
//
//  Created by Håkon Bogen on 14/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

import Alamofire

extension APIClient {

    private func dataTask(urlRequest: NSURLRequest, success: () -> Void , failure: (error: APIError) -> () ) -> NSURLSessionTask? {
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
            let serializedResponse : Dictionary<String,AnyObject>? = {
                if let data = data {
                    return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? Dictionary<String,AnyObject>
                }
                return nil
            }()
            if self.isUnauthorized(response as! NSHTTPURLResponse?) {
                self.removeAccessTokenUsedInLastRequest()
                failure(error: APIError.UnauthorizedOAuthTokenError())
            } else if let actualError = error as NSError!  {
                dispatch_async(dispatch_get_main_queue(), {
                    let error = APIError(error: actualError)
                    error.responseText = serializedResponse?.description
                    track(error:error)
                    failure(error: error)
                })
            } else if (response as! NSHTTPURLResponse).didFail()  {
                let err = APIError(urlResponse: (response as! NSHTTPURLResponse), jsonResponse: serializedResponse)
                failure(error:err)
            }else {
                dispatch_async(dispatch_get_main_queue(), {
                    success()
                })
            }
        })
        lastPerformedTask = task
        return task
    }

    func jsonDataTask(urlrequest: NSURLRequest, success: (Dictionary <String, AnyObject>) -> Void , failure: (error: APIError) -> () ) -> NSURLSessionTask? {
        let task = session.dataTaskWithRequest(urlrequest, completionHandler: { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                let htttpURL = response as? NSHTTPURLResponse
                println(htttpURL)
                let string = NSString(data: data, encoding: NSASCIIStringEncoding)
                if self.isUnauthorized(response as! NSHTTPURLResponse?) {
                    self.removeAccessTokenUsedInLastRequest()
                    let error = APIError.UnauthorizedOAuthTokenError()
                    error.responseText = string as! String
                    track(error: error)
                    failure(error: error)
                } else if let actualError = error as NSError! {
                    let error = APIError(error: actualError)
                    error.responseText = string as! String
                    track(error:error)
                    failure(error: error)
                } else {
                    var jsonError : NSError?
                    // TOODO make responseDictionary
                    if let actualData = data as NSData? {
                        if actualData.length == 0 {
                            failure(error:APIError(error:  NSError(domain: "", code: 232, userInfo: nil)))
                        }else if (response as! NSHTTPURLResponse).didFail()  {
                            let err = APIError(domain: Constants.Error.apiClientErrorDomain, code: htttpURL!.statusCode, userInfo: nil)
                            track(error: err)
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


    func urlSessionDownloadTask(method: httpMethod, encryptionModel: POSBaseEncryptedModel, acceptHeader: String, progress: NSProgress?, success: (url: NSURL) -> Void , failure: (error: APIError) -> ()) -> NSURLSessionTask? {
        let downloadURL = NSURL(string: encryptionModel.uri)
        var urlRequest = NSMutableURLRequest(URL: downloadURL!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = method.rawValue
        for (key, value) in self.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        urlRequest.allHTTPHeaderFields![Constants.HTTPHeaderKeys.accept] = acceptHeader
        Alamofire.Manager.sharedInstance.startRequestsImmediately = false
        var completedURL : NSURL?
        let downloadURI = encryptionModel.uri
        let request = Alamofire.download(urlRequest) { (tempURL, response) -> (NSURL) in
            let baseEncryptionModel : POSBaseEncryptedModel = {
                if let attachment = encryptionModel as? POSAttachment {
                    return POSAttachment.existingAttachmentWithUri(downloadURI, inManagedObjectContext: POSModelManager.sharedManager().managedObjectContext!) as POSBaseEncryptedModel
                } else {
                    return POSReceipt.existingReceiptWithUri(downloadURI, inManagedObjectContext: POSModelManager.sharedManager().managedObjectContext!) as POSBaseEncryptedModel
                }}()
            let filePath = baseEncryptionModel.decryptedFilePath()
            if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
            }
            let fileURL = NSURL(fileURLWithPath: filePath)!
            completedURL = fileURL
            return fileURL
            }.progress { (bytesRead, totalBytesRead, totalBytesExcpedtedToRead) -> Void in
                if let actualProgress = progress as NSProgress! {
                    actualProgress.completedUnitCount = totalBytesRead
                }
            }.response { (request, response, object, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if self.isUnauthorized(response as NSHTTPURLResponse?) {
                        let error = APIError.UnauthorizedOAuthTokenError()
                        track(error: error)
                        self.removeAccessTokenUsedInLastRequest()
                        failure(error: error)
                    } else if let actualError = error as NSError! {
                        track(error: APIError(error: actualError))
                        failure(error: APIError(error: actualError))
                    } else {
                        success(url: completedURL!)
                    }
                })
        }
        self.lastPerformedTask = request.task
        return request.task
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
    func urlSessionJSONTask(#url: String,  success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) -> NSURLSessionTask? {
        let fullURL = NSURL(string: url, relativeToURL: NSURL(string: __SERVER_URI__))
        var urlRequest = NSMutableURLRequest(URL: fullURL!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = httpMethod.get.rawValue
        for (key, value) in self.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let task = jsonDataTask(urlRequest, success: success, failure: failure)
        return task
    }

    func urlSessionJSONTask(method: httpMethod, url: String, parameters: [String : AnyObject], success: ([String : AnyObject]) -> Void , failure: (error: APIError) -> ()) -> NSURLSessionTask? {
        let fullURL = NSURL(string: url, relativeToURL: NSURL(string: __SERVER_URI__))
        var urlRequest = NSMutableURLRequest(URL: fullURL!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = method.rawValue
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        for (key, value) in self.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let task = jsonDataTask(urlRequest, success: success, failure: failure)
        return task
    }

    func urlSessionTask(method: httpMethod, url:String, success: () -> Void , failure: (error: APIError) -> ()) -> NSURLSessionTask? {
        let url = NSURL(string: url)
        var urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = method.rawValue
        for (key, value) in self.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        let task = dataTask(urlRequest, success: success, failure: failure)
        return task
    }

    func urlSessionTask(method: httpMethod, url:String, parameters: Dictionary<String,AnyObject>, success: () -> Void , failure: (error: APIError) -> ()) -> NSURLSessionTask? {
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

}
