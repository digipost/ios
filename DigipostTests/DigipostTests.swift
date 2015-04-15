//
//  DigipostTests.swift
//  DigipostTests
//
//  Created by Håkon Bogen on 15/04/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import XCTest
import KIF

class DigipostTests: KIFTestCase {

    override func beforeAll() {
        super.beforeAll()

    }
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

    }
    
    func testExample() {
        // This is an example of a functional test case.
        tester.tapViewWithAccessibilityLabel(AccessibilityLabels.Onboarding.getStartedButton)
        tester.tapViewWithAccessibilityLabel(AccessibilityLabels.Onboarding.loginButton)
        tester.waitForTimeInterval(2)
        tester.tapScreenAtPoint(CGPointMake(150, 200))
        tester.waitForSoftwareKeyboard()
        tester.enterTextIntoCurrentFirstResponder("Your fnr here")
        tester.tapScreenAtPoint(CGPointMake(150, 250))
        tester.waitForTimeInterval(0.1)
        tester.enterTextIntoCurrentFirstResponder("your password here")
        tester.waitForTimeInterval(1)
        tester.tapScreenAtPoint(CGPointMake(150, 300))
        tester.waitForTimeInterval(4)
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
    }


    
}
