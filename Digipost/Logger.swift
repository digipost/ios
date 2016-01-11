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

    private struct Constants {
        static let severity = "severity"
        static let message = "message"

        static let uri = "/post/log/mobile/ios"

    }

    /**
    Log an error to digipost log service on a specific format. 
    Example on format with a single String:
    Logger dpostLogError:@"Description: State-parameter returned from server differed from what client sent | Location: Showing OAuth Login Screen | UI: User will get an error and be asked to try logging in again | Cause: Server is broken or man in the middle"];

    :param: description    Explanation on what caused the error
    :param: location       Where in the app the error happened
    :param: UI             How will it look to the user
    :param: cause          What most likely caused the error
    */
    class func dpostLogError(description: String, location: String, UI: String, cause: String ) {
        let message = standardizedMessage(description, location: location, UI: UI, cause: cause)
        dpostLog(.Error, message: message)
    }

    /**
    Log a warning to digipost log service on a specific format.
    Example on format with a single String:
    Logger dpostLogWarning:@"Description: State-parameter returned from server differed from what client sent | Location: Showing OAuth Login Screen | UI: User will get an error and be asked to try logging in again | Cause: Server is broken or man in the middle"];

    :param: description    Explanation on what caused the warning
    :param: location       Where in the app the error happened
    :param: UI             How will it look to the user
    :param: cause          What most likely caused the warning
    */
    class func dpostLogWarning(description: String, location: String, UI: String, cause: String ) {
        let message = standardizedMessage(description, location: location, UI: UI, cause: cause)
        dpostLog(.Warn, message: message)
    }

    private class func standardizedMessage(description: String , location: String, UI: String, cause: String) -> String {
        return "Description: \(description) | Location: \(location) | UI: \(UI) | Cause: \(cause)"
    }

    private class func dpostLog(severity: DpostLogSeverity, message: String) {
        let parameters = [ Logger.Constants.severity : severity.rawValue, Logger.Constants.message : message ]
        APIClient.sharedClient.postLog(uri: Logger.Constants.uri, parameters: parameters)
    }

}

func DLog(message: String, function: String = __FUNCTION__) {
    #if DEBUG
        print("\(function): \(message)")
    #endif
}