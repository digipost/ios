//
//  Logger.swift
//  Digipost
//
//  Created by Håkon Bogen on 26/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation


enum DpostLogSeverity : String {
    case Debug = "DEBUG"
    case Info = "INFO"
    case Warn = "WARN"
    case Error = "ERROR"
}

class Logger {

    struct Constants {
        static let severity = "severity"
        static let message = "message"

        static let uri = "/post/log/mobile/ios"

        // enable when endpoint is ready
        static let currentlyEnabled = false
    }

    class func dpostLog(severity: String, message: String) {
        if Constants.currentlyEnabled {
            let parameters = [ Constants.severity : severity, Constants.message : message ]
            APIClient.sharedClient.postLog(Constants.uri, parameters: parameters)
        }
    }

}