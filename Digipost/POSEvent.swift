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

class POSEvent : POSMetadataObject {
    
    var subTitle = ""
    var descriptionText = ""
    var place = ""
    var streetAddress = ""
    var postalCode = ""
    var city = ""
    var address = ""
    var timeframes = [POSTimeframe]()
    
    var barcodeTitle = ""
    var barcode = ""
    var barcodeText = ""
    
    var infoTitle1 = ""
    var infoText1 = ""
    var infoTitle2 = ""
    var infoText2 = ""
    var infoTitle3 = ""
    var infoText3 = ""
    
    var linkTitle = ""
    var linkURL = ""
    
    init() {
        super.init(type: POSMetadata.TYPE.EVENT)
    }
}
