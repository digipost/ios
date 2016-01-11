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
        let result = self.startIndex.advancedBy(i)
        return self[result]
    }

    // O(n)
    subscript (r: Range<Int>) -> String {
        get {
            var counter = 0
            var currentIndex = self.startIndex
            var stringInRange = ""
            while counter < r.endIndex && currentIndex < self.endIndex {
                currentIndex = currentIndex.successor()
                stringInRange.append(self[currentIndex])
                counter++
            }
            return stringInRange

        }
    }
}