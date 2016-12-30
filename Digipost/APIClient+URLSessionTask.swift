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

import UIKit


extension APIClient {

    fileprivate func dataTask(_ urlRequest: URLRequest, success: @escaping () -> Void , failure: @escaping (_ error: APIError) -> () ) -> URLSessionTask {
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            let serializedResponse : Dictionary<String,AnyObject>? = {
                if let data = data {
                    do {
                        return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String,AnyObject>
                        
                    } catch {
                        return nil
                    }
                }
                return nil
            }()
            if let actualError = error as NSError!  {
                DispatchQueue.main.async(execute: {
                    let error = APIError(error: actualError)
                    error.responseText = serializedResponse?.description
                    failure(error: error)
                })
            } else if HTTPURLResponse.isUnathorized(response as? HTTPURLResponse) {
                let error = APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.oAuthUnathorized.rawValue, userInfo: nil)
                failure(error:error)
            }  else if (response as! HTTPURLResponse).didFail()  {
                let err = APIError(urlResponse: (response as! HTTPURLResponse), jsonResponse: serializedResponse)
                DispatchQueue.main.async(execute: {
                    failure(error:err)
                })
            }else {
                DispatchQueue.main.async(execute: {
                    success()
                })
            }
        })
        lastPerformedTask = task
        return task
    }

    fileprivate func jsonDataTask(_ urlrequest: URLRequest, success: @escaping (Dictionary <String, AnyObject>) -> Void , failure: @escaping (_ error: APIError) -> () ) -> URLSessionTask {
        let task = session.dataTask(with: urlrequest, completionHandler: { (data, response, error) -> Void in
            DispatchQueue.main.async(execute: {
                let httpResponse = response as? HTTPURLResponse
                
                
                // if error happens in client, for example no internet, timeout ect.
                if let actualError = error as NSError!, let actualData = data {
                    let error = APIError(error: actualError)
                    let string = NSString(data: actualData, encoding: String.Encoding.ascii)
                    error.responseText = string as? String
                    failure(error: error)
                } else {
                    let code : Int = {
                        if httpResponse == nil {
                            return Constants.Error.Code.unknownError.rawValue
                        } else {
                            return httpResponse!.statusCode
                        }
                        }()
                    if HTTPURLResponse.isUnathorized(httpResponse) {
                        let error = APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.oAuthUnathorized.rawValue, userInfo: nil)
                        failure(error:error)
                    } else {
                        if let actualData = data as Data? {
                            if actualData.count == 0 {
                                failure(APIError(error: NSError(domain: Constants.Error.apiClientErrorDomain, code: code, userInfo: nil)))
                            } else if (response as! HTTPURLResponse).didFail()  {
                                let err = APIError(domain: Constants.Error.apiClientErrorDomain, code: httpResponse!.statusCode, userInfo: nil)
                                failure(err)
                            } else {
                                let serializer = try! JSONSerialization.jsonObject(with: actualData, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String, AnyObject>
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

    func urlSessionDownloadTask(_ method: httpMethod, encryptionModel: POSBaseEncryptedModel, acceptHeader: String, progress: Progress?, success: @escaping (_ url: URL) -> Void , failure: @escaping (_ error: APIError) -> ()) -> URLSessionTask {
        let encryptedModelUri = encryptionModel.uri
        let urlRequest = fileTransferSessionManager.requestSerializer.request(withMethod: "GET", urlString: encryptionModel.uri, parameters: nil, error: nil)
        urlRequest.allHTTPHeaderFields![Constants.HTTPHeaderKeys.accept] = acceptHeader
        fileTransferSessionManager.setDownloadTaskDidWriteDataBlock { (session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExptextedToWrite) -> Void in
            progress?.completedUnitCount = totalBytesWritten
        }

        let isAttachment = encryptionModel is POSAttachment

        let task = fileTransferSessionManager.downloadTask(with: urlRequest as URLRequest, progress: nil, destination: { (url, response) -> URL in
            let changedBaseEncryptionModel : POSBaseEncryptedModel? = {
                if isAttachment {
                    return POSAttachment.existingAttachment(withUri: encryptedModelUri, in: POSModelManager.shared().managedObjectContext)
                } else {
                    return POSReceipt.existingReceipt(withUri: encryptedModelUri, in: POSModelManager.shared().managedObjectContext)
                }
            }()

            if let filePath = changedBaseEncryptionModel?.decryptedFilePath() {
                return URL(fileURLWithPath: filePath)
            } else {
                return URL()
            }

            }, completionHandler: { (response, fileURL, error) -> Void in
                if let actualError = error {
                    if (error!.code != NSURLErrorCancelled) {
                        if HTTPURLResponse.isUnathorized(response as? HTTPURLResponse) {
                            OAuthToken.removeAccessTokenForOAuthTokenWithScope(kOauth2ScopeFull)
                            Logger.dpostLogWarning("accesstoken was invalid, will try to fetch a new using refresh token", location: "downloading a file", UI: "User waiting for file to complete download", cause: "might be a problem with clock on users device, or token was revoked")
                            self.validateFullScope {
                                failure(APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.unknownError.rawValue, userInfo: nil))
                            }
                        } else {
                            failure(APIError(error: actualError as NSError))
                        }
                    }
                } else if let actualFileUrl = fileURL {
                    success(actualFileUrl)
                }
                // we get here if the request was canceled, should do nothing.
        })
        return task
    }

    fileprivate func isUnauthorized(_ urlResponse: HTTPURLResponse?) -> Bool {
        if let actualResponse = urlResponse as HTTPURLResponse! {
            if (actualResponse.statusCode == 403 || actualResponse.statusCode == 401) {
                return true
            }
        }
        return false
    }

    /**
    GET a request to server that fetches json structures, like list of documents, list of folders.

    :param: url         url to fetch data from
    :param: parameters  dictionary with query parameters of the HTTP-GET-request, such as skip, take, and/or search
    :param: success     block with json data that has to be inserted to database
    :param: failure     failure block with error that should be sent to present a UIAlertcontroller with API error

    :returns: a task to resume when the request should be started
    */
    func urlSessionJSONTask(url: String, parameters: Dictionary<String,String>? = nil, success: @escaping (Dictionary<String,AnyObject>) -> Void , failure: @escaping (_ error: APIError) -> ()) -> URLSessionTask {

        var fullURL: URL
        if let existingParameters = parameters {
            fullURL = URL(string: url.getURLStringWithQueryParametersFrom(existingParameters), relativeTo: URL(string: k__SERVER_URI__))!
        } else {
            fullURL = URL(string: url, relativeTo: URL(string: k__SERVER_URI__))!
        }
        
        let urlRequest = NSMutableURLRequest(url: fullURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.httpMethod = httpMethod.get.rawValue
        for (key, value) in self.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let task = jsonDataTask(urlRequest as URLRequest, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue {
                OAuthToken.removeAccessTokenForOAuthTokenWithScope(kOauth2ScopeFull)
                Logger.dpostLogWarning("accesstoken was invalid, will try to fetch a new using refresh token", location: "somewhere a jsonDataTask is performed, ex: downloading list of documents, list of folders", UI: "User waiting for the request to finish", cause: "might be a problem with clock on users device, or token was revoked")
                self.validateFullScope {
                    failure(APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.unknownError.rawValue, userInfo: nil))
                }
            } else {
                failure(error)
            }
        }

        return task
    }

    func urlSessionTask(_ method: httpMethod, url:String, parameters: Dictionary<String,AnyObject>? = nil, success: @escaping () -> Void , failure: @escaping (_ error: APIError) -> ()) -> URLSessionTask {
        let url = URL(string: url)
        let urlRequest = NSMutableURLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.httpMethod = method.rawValue
        
        if let actualParameters = parameters {
            urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: actualParameters, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
        for (key, value) in self.additionalHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let task = dataTask(urlRequest as URLRequest, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized.rawValue {
                OAuthToken.removeAccessTokenForOAuthTokenWithScope(kOauth2ScopeFull)
                Logger.dpostLogWarning("accesstoken was invalid, will try to fetch a new using refresh token", location: "doing a data task, ex renaming file, moving a document or folder", UI: "User is waiting for a data task to finish", cause: "might be a problem with clock on users device, or token was revoked")
                self.validateFullScope {
                    failure(APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.unknownError.rawValue, userInfo: nil))
                }
            } else {
                failure(error)
            }
        }

        return task
    }

    func urlSessionTaskWithNoAuthorizationHeader(_ method: httpMethod, url:String, parameters: Dictionary<String,AnyObject>, success: @escaping () -> Void , failure: @escaping (_ error: APIError) -> ()) -> URLSessionTask {
        let url = URL(string: url)
        let urlRequest = NSMutableURLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 50)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
        urlRequest.setValue(nil, forHTTPHeaderField: "Authorization")
        let contentType = "application/vnd.digipost-\(k__API_VERSION__)+json"
        urlRequest.setValue(contentType, forHTTPHeaderField: Constants.HTTPHeaderKeys.contentType)

        let task = dataTask(urlRequest as URLRequest, success: success, failure: failure)
        return task
    }
}
