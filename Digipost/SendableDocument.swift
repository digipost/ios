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

class SendableDocumentConstants {
    static let subject = "subject"
    static let kladd = "kladd"
    static let deliveryMethod = "deliveryMethod"
    static let DIGIPOST = "DIGIPOST"
    static let authenticationLevel = "authenticationLevel"

    static let deleteMessageRelPostfix = "delete_message"
    static let addContentRelPostfix = "add_content"
    static let updateMessageRelPostfix = "update_message"
    static let selfRelPostfix = "self"
    static let sendRelPostfix = "send"

    static let link = "link"
    static let rel = "rel"
    static let uri = "uri"

    static let tempFileName = "temp.html"
}


class SendableDocument {
    var deleteMessageUri : String?
    var addContentUri : String?
    var updateMessageUri : String?
    var getSelfUri : String?
    var sendUri : String?
    var status : String?

    var recipients = [Recipient]()

    init(dictionary: [String : AnyObject]) {
        setupWithJSONContent(dictionary)
    }

    init(recipients: [Recipient]) {
        self.recipients = recipients
    }

    func setupWithJSONContent(_ jsonDictionary: [String : AnyObject]) {
        if let linkArray = jsonDictionary[SendableDocumentConstants.link] as? [[String : String]] {
            for link in linkArray {
                if let relLink = link[SendableDocumentConstants.rel], let relURL = URL(string: relLink) {
                    switch relURL.lastPathComponent{
                    case SendableDocumentConstants.deleteMessageRelPostfix:
                        deleteMessageUri = link[SendableDocumentConstants.uri] as String?
                        break
                    case SendableDocumentConstants.updateMessageRelPostfix:
                        updateMessageUri = link[SendableDocumentConstants.uri] as String?
                        break
                    case SendableDocumentConstants.addContentRelPostfix:
                        addContentUri = link[SendableDocumentConstants.uri] as String?
                        break
                    case SendableDocumentConstants.selfRelPostfix:
                        getSelfUri = link[SendableDocumentConstants.uri] as String?
                        break
                    case SendableDocumentConstants.sendRelPostfix:
                        sendUri = link[SendableDocumentConstants.uri] as String?
                        break

                    default:
                        break
                    }
                }
            }
        }
    }

    func urlForHTMLContentOnDisk(_ htmlContent: String) -> URL? {
        let fileUrl = URL(fileURLWithPath: POSFileManager.shared().uploadsFolderPath()).appendingPathComponent(SendableDocumentConstants.tempFileName)
        if FileManager.default.createFile(atPath: fileUrl.absoluteString, contents: htmlContent.data(using: String.Encoding.utf8, allowLossyConversion: false), attributes: nil) {
            return URL(fileURLWithPath: fileUrl.absoluteString)
        } else {
            return nil
        }
    }

   func draftParameters() -> [ String : AnyObject] {
    let digipostAddresses = self.recipients.map { (recipient) -> [String : String] in
        return [ Constants.Recipient.digipostAddress : recipient.digipostAddress!]
    }
    return [SendableDocumentConstants.subject : SendableDocumentConstants.kladd as AnyObject, SendableDocumentConstants.deliveryMethod : SendableDocumentConstants.DIGIPOST as AnyObject, SendableDocumentConstants.authenticationLevel : AuthenticationLevel.password as AnyObject, Constants.Recipient.recipient: digipostAddresses as AnyObject]
    }
}
