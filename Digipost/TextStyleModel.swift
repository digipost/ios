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

    init(value: Any, preferredIconName: String ) {
        self.value = value
        self.preferredIconName = preferredIconName
        enabled = false
    }

    private static func boldTextStyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFontDescriptorSymbolicTraits.TraitBold, preferredIconName: "")
    }

    private static func italicTextStyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFontDescriptorSymbolicTraits.TraitItalic, preferredIconName: "")
    }

    private static func underlineTextStyleModel() -> TextStyleModel {
        return TextStyleModel(value: NSUnderlineStyle.StyleSingle, preferredIconName: "")
    }

    private static func h1StyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.headlineH1(), preferredIconName: "")
    }

    private static func h2StyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.headlineH2(), preferredIconName: "")
    }

    private static func h3StyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.headlineH3(), preferredIconName: "")
    }

    private static func paragraphStyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.paragraph(), preferredIconName: "")
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
        return [multiButtonStyleArray]
    }

}