//
//  String+Substring.swift
//  Digipost
//
//  Created by Håkon Bogen on 29/04/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension String
{
    subscript(i: Int) -> Character {
        return self[advance(startIndex, i)]
    }
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)

            return self[Range(start: startIndex, end: endIndex)]
        }
    }
}