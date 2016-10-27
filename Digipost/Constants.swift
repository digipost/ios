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

struct Constants {
    
    struct APIClient {
        static let taskCounter = "taskCounter"
        static var baseURL : String {
            return k__SERVER_URI__
        }
        
        struct AttributeKey {
            static let location = "location"
            static let subject = "subject"
            static let folderId = "folderId"
            static let identifier = "id"
            static let name = "name"
            static let icon = "icon"
            static let folder = "folder"
            static let token = "token"
            static let device = "device"
        }
        
    }
    
    struct FolderName {
            static let inbox = "INBOX"
            static let folder = "FOLDER"
    }
    
    struct HTTPHeaderKeys {
        static let accept = "Accept"
        static let contentType = "Content-Type"
    }
    
    struct Error {
        static let apiErrorDomainOAuthUnauthorized = "oAuthUnauthorized"
        
        static let apiClientErrorDomain = "APIManagerErrorDomain"
        enum Code : Int {
            case oAuthUnathorized = 4001
            case uploadFileDoesNotExist = 4002
            case uploadFileTooBig = 4003
            case uploadLinkNotFoundInRootResource = 4004
            case uploadFailed = 4005
            case NeedHigherAuthenticationLevel = 4006
            case UnknownError = 4007
            case NoOAuthTokenPresent = 4008
        }
        static let apiClientErrorScopeKey = "scope"
    }

    struct Account {
        static let viewControllerIdentifier = "accountViewController"
        static let refreshContentNotification = "refreshContentNotificiation"
        static let accountCellIdentifier = "accountCellIdentifier"
        static let mainAccountCellIdentifier = "mainAccountCellIdentifier"
        static let accountCellNibName = "AccountTableViewCell"
        static let mainAccountCellNibName = "MainAccountTableViewCell"
    }
    
    struct Invoice {
        static let InvoiceBankTableViewNibName = "InvoiceBankTableView"
        static let InvoiceBankTableViewCellNibName = "InvoiceBankTableViewCell"
    }
    
    struct Composer {
        static let imageModuleCellIdentifier = "ImageModuleCell"
        static let textModuleCellIdentifier = "TextModuleCell"
    }

    struct Recipient {
        static let name = "name"
        static let recipient = "recipient"
        static let address = "address"
        static let mobileNumber = "mobile-number"
        static let organizationNumber = "organisation-number"
        static let uri = "uri"
        static let digipostAddress = "digipost-address"
    }


}

func == (left:Int, right:Constants.Error.Code) -> Bool {
    return left == right.rawValue
}

func == (left:Constants.Error.Code, right:Int) -> Bool {
    return left.rawValue == right
}


    
    
