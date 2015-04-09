//
//  XCTestCase+ModelAssertions.swift
//  Digipost
//
//  Created by Håkon Bogen on 20/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import XCTest

extension XCTestCase {
    
    class func assertRootResourceObject(rootResource: POSRootResource) {
        XCTAssertTrue(rootResource.fullName == "Dangfart Utnes", "Not correct name set")
        XCTAssertTrue(rootResource.mailboxes.count == 1 , "Could not parse mailboxes")
    }
}
