//
//  APIClient+URLSessionTask.swift
//  Digipost
//
//  Created by Håkon Bogen on 14/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit


extension APIClient {
    
    private func dataTask(urlRequest: NSURLRequest, success: () -> Void , failure: (error: NSError) -> () ) -> NSURLSessionTask? {
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data,response, error) in
            if let actualError = error {
                failure(error: actualError)
            } else {
                let urlResponse = response as NSHTTPURLResponse
                if (urlResponse.statusCode == 400 ) {
                    failure(error:NSError(domain: "failed", code: 400, userInfo: nil))
                } else {
                    println(response)
                    success()
                }
            }
        })
        return task
    }
    
    func downloadTask(urlrequest: NSURLRequest, success: (url: NSURL) -> Void , failure: (error: NSError) -> () ) -> NSURLSessionTask? {
        let task = session.downloadTaskWithRequest(urlrequest, completionHandler: { (url, response, error) -> Void in
            println(url,response,error)
            if let actualError = error {
                failure(error: actualError)
            } else {
                let urlResponse = response as NSHTTPURLResponse
                if (urlResponse.statusCode == 400 ) {
                    failure(error:NSError(domain: "failed", code: 400, userInfo: nil))
                } else {
                    println(response)
                    success(url: url)
                }
            }
        })
        return task
    }
    
    func urlSessionDownloadTask(method: httpMethod, url: String, acceptHeader: String , success: (url: NSURL) -> Void , failure: (error: NSError) -> ()) -> NSURLSessionTask? {
        let url = NSURL(string: url)
        var urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = method.rawValue
        urlRequest.allHTTPHeaderFields![Constants.HTTPHeaderKeys.accept] = acceptHeader
        let task = downloadTask(urlRequest, success: success, failure: failure)
        return task
    }
    
    func urlSessionTask(method: httpMethod, url:String, success: () -> Void , failure: (error: NSError) -> ()) -> NSURLSessionTask? {
        let url = NSURL(string: url)
        var urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = method.rawValue
        let task = dataTask(urlRequest, success: success, failure: failure)
        return task
    }
    
    func urlSessionTask(method: httpMethod, url:String, parameters: Dictionary<String,AnyObject>, success: () -> Void , failure: (error: NSError) -> ()) -> NSURLSessionTask? {
        let url = NSURL(string: url)
        var urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.HTTPMethod = method.rawValue
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        let task = dataTask(urlRequest, success: success, failure: failure)
        return task
    }
       
 
}
