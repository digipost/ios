//
//  APIClient.swift
//  Digipost
//
//  Created by Håkon Bogen on 06/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

class APIClient : NSObject {
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
        sessionConfiguration.HTTPAdditionalHeaders = ["Accept": "text/html", "apiCode" : "jewncewiz"]
        
        self.queue = NSOperationQueue()
        self.session = NSURLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: self.queue)
        RACObserve(self, Constants.APIClient.taskCounter).subscribeNext({
            (anyObject) in
            if let taskCounter = anyObject as? Int {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = (taskCounter > 0)
            }
        })
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
    
    private class func signal(endPoint: String, arguments: Dictionary<String,AnyObject>?) -> RACSignal? {
        let baseURL = NSURL(string: Constants.APIClient.baseURL)!
        
        var url: NSURL {
            if let argumentString = APIClient.stringFromArguments(arguments) {
                let endPointWithArguments = "\(endPoint)?\(argumentString)"
                return NSURL(string: endPointWithArguments,relativeToURL:baseURL)!
            }else {
                return  NSURL(string: endPoint, relativeToURL: baseURL)!
            }
        }
        
        return RACSignal.createSignal {
            (subscriber) -> RACDisposable! in
            println("url: \(url)")
            let task = APIClient.sharedClient.session?.dataTaskWithURL(url, completionHandler: {
                (data, response, error) in
                
                println("response : \(response)")
                if (error != nil) {
                    subscriber.sendError(error)
                } else {
                    var jsonError: NSError?
                    let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError)
                    println(json)
                    
                    if (jsonError != nil) {
                        subscriber.sendError(jsonError)
                    } else {
                        var date: NSDate?
                        let apiResponse = APIResponse(json: json, date: date)
                        subscriber.sendNext(apiResponse)
                        subscriber.sendCompleted()
                    }
                }
            })
            
            task?.resume()
            APIClient.incrementTaskCounter()
            
            return RACDisposable(block: {
                task?.cancel()
                APIClient.decrementTaskCounter()
            })
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
}
