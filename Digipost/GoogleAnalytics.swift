//
//  GoogleAnalytics.swift
//  Digipost
//
//  Created by Håkon Bogen on 09/04/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

struct GoogleAnalyticsConstants {
    static let errorCategory = "APIError"
    static let actionCategory = "Action"
}

func track(#error: APIError) {
    let tracker = GAI.sharedInstance().defaultTracker
    let errorAction : String = {
        if (error.code == APIErrorConstants.noErrorCode) {
            return "HTTP \(error.httpStatusCode)"
        }else {
            return "\(error.code)"
        }
    }()
    let label : String =  {
        if (error.domain == Constants.Error.apiErrorDomainOAuthUnauthorized) {
            return "Oauth failed - highest token : \(OAuthToken.oAuthTokenWithHighestScopeInStorage()?.debugDescription) "
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