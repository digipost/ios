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

    /**
    Returns array with array of text style models.
    Where there are more than one model in the array, the ui should show them in
    multi segmented controls

    :returns: array with array of textstylemodels

    */
    static func allTextStyleModels() -> [[TextStyleModel]] {
        let multiButtonStyleArray = [boldTextStyleModel(), italicTextStyleModel(), underlineTextStyleModel()]
        return [multiButtonStyleArray]
    }
}