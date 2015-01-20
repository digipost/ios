//
//  ModelTests.swift
//  Digipost
//
//  Created by Håkon Bogen on 20/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import XCTest

class ModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        OAuthToken.removeAllTokens()
        POSModelManager.sharedManager().deleteAllObjects()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testRootResource() {
        let responseDict = XCTestCase.jsonDictionaryFromFile("rootresource.json")
        POSModelManager.sharedManager().updateRootResourceWithAttributes(responseDict)
        let managedObjectContext = POSModelManager.sharedManager().managedObjectContext
        let rootResource = POSRootResource.existingRootResourceInManagedObjectContext(managedObjectContext)
        XCTestCase.assertRootResourceObject(rootResource)
    }

}
