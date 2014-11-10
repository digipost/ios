//
//  NSDate+Extensions.swift
//  Digipost
//
//  Created by Håkon Bogen on 07/11/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

extension NSDate {
    
    func prettyStringWithJPGExtension()-> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM YY HH:mm:ss"
        var dateString = "IMG "
        dateString = dateString.stringByAppendingString(dateFormatter.stringFromDate(self))
        dateString = dateString.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
        dateString = dateString.stringByAppendingString(".jpg")
        return dateString
    }
    
    func prettyStringWithMOVExtension()-> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM YY HH:mm:ss"
        var dateString = "MOV "
        dateString = dateString.stringByAppendingString(dateFormatter.stringFromDate(self))
        dateString = dateString.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
        dateString = dateString.stringByAppendingString(".mov")
        return dateString
    }
}
