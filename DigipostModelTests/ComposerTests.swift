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

    struct Strings {
        static let one = "Carl Sagan"
        static let two = " on a trip for Titan."
        static let three = "Giordano Bruno"
        static let four = " visiting Andromeda."
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParagraph() {
        let wantedOutput = "<p>\(Strings.one)</p>"
        var textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        XCTAssertEqual(textComposerModule.htmlRepresentation(), wantedOutput, "")
    }

    func testBoldInParagraph() {
        let wantedOutput = "<p>\(Strings.one)<b>\(Strings.two)</b></p>"
        var textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        let rangeOfString = (textComposerModule.attributedText.string as NSString).rangeOfString(Strings.two)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.TraitBold, enabled: true , atRange:rangeOfString)
        XCTAssertEqual(textComposerModule.htmlRepresentation(), wantedOutput, "")
    }

    func testTwoBoldRangesInParagraph() {
        let wantedOutput = "<p>\(Strings.one)<b>\(Strings.two)</b>\(Strings.three)<b>\(Strings.four)</b></p>"
        var textComposerModule = TextComposerModule.paragraphModule()

        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendCharactersToEndOfString(Strings.two)

        let rangeOfString = (textComposerModule.attributedText.string as NSString).rangeOfString(Strings.two)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.TraitBold, enabled: true, atRange:rangeOfString)

        textComposerModule.appendCharactersToEndOfString(Strings.three)
        textComposerModule.appendCharactersToEndOfString(Strings.four)

        let rangeOfStringThree = (textComposerModule.attributedText.string as NSString).rangeOfString(Strings.three)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.TraitBold, enabled: false, atRange:rangeOfStringThree)

        let rangeOfStringFour = (textComposerModule.attributedText.string as NSString).rangeOfString(Strings.four)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.TraitBold, enabled: true, atRange:rangeOfStringFour)

        XCTAssertEqual(textComposerModule.htmlRepresentation(), wantedOutput, "")
    }
}
