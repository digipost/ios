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

private struct OAuthTokenIdTokenConstants {
    static let nonce = "nonce"
    static let aud = "aud"
}

extension OAuthToken {
    
    class func isIdTokenValid(idToken : String?, nonce : String) -> Bool {
        if let actualIDToken = idToken {
            let idTokenContentArray  = idToken?.componentsSeparatedByString(".")
            if idTokenContentArray?.count == 2 {
                if let base64EncodedJson = idTokenContentArray?[1] {
                    var numberOfCharactersAdded = 0
                    var error : NSError?
                    var alteredBase64EncodedJson = base64EncodedJson
                    var base64Data : NSData?
                    while base64Data == nil {
                        base64Data = NSData(base64EncodedString: alteredBase64EncodedJson, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                        alteredBase64EncodedJson = alteredBase64EncodedJson.stringByAppendingString("=")
                        numberOfCharactersAdded++
                        if numberOfCharactersAdded > 2 {
                            return false
                        }
                    }
                    let jsonDataAsString = NSString(data: base64Data!, encoding: NSASCIIStringEncoding)
                    
                    do{
                        if let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(base64Data!, options: NSJSONReadingOptions.AllowFragments) as? [String : AnyObject] {
                            if let aud = jsonDictionary[OAuthTokenIdTokenConstants.aud] as? String, let nonceInJson = jsonDictionary[OAuthTokenIdTokenConstants.nonce] as? String {
                                if aud != OAUTH_CLIENT_ID {
                                    return false
                                }
                                if nonce != nonceInJson {
                                    return false
                                }
                            } else {
                                return false
                            }
                        }
                    }catch{
                        return false
                    }
                    
                    let signature = idTokenContentArray![0]
                    let tokenContent = idTokenContentArray![1]
                    let hmacEncodedTokenContent = NSString.pos_base64HmacSha256(tokenContent, secret: OAUTH_SECRET)
                    if signature != hmacEncodedTokenContent {
                        return false
                    }
                    return true
                }
            }
        }
        
        return false
        
    }
}
