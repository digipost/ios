//
//  Logger.swift
//  Digipost
//
//  Created by Håkon Bogen on 26/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

///post/log/mobile/ios

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
    }

    class func dpostLog(severity: String, message: String) {

        let parameters = [ Constants.severity : severity, Constants.message : message ]


    }

}