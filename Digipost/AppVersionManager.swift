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
    static let APP_VERSIONS_FROM_IN_DEFAULTS = "AppVersionsInUserDefaults"
    
    static func deleteOldTokensIfReinstall() {
        
        if reInstall() {
            clearTokens()
        }
        
        updateAppVersionsInUserDefaults()
        updateAppVersionsInKeychain()
    }
    
    class func reInstall() -> Bool {        
        return oldVersionsFoundInKeychain() && !oldVersionsFoundInUserDefaults()
    }
    
    class func clearTokens() {
        OAuthToken.removeAllTokens()
        OAuthToken.removeRefreshToken()
    }
    
    class func getAppVersion() -> String? {
        let dictionary = Bundle.main.infoDictionary!
        return dictionary["CFBundleVersion"] as? String
    }
    
    //UserDefault - App Versions
    
    class func oldVersionsFoundInUserDefaults() -> Bool {
        return getAppVersionsFromUserDefaults() != nil
    }
    
    class func getAppVersionsFromUserDefaults() -> [String]? {
        return UserDefaults.standard.object(forKey: APP_VERSIONS_FROM_IN_DEFAULTS) as? [String]
    }
    
    class func updateAppVersionsInUserDefaults() {        
        if let currentAppVersion = getAppVersion() {
            
            var appVersions : [String] = [] 
            
            if let existingAppVersions = getAppVersionsFromUserDefaults() {
                appVersions = existingAppVersions
            }
            
            guard currentAppVersion != appVersions.last else {return}
            appVersions.append(currentAppVersion)
            
            UserDefaults.standard.set(appVersions, forKey: APP_VERSIONS_FROM_IN_DEFAULTS)
        }
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
        if let currentAppVersion = getAppVersion() {
            
            var appVersions : [String] = [] 
            
            if let existingAppVersions = getAppVersionsFromKeychain() {
                appVersions = existingAppVersions
            }
            
            guard currentAppVersion != appVersions.last else {return}
            appVersions.append(currentAppVersion)
            
            let keychainAccess = LUKeychainAccess()
            keychainAccess.setObject(appVersions, forKey: APP_VERSIONS_IN_KEYCHAIN)
        }
    }
}