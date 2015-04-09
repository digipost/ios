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
}

func track(#error: APIError) {
    let tracker = GAI.sharedInstance().defaultTracker
    let dictionary = GAIDictionaryBuilder.createEventWithCategory(GoogleAnalyticsConstants.errorCategory, action: "\(error.code)", label: error.description, value: nil).build()
    tracker.send(dictionary)
}