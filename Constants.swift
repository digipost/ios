//
//  Constants.swift
//  Digipost
//
//  Created by Håkon Bogen on 05/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//


import Foundation

struct Constants {
    
    struct APIClient {
        static let taskCounter = "taskCounter"
        static var baseURL : String {
            return __SERVER_URI__
        }
        
        struct AttributeKey {
            static let location = "location"
            static let subject = "subject"
            static let folderId = "folderId"
            static let identifier = "id"
            static let name = "name"
            static let icon = "icon"
            static let folder = "folder"
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
    
    struct Composer {
        static let imageModuleCellIdentifier = "ImageModuleCell"
        static let textModuleCellIdentifier = "TextModuleCell"
    }

}

func == (left:Int, right:Constants.Error.Code) -> Bool {
    return left == right.rawValue
}

func == (left:Constants.Error.Code, right:Int) -> Bool {
    return left.rawValue == right
}


    
    
