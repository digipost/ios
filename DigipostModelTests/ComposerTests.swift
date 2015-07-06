//
//  ComposerTests.swift
//  Digipost
//
//  Created by Håkon Bogen on 03/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//
//
import UIKit
import XCTest

class ComposerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    static let testString = "hello world"
    
    func testTextAlignmentHTMLRepresentation() {
        let wantedOutput = "<p>\(ComposerTests.testString)</p>"
        var textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.setTextAlignment(NSTextAlignment.Right)
        textComposerModule.appendCharactersToEndOfString(ComposerTests.testString)
        XCTAssertEqual(textComposerModule.htmlRepresentation(), wantedOutput, "")
    }

}
