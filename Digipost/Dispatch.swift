//
//  dispatch.swift
//  BoligLogg
//
//  Created by Håkon Bogen on 12/01/15.
//  Copyright (c) 2015 Shortcut AS. All rights reserved.
//

import Foundation

func dispatch(#after: NSTimeInterval, closure: dispatch_block_t) {
    dispatch(after: after, closure: closure)
}

func dispatch(#after: NSTimeInterval, queue: dispatch_queue_t = dispatch_get_main_queue(), #closure: dispatch_block_t) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(after) * Int64(NSEC_PER_SEC))
    dispatch_after(time, dispatch_get_main_queue(), closure)
}
