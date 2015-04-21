//
//  SendObject.swift
//  Digipost
//
//  Created by Håkon Bogen on 21/04/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

class SendableDocumentConstants {
    static let subject = "subject"
    static let kladd = "kladd"
    static let deliveryMethod = "deliveryMethod"
    static let DIGIPOST = "DIGIPOST"
    static let authenticationLevel = "authenticationLevel"

    static let deleteMessageRelPostfix = "delete_message"
    static let addContentRelPostfix = "add_content"
    static let updateMessageRelPostfix = "update_message"

    static let link = "link"
    static let rel = "rel"
    static let uri = "uri"

}


class SendableDocument {
    var deleteMessageUri : String?
    var addContentUri : String?
    var updateMessageUri : String?
    var status : String?

    var recipients = [Recipient]()

    init(dictionary: [String : AnyObject]) {
        if let linkArray = dictionary[SendableDocumentConstants.link] as? [[String : String]] {
            for link in linkArray {
                if let relLink = link[SendableDocumentConstants.rel] {
                    switch relLink.lastPathComponent {
                    case SendableDocumentConstants.deleteMessageRelPostfix:
                        deleteMessageUri = link[SendableDocumentConstants.uri] as String?
                        break
                    case SendableDocumentConstants.updateMessageRelPostfix:
                        updateMessageUri = link[SendableDocumentConstants.uri] as String?
                        break
                    case SendableDocumentConstants.addContentRelPostfix:
                        addContentUri = link[SendableDocumentConstants.uri] as String?
                        break
                    default:
                        break
                    }
                }
            }
        }
    }

    func urlForHTMLContentOnDisk(htmlContent: String) -> NSURL? {
        POSFileManager.sharedFileManager().uploadsFolderPath()
        let filePath = POSFileManager.sharedFileManager().uploadsFolderPath().stringByAppendingPathComponent("temp.html")
        if NSFileManager.defaultManager().createFileAtPath(filePath, contents: htmlContent.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false), attributes: nil) {
            return NSURL(fileURLWithPath: filePath)
        } else {
            println(filePath)
            return nil
        }
    }

    class func draftParameters() -> [ String : String] {
        return [SendableDocumentConstants.subject : SendableDocumentConstants.kladd, SendableDocumentConstants.deliveryMethod : SendableDocumentConstants.DIGIPOST, SendableDocumentConstants.authenticationLevel : AuthenticationLevel.password]
    }
}