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

class APITests: XCTestCase {

    override func setUp() {
        super.setUp()
        let oAuthToken = XCTestCase.mockTokenWithScope(kOauth2ScopeFull)
        
        // get valid OAuthToken
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
//        OAuthToken.removeAllTokens()
    }
    
    func testGetRootResource() {
        let expectation = expectationWithDescription("fetched root resource")
        
        let token = OAuthToken.oAuthTokenWithScope(kOauth2ScopeFull)
            APIClient.sharedClient.updateRootResource(success: { (responseDictionary) -> Void in
                POSModelManager.sharedManager().updateRootResourceWithAttributes(responseDictionary)
                expectation.fulfill()
                let rootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext)
                XCTestCase.assertRootResourceObject(rootResource)
            }, failure: { (error) -> () in
                XCTFail(error.description)
                expectation.fulfill()
            })
        waitForExpectationsWithTimeout(50, handler: { (error) -> Void in
    })
        
    }
}
