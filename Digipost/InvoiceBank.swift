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

class InvoiceBank{
    
    var name: String = ""
    var registrationUrl: String = ""
    var activeType1Agreement = false
    var activeType2Agreement = false
    
    var logo: String {
        get {
            return "invoice-bank-\((self.name).lowercased().removeWhitespaces())"
        }
    }
    
    init(){}
    
    init (name: String, registrationUrl: String, activeType1Agreement: Bool, activeType2Agreement: Bool) {
        self.name = name
        self.registrationUrl = registrationUrl
        self.activeType1Agreement = activeType1Agreement
        self.activeType2Agreement = activeType2Agreement
    }
    
    func haveRegistrationUrl() -> Bool {
        return registrationUrl != ""
    }
}
