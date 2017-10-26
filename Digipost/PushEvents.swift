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

import UserNotifications

@objc class PushEvents: NSObject {
    
    class func reportActivationState() {
        let activationState = getActivationState()
        GAEvents.event(category: "push", action: "status", label: activationState, value: nil)
    }
    
    class func getActivationState() -> String {
        let semaphore = DispatchSemaphore(value: 0)
        var label = "undetermined"
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus.rawValue == UNAuthorizationStatus.authorized.rawValue {
                    label = "authorized"
                }else if settings.authorizationStatus.rawValue == UNAuthorizationStatus.denied.rawValue {
                    label = "denied"
                }
                semaphore.signal()
            }
        } else {
            if let settings = UIApplication.shared.currentUserNotificationSettings {
                if UIApplication.shared.isRegisteredForRemoteNotifications {
                    if settings.types.rawValue != 0{
                        label = "authorized"
                    }else {
                        label = "denied"
                    }
                }
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        return label
    }
}
