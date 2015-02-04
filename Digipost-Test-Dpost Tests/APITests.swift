//
//  APITests.swift
//  Digipost
//
//  Created by Håkon Bogen on 20/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
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
