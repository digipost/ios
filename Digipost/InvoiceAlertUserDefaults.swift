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

import Foundation

@objc class InvoiceAlertUserDefaults: NSObject{
    
    static let hideInvoiceAlert = "hideInvoiceAlert";
    
    @objc static func resetInvoiceAlertModalChoice(){
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: hideInvoiceAlert)
    }
    
    @objc static func dontShowInvoiceNotifications(){
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: hideInvoiceAlert)
    }
    
    @objc static func shouldShowInvoiceNotification() -> Bool{
        let defaults = UserDefaults.standard
        return !defaults.bool(forKey: hideInvoiceAlert)
    }
}
