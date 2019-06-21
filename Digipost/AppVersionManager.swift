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

import LUKeychainAccess

@objc class AppVersionManager: NSObject{
    
    static let APP_VERSIONS_IN_KEYCHAIN = "AppVersionsInKeychain"
    static let APP_VERSIONS_IN_USER_DEFAULTS = "AppVersionsInUserDefaults"
    
    @objc static func deleteOldTokensIfReinstall() {
        
        if reInstall() {
            OAuthToken.removeToken()
        }
        
        updateAppVersionsInUserDefaults()
        updateAppVersionsInKeychain()
    }
    
    class func reInstall() -> Bool {        
        return oldVersionsFoundInKeychain() && !oldVersionsFoundInUserDefaults()
    }
    
    //UserDefault - App Versions
    
    class func oldVersionsFoundInUserDefaults() -> Bool {
        return getAppVersionsFromUserDefaults() != nil
    }
    
    class func getAppVersionsFromUserDefaults() -> [String]? {
        return UserDefaults.standard.object(forKey: APP_VERSIONS_IN_USER_DEFAULTS) as? [String]
    }
    
    class func updateAppVersionsInUserDefaults() {        
        let appVersions = getCurrentAppVersions(oldAppVersions: getAppVersionsFromUserDefaults())
        UserDefaults.standard.set(appVersions, forKey: APP_VERSIONS_IN_USER_DEFAULTS)
    }
    
    //Keychain - App Versions
    
    class func oldVersionsFoundInKeychain() -> Bool {
        return getAppVersionsFromKeychain() != nil
    }
    
    class func getAppVersionsFromKeychain() -> [String]? {
        let keychainAccess = LUKeychainAccess()
        return keychainAccess.object(forKey: APP_VERSIONS_IN_KEYCHAIN) as? [String]
    }
    
    class func updateAppVersionsInKeychain() {        
        let appVersions = getCurrentAppVersions(oldAppVersions: getAppVersionsFromKeychain())
        let keychainAccess = LUKeychainAccess()
        keychainAccess.setObject(appVersions, forKey: APP_VERSIONS_IN_KEYCHAIN)
    }
    
    //Common
    
    class func getAppVersion() -> String? {
        let dictionary = Bundle.main.infoDictionary!
        return dictionary["CFBundleVersion"] as? String
    }
    
    class func getCurrentAppVersions( oldAppVersions: [String]?) -> [String] {
        
        var appVersions : [String] = []
        
        if let existing = oldAppVersions {
            appVersions = existing
        }
        
        if let currentAppVersion = getAppVersion() {
            guard currentAppVersion != appVersions.last else {return appVersions}
            
            appVersions.append(currentAppVersion)
        }
        
        return appVersions
    }
    
    class func clearUserDefaultVersions() {
        UserDefaults.standard.set(nil, forKey: APP_VERSIONS_IN_USER_DEFAULTS)
        UserDefaults.standard.synchronize()
    }
    
    class func clearKeyChainVersions() {
        let keychainAccess = LUKeychainAccess()
        keychainAccess.setObject(nil, forKey: APP_VERSIONS_IN_KEYCHAIN)
    }
}
