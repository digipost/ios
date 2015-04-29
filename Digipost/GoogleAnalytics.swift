//
//  GoogleAnalytics.swift
//  Digipost
//
//  Created by Håkon Bogen on 09/04/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

struct GoogleAnalyticsConstants {
    static let errorCategory = "API Error"
    static let actionCategory = "Action"
}


func track(#didShowToUserInController: UIViewController?, error: APIError) {
    let tracker = GAI.sharedInstance().defaultTracker
    let errorAction : String = {
        var fullString = ""
        if let actualViewController = didShowToUserInController {
            fullString = fullString.stringByAppendingString(NSStringFromClass(actualViewController.dynamicType))
        }
        if (error.code == APIErrorConstants.noErrorCode) {
            return fullString.stringByAppendingString("HTTP \(error.httpStatusCode)")
        }else {
            return fullString.stringByAppendingString("\(error.code)")
        }

    }()

    let label : String =  {
        if (error.domain == Constants.Error.apiErrorDomainOAuthUnauthorized) {
            return "Oauth unauthorized : \(OAuthToken.oAuthTokenWithHighestScopeInStorage()?.debugDescription) "
        }else {
            if error.responseText == nil {
                return error.description
            }
            return error.responseText!
        }
    }()
    let dictionary = GAIDictionaryBuilder.createEventWithCategory(GoogleAnalyticsConstants.errorCategory, action: errorAction, label: label, value: nil).build()
    tracker.send(dictionary  as [NSObject : AnyObject])
}

func track(#eventName: String, extraInfo: String?) {
    let tracker = GAI.sharedInstance().defaultTracker
    let dictionary = GAIDictionaryBuilder.createEventWithCategory(GoogleAnalyticsConstants.actionCategory, action: eventName, label: extraInfo, value: nil).build()
     tracker.send(dictionary  as [NSObject : AnyObject])
}