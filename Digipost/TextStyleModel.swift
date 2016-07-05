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

import Foundation


enum TextStyleModelType : String {
    case Bold = "Bold"
    case Italic = "Italic"
    case Underline = "underline"
    case Paragraph = "p"
    case H1 = "h1"
    case H2 = "h2"
    case OrderedList = "orderedList"
    case UnorderedList = "unorderedList"
}

class TextStyleModel {

    let value : Any
    let preferredIconName : String?
    var enabled : Bool

    // keyword used around to mark what kind of style it is
    let keyword : String

    let type : TextStyleModelType

    //  Human readable name for the text style ex. "Big headline" for h1
    let name : String?

    init(value: Any, preferredIconName: String? = nil, keyword : String, name : String? = nil, type : TextStyleModelType = .Bold) {
        self.value = value
        self.preferredIconName = preferredIconName
        enabled = false
        self.keyword = keyword
        self.name = name
        self.type = type
    }

    init(preferredIconName : String? = nil, type: TextStyleModelType) {
        self.type = type
        self.preferredIconName = preferredIconName
        enabled = false
        // deprecated
        self.keyword = "s"
        self.name = nil
        self.value = UIFont()
    }

    private static func boldTextStyleModel() -> TextStyleModel {
        return TextStyleModel(preferredIconName: "Bold", type: .Bold)
    }

    private static func italicTextStyleModel() -> TextStyleModel {
        return TextStyleModel(preferredIconName: "Italic", type: .Italic)
    }

    private static func underlineTextStyleModel() -> TextStyleModel {
        return TextStyleModel(preferredIconName: "Underline", type: .Underline)
    }

    private static func h1StyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.headlineH1(), keyword: "h1", name: "Stor overskrift")
    }

    private static func h2StyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.headlineH2(), keyword: "h2", name: "Medium overskrift")
    }

    private static func h3StyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.headlineH3(), keyword: "h3")
    }

    private static func paragraphStyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.paragraph(), keyword: "p", name: "Brødtekst")
    }

    private static func leftAlignStyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.paragraph(), preferredIconName: "left", keyword: "align-left")
    }

    private static func rightAlignStyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.paragraph(), preferredIconName: "right", keyword: "align-right")
    }

    private static func centerAlignStyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.paragraph(), preferredIconName: "center", keyword: "align-center")
    }

    private static func orderedListStyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.paragraph(), preferredIconName: "orderedList", keyword: "orderedList", type: .OrderedList)
    }

    private static func unorderedListStyleModel() -> TextStyleModel {
        return TextStyleModel(value: UIFont.paragraph(), preferredIconName: "unorderedList", keyword: "unorderedList", type: .UnorderedList)
    }

    /**
    Returns array with array of text style models.
    Where there are more than one model in the array, the ui should show them in
    multi segmented controls

    :returns: array with array of textstylemodels

    */
    static func allTextStyleModels() -> [[[TextStyleModel]]] {
        let multiButtonStyleArray = [boldTextStyleModel(), italicTextStyleModel(), underlineTextStyleModel()]
        let aParagraphStyleModel = paragraphStyleModel()
        aParagraphStyleModel.enabled = true
        let stylePickerArray = [h1StyleModel(), h2StyleModel(), h3StyleModel(), aParagraphStyleModel]
        let buttonGroups = [[multiButtonStyleArray, stylePickerArray], [[leftAlignStyleModel(), centerAlignStyleModel(), rightAlignStyleModel()]]]
        return buttonGroups
    }

}