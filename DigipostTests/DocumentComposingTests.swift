//
//  DocumentComposingTests.swift
//  Digipost
//
//  Created by Håkon Bogen on 20/04/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import XCTest

class DocumentComposingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGenerateSimpleHTML() {
        let exampleText = "Hello world!"
        let expectedHTMLContent = "<p>Hello world!</p>"

        let textComposerModule = TextComposerModule(moduleWithFont: UIFont.systemFontOfSize(15))
        textComposerModule.text = exampleText
        let generatedHTML = textComposerModule.htmlRepresentation()
        XCTAssertTrue(generatedHTML == expectedHTMLContent, "generated html: \(generatedHTML) was not as excpeted: \(expectedHTMLContent)")
    }

}
