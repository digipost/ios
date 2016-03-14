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

class ComposerTests: XCTestCase {

    struct Strings {
        static let one = "Carl Sagan"
        static let two = " on a trip for Titan."
        static let three = "Giordano Bruno"
        static let four = " visiting Andromeda."
        static let five = "We are all in the gutter, but some of us are looking at the stars."
        static let six = "Which came first - time or space?"
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // Convience for setting font traits at range
    private func setFontTraits(fontTraits: UIFontDescriptorSymbolicTraits, string: String, enabled: Bool, textComposerModule: TextComposerModule) {
        let rangeOfString = (textComposerModule.attributedText.string as NSString).rangeOfString(string)
        textComposerModule.setFontTrait(fontTraits, enabled: enabled , atRange:rangeOfString)
    }

    private func assertEqual() {

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

    func testWholeBoldParagraph() {
        let wantedOutput = "<p><b>\(Strings.one)</b></p>"
        var textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        let rangeOfString = (textComposerModule.attributedText.string as NSString).rangeOfString(Strings.one)
        textComposerModule.setFontTrait(.TraitBold, enabled: true , atRange:rangeOfString)
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

    func testBoldAndItalicInParagraph() {
        let wantedOutput = "<p>\(Strings.one)<b>\(Strings.two)</b>\(Strings.three)<i>\(Strings.four)</i></p>"

        var textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        textComposerModule.appendCharactersToEndOfString(Strings.three)
        textComposerModule.appendCharactersToEndOfString(Strings.four)

        let rangeOfString = (textComposerModule.attributedText.string as NSString).rangeOfString(Strings.two)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.TraitBold, enabled: true, atRange:rangeOfString)

        let rangeOfStringFour = (textComposerModule.attributedText.string as NSString).rangeOfString(Strings.four)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.TraitItalic, enabled: true, atRange:rangeOfStringFour)

        XCTAssertEqual(textComposerModule.htmlRepresentation(), wantedOutput, "")
    }

    func testLotsOfBoldRangesInMultipleParagraphs() {
        let wantedOutput = "<p>\(Strings.one)<b>\(Strings.two)</b></p><p>\(Strings.three)<b>\(Strings.four)</b>\(Strings.five)</p><p><b>\(Strings.six)</b></p>"

        var textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.three)
        textComposerModule.appendCharactersToEndOfString(Strings.four)
        textComposerModule.appendCharactersToEndOfString(Strings.five)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.six)

        setFontTraits(.TraitBold, string: Strings.two, enabled: true, textComposerModule: textComposerModule)
        setFontTraits(.TraitBold, string: Strings.four, enabled: true, textComposerModule: textComposerModule)
        setFontTraits(.TraitBold, string: Strings.six, enabled: true, textComposerModule: textComposerModule)

        XCTAssertEqual(textComposerModule.htmlRepresentation(), wantedOutput, "")
    }

    func testTwoParagraphs() {
        let wantedOutput = "<p>\(Strings.one)</p><p>\(Strings.two)</p>"
        var textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        XCTAssertEqual(textComposerModule.htmlRepresentation(), wantedOutput, "")
    }

    func testThreeParagraphs() {
        let wantedOutput = "<p>\(Strings.one)</p><p>\(Strings.two)</p><p>\(Strings.three)</p>"
        var textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.three)
        XCTAssertEqual(textComposerModule.htmlRepresentation(), wantedOutput, "")
    }

    func testMixedBoldAndItalicInSingleParagraph() {
        let wantedOutput = "<p><b>\(Strings.one)</b><i><b>\(Strings.two)</i></b><i>\(Strings.three)</i></p>"
        var textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        textComposerModule.appendCharactersToEndOfString(Strings.three)

        setFontTraits(.TraitBold, string: Strings.one + Strings.two, enabled: true, textComposerModule: textComposerModule)
        setFontTraits(.TraitItalic, string: Strings.two + Strings.three, enabled: true, textComposerModule: textComposerModule)
        XCTAssertEqual(textComposerModule.htmlRepresentation(), wantedOutput, "")
    }

    func testThreeParagraphsWithCompleteStylingOnOne() {
        let wantedOutput = "<p>\(Strings.one)</p><p>\(Strings.two)</p><p><b>\(Strings.three)</b></p>"
        var textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.three)

        let rangeOfStringThree = (textComposerModule.attributedText.string as NSString).rangeOfString(Strings.three)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.TraitBold, enabled: true, atRange:rangeOfStringThree)
        XCTAssertEqual(textComposerModule.htmlRepresentation(), wantedOutput, "")
    }

    func testThreeParagraphsWithPartialStylingOnOne() {
        let wantedOutput = "<p>\(Strings.one)</p><p>\(Strings.two)</p><p><b>\(Strings.three)</b>\(Strings.four)</p>"
        var textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.three)
        textComposerModule.appendCharactersToEndOfString(Strings.four)

        let rangeOfStringThree = (textComposerModule.attributedText.string as NSString).rangeOfString(Strings.three)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.TraitBold, enabled: true, atRange:rangeOfStringThree)

        print(textComposerModule.attributedText)
        XCTAssertEqual(textComposerModule.htmlRepresentation(), wantedOutput, "")
    }

    func testHeadline1() {
        let wantedOutput = "<h1>\(Strings.one)\(Strings.two)</h1>"
        var textComposerModule = TextComposerModule.headlineModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        let rangeOfString = (textComposerModule.attributedText.string as NSString).rangeOfString(Strings.two)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.TraitBold, enabled: true , atRange:rangeOfString)
        XCTAssertEqual(textComposerModule.htmlRepresentation(), wantedOutput, "")
    }

}
