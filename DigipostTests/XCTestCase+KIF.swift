//
//  XCTestCase+KIF.swift
//  Digipost
//
//  Created by Håkon Bogen on 15/04/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import KIF
import XCTest

extension XCTestCase {
    var tester: KIFUITestActor { return tester() }
    var system: KIFSystemTestActor { return system() }

    func tester(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }

    func system(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
}

extension KIFTestActor {
    func tester(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }

    func system(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
}