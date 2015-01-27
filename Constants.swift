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
    }
    
    struct Account {
        static let viewControllerIdentifier = "accountViewController"
        static let refreshContentNotification = "refreshContentNotificiation"
        static let accountCellIdentifier = "accountCellIdentifier"
        static let mainAccountCellIdentifier = "mainAccountCellIdentifier"
        static let accountCellNibName = "AccountTableViewCell"
        static let mainAccountCellNibName = "MainAccountTableViewCell"

    }

}

    