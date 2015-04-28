//
//  LoginTests.swift
//  Digipost
//
//  Created by Håkon Bogen on 28/04/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import XCTest
import KIF

class LoginTests: KIFTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func getToLoginScreenIfPossible() {
        if let getStartedButton = UIApplication.sharedApplication().keyWindow?.accessibilityElementWithLabel(AccessibilityLabels.Onboarding.getStartedButton) {
            tester.tapViewWithAccessibilityLabel(AccessibilityLabels.Onboarding.getStartedButton)
        } else {

        }
    }

    func testExample() {
        // This is an example of a functional test case.
        getToLoginScreenIfPossible()
        tester.waitForTimeInterval(2)
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
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
