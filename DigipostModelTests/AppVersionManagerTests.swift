//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import XCTest
import LUKeychainAccess
@testable import Digipost

class AppVersionManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func clearAppVersions() {
        AppVersionManager.clearUserDefaultVersions()
        AppVersionManager.clearKeyChainVersions()
    }
    
    func simulateRun() {
        AppVersionManager.updateAppVersionsInKeychain()
        AppVersionManager.updateAppVersionsInUserDefaults()
    }
    
    func testSaveVersionInKeychain() {
        clearAppVersions()
        
        AppVersionManager.updateAppVersionsInKeychain()
        let keychain = AppVersionManager.oldVersionsFoundInKeychain()
        
        XCTAssert(keychain, "Version not found in keychain")
    }
    
    func testSaveVersionInUserDefaults() {
        clearAppVersions()
        
        AppVersionManager.updateAppVersionsInUserDefaults()
        let userdefaults = AppVersionManager.oldVersionsFoundInUserDefaults()
        
        XCTAssert(userdefaults, "Version not found in userdefaults")
    }
    
    func testClearVersions() {
        clearAppVersions()
        
        let keychain = AppVersionManager.oldVersionsFoundInKeychain()
        let userdefaults = AppVersionManager.oldVersionsFoundInKeychain()
        
        XCTAssertFalse(keychain || userdefaults, "Clear failed ")
    }
    
    func testCleanInstall() {
        clearAppVersions()
        
        let keychain = AppVersionManager.oldVersionsFoundInKeychain()
        let userdefaults = AppVersionManager.oldVersionsFoundInKeychain()
        
        XCTAssert(!keychain && !userdefaults, "Old version found!")
    }
    
    func testUpdateInstall() {
        clearAppVersions()
        
        simulateRun()
        let keychain = AppVersionManager.oldVersionsFoundInKeychain()
        let userdefaults = AppVersionManager.oldVersionsFoundInKeychain()
        
        XCTAssert(keychain && userdefaults, "No old versions found!")
    }
    
    func testReinstall() {
        clearAppVersions()
        
        AppVersionManager.updateAppVersionsInKeychain()
        let keychain = AppVersionManager.oldVersionsFoundInKeychain()
        let userdefaults = AppVersionManager.oldVersionsFoundInUserDefaults()
        
        XCTAssert(keychain && !userdefaults, "Reinstall failed")
    }
}
