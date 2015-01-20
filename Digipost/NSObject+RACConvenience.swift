//
//  NSObject+RACConvenience.swift
//  Digipost
//
//  Created by Håkon Bogen on 19/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension NSObject {
    
    func RACSignalSubscriptionNext(#selector:Selector, fromProtocol: Protocol, subscribeNext: (racTuple: RACTuple) -> Void) {
        rac_signalForSelector(selector, fromProtocol:fromProtocol).subscribeNext { (anyObject) -> Void in
            if let racTuple = anyObject as? RACTuple {
                subscribeNext(racTuple: racTuple)
            } else {
                
            }
        }
    }
}
