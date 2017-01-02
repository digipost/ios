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
    fileprivate func setFontTraits(_ fontTraits: UIFontDescriptorSymbolicTraits, string: String, enabled: Bool, textComposerModule: TextComposerModule) {
        let rangeOfString = (textComposerModule.attributedText.string as NSString).range(of: string)
        textComposerModule.setFontTrait(fontTraits, enabled: enabled , atRange:rangeOfString)
    }

    fileprivate func assertEqual() {

    }

    func testParagraph() {
        let wantedOutput = "<p>\(Strings.one)</p>"
        let textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        XCTAssertEqual(textComposerModule.htmlRepresentation() as String, wantedOutput, "")
    }

    func testBoldInParagraph() {
        let wantedOutput = "<p>\(Strings.one)<b>\(Strings.two)</b></p>"
        let textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        let rangeOfString = (textComposerModule.attributedText.string as NSString).range(of: Strings.two)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.traitBold, enabled: true , atRange:rangeOfString)
        XCTAssertEqual(textComposerModule.htmlRepresentation() as String, wantedOutput, "")
    }

    func testWholeBoldParagraph() {
        let wantedOutput = "<p><b>\(Strings.one)</b></p>"
        let textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        let rangeOfString = (textComposerModule.attributedText.string as NSString).range(of: Strings.one)
        textComposerModule.setFontTrait(.traitBold, enabled: true , atRange:rangeOfString)
        XCTAssertEqual(textComposerModule.htmlRepresentation() as String, wantedOutput, "")
    }

    func testTwoBoldRangesInParagraph() {
        let wantedOutput = "<p>\(Strings.one)<b>\(Strings.two)</b>\(Strings.three)<b>\(Strings.four)</b></p>"
        let textComposerModule = TextComposerModule.paragraphModule()

        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendCharactersToEndOfString(Strings.two)

        let rangeOfString = (textComposerModule.attributedText.string as NSString).range(of: Strings.two)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.traitBold, enabled: true, atRange:rangeOfString)

        textComposerModule.appendCharactersToEndOfString(Strings.three)
        textComposerModule.appendCharactersToEndOfString(Strings.four)

        let rangeOfStringThree = (textComposerModule.attributedText.string as NSString).range(of: Strings.three)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.traitBold, enabled: false, atRange:rangeOfStringThree)

        let rangeOfStringFour = (textComposerModule.attributedText.string as NSString).range(of: Strings.four)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.traitBold, enabled: true, atRange:rangeOfStringFour)

        XCTAssertEqual(textComposerModule.htmlRepresentation() as String, wantedOutput, "")
    }

    func testBoldAndItalicInParagraph() {
        let wantedOutput = "<p>\(Strings.one)<b>\(Strings.two)</b>\(Strings.three)<i>\(Strings.four)</i></p>"

        let textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        textComposerModule.appendCharactersToEndOfString(Strings.three)
        textComposerModule.appendCharactersToEndOfString(Strings.four)

        let rangeOfString = (textComposerModule.attributedText.string as NSString).range(of: Strings.two)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.traitBold, enabled: true, atRange:rangeOfString)

        let rangeOfStringFour = (textComposerModule.attributedText.string as NSString).range(of: Strings.four)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.traitItalic, enabled: true, atRange:rangeOfStringFour)

        XCTAssertEqual(textComposerModule.htmlRepresentation() as String, wantedOutput, "")
    }

    func testLotsOfBoldRangesInMultipleParagraphs() {
        let wantedOutput = "<p>\(Strings.one)<b>\(Strings.two)</b></p><p>\(Strings.three)<b>\(Strings.four)</b>\(Strings.five)</p><p><b>\(Strings.six)</b></p>"

        let textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.three)
        textComposerModule.appendCharactersToEndOfString(Strings.four)
        textComposerModule.appendCharactersToEndOfString(Strings.five)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.six)

        setFontTraits(.traitBold, string: Strings.two, enabled: true, textComposerModule: textComposerModule)
        setFontTraits(.traitBold, string: Strings.four, enabled: true, textComposerModule: textComposerModule)
        setFontTraits(.traitBold, string: Strings.six, enabled: true, textComposerModule: textComposerModule)

        XCTAssertEqual(textComposerModule.htmlRepresentation() as String, wantedOutput, "")
    }

    func testTwoParagraphs() {
        let wantedOutput = "<p>\(Strings.one)</p><p>\(Strings.two)</p>"
        let textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        XCTAssertEqual(textComposerModule.htmlRepresentation() as String, wantedOutput, "")
    }

    func testThreeParagraphs() {
        let wantedOutput = "<p>\(Strings.one)</p><p>\(Strings.two)</p><p>\(Strings.three)</p>"
        let textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.three)
        XCTAssertEqual(textComposerModule.htmlRepresentation() as String, wantedOutput, "")
    }

    func testMixedBoldAndItalicInSingleParagraph() {
        let wantedOutput = "<p><b>\(Strings.one)</b><i><b>\(Strings.two)</i></b><i>\(Strings.three)</i></p>"
        let textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        textComposerModule.appendCharactersToEndOfString(Strings.three)

        setFontTraits(.traitBold, string: Strings.one + Strings.two, enabled: true, textComposerModule: textComposerModule)
        setFontTraits(.traitItalic, string: Strings.two + Strings.three, enabled: true, textComposerModule: textComposerModule)
        XCTAssertEqual(textComposerModule.htmlRepresentation() as String, wantedOutput, "")
    }

    func testThreeParagraphsWithCompleteStylingOnOne() {
        let wantedOutput = "<p>\(Strings.one)</p><p>\(Strings.two)</p><p><b>\(Strings.three)</b></p>"
        let textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.three)

        let rangeOfStringThree = (textComposerModule.attributedText.string as NSString).range(of: Strings.three)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.traitBold, enabled: true, atRange:rangeOfStringThree)
        XCTAssertEqual(textComposerModule.htmlRepresentation() as String, wantedOutput, "")
    }

    func testThreeParagraphsWithPartialStylingOnOne() {
        let wantedOutput = "<p>\(Strings.one)</p><p>\(Strings.two)</p><p><b>\(Strings.three)</b>\(Strings.four)</p>"
        let textComposerModule = TextComposerModule.paragraphModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        textComposerModule.appendNewParagraph()
        textComposerModule.appendCharactersToEndOfString(Strings.three)
        textComposerModule.appendCharactersToEndOfString(Strings.four)

        let rangeOfStringThree = (textComposerModule.attributedText.string as NSString).range(of: Strings.three)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.traitBold, enabled: true, atRange:rangeOfStringThree)

        print(textComposerModule.attributedText)
        XCTAssertEqual(textComposerModule.htmlRepresentation() as String, wantedOutput, "")
    }

    func testHeadline1() {
        let wantedOutput = "<h1>\(Strings.one)\(Strings.two)</h1>"
        let textComposerModule = TextComposerModule.headlineModule()
        textComposerModule.appendCharactersToEndOfString(Strings.one)
        textComposerModule.appendCharactersToEndOfString(Strings.two)
        let rangeOfString = (textComposerModule.attributedText.string as NSString).range(of: Strings.two)
        textComposerModule.setFontTrait(UIFontDescriptorSymbolicTraits.traitBold, enabled: true , atRange:rangeOfString)
        XCTAssertEqual(textComposerModule.htmlRepresentation() as String, wantedOutput, "")
    }

}
