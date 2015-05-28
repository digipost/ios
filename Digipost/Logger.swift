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


@objc
class Logger {

    private struct Constants {
        static let severity = "severity"
        static let message = "message"

        static let uri = "/post/log/mobile/ios"

        // enable when endpoint is ready
        static let currentlyEnabled = true
    }

    class func dpostLogDebug(message: String) {
        dpostLog(DpostLogSeverity.Debug, message: message)
    }

    class func dpostLogInfo(message: String) {
        dpostLog(DpostLogSeverity.Info, message: message)
    }

    class func dpostLogWarn(message: String) {
        dpostLog(DpostLogSeverity.Warn, message: message)
    }

    class func dpostLogError(message: String) {
        dpostLog(DpostLogSeverity.Error, message: message)
    }

    private class func dpostLog(severity: DpostLogSeverity, message: String) {
        if Logger.Constants.currentlyEnabled {
            let parameters = [ Logger.Constants.severity : severity.rawValue, Logger.Constants.message : message ]
            APIClient.sharedClient.postLog(uri: Logger.Constants.uri, parameters: parameters)
        }
        DLog(message)
    }



}

 func DLog(message: String, function: String = __FUNCTION__) {
    #if DEBUG
        println("\(function): \(message)")
    #endif
}