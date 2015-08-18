//
//  TextStyleModel.swift
//  Digipost
//
//  Created by Håkon Bogen on 08/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation


enum TextStyleModelType {
    case Text
}

class TextStyleModel {

    let value : Any
    let preferredIconName : String
    var enabled : Bool

    // keyword used around to mark what kind of style it is
    var keyword : String

    init(value: Any, preferredIconName: String, keyword : String ) {
        self.value = value
        self.preferredIconName = preferredIconName
        enabled = false
        self.keyword = keyword
    }

    private static func boldTextStyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFontDescriptorSymbolicTraits.TraitBold, preferredIconName: "", keyword: "Bold")
    }

    private static func italicTextStyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFontDescriptorSymbolicTraits.TraitItalic, preferredIconName: "", keyword: "Italic")
    }

    private static func underlineTextStyleModel() -> TextStyleModel {
        return TextStyleModel(value: NSUnderlineStyle.StyleSingle, preferredIconName: "", keyword: "underline")
    }

    private static func h1StyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.headlineH1(), preferredIconName: "", keyword: "h1")
    }

    private static func h2StyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.headlineH2(), preferredIconName: "", keyword: "h2")
    }

    private static func h3StyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.headlineH3(), preferredIconName: "", keyword: "h3")
    }

    private static func paragraphStyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.paragraph(), preferredIconName: "", keyword: "paragraph")
    }

    /**
    Returns array with array of text style models.
    Where there are more than one model in the array, the ui should show them in
    multi segmented controls

    :returns: array with array of textstylemodels

    */
    static func allTextStyleModels() -> [[TextStyleModel]] {
        let multiButtonStyleArray = [boldTextStyleModel(), italicTextStyleModel(), underlineTextStyleModel()]
        let stylePickerArray = [h1StyleModel(), h2StyleModel(), h3StyleModel(), paragraphStyleModel()]
        return [multiButtonStyleArray, stylePickerArray]
    }

}