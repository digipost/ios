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
import XCTest

extension XCTestCase {
    
    class func jsonDictionaryFromFile(filename: String) -> Dictionary<String, AnyObject> {
        let testBundle = NSBundle(forClass: OAuthTests.self)
        let path = testBundle.pathForResource(filename, ofType: nil)
        XCTAssertNotNil(path, "wrong filename")
        let data = NSData(contentsOfFile: path!)
        XCTAssertNotNil(data, "wrong filename")
        var error : NSError?
        let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: &error) as Dictionary<String,AnyObject>
        XCTAssertNil(error, "could not read json")
        return jsonDictionary
    }
    
    class func mockTokenWithScope(scope: String) -> OAuthToken {
        var oAuthDictionary: Dictionary <String,AnyObject>!
        if scope == kOauth2ScopeFull {
            oAuthDictionary = XCTestCase.jsonDictionaryFromFile("ValidOAuthToken.json")
        } else {
            oAuthDictionary = XCTestCase.jsonDictionaryFromFile("ValidOAuthTokenHigherSecurity.json")
        }
        let token = OAuthToken(attributes: oAuthDictionary, scope: scope)
        return token!
    }
}
