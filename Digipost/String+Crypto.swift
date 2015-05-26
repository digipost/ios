//
//  String+Crypto.swift
//  Digipost
//
//  Created by Håkon Bogen on 19/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import Foundation

extension String {
    func hmacsha256(secret: String) -> String {
        let charKey = secret.cStringUsingEncoding(NSUTF8StringEncoding)!
        let charData = self.cStringUsingEncoding(NSASCIIStringEncoding)!
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var resultPointer = UnsafeMutablePointer<Void>.alloc(digestLength)
        let result: Void = CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), charKey, charKey.count, charData, charData.count, resultPointer)
        let HMAC = NSData(bytes: resultPointer, length: digestLength)
        let hash = HMAC.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn)
        return hash
    }

}
