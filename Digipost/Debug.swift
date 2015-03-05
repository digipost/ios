//
//  Debug.swift
//  Digipost
//
//  Created by Håkon Bogen on 05/03/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

func debugPrintln(message: String, function: String = __FUNCTION__) {
    #if DEBUGLOG
      println("DEBUG: \(function): \(message)")
    #endif
}

func debugIfNil(object: AnyObject?, message: String, function : String = __FUNCTION__ ) {
    #if DEBUGLOG
        if object == nil {
        println("DEBUG: Excpected non-nil! \(function): \(message)")
        }
    #endif
}