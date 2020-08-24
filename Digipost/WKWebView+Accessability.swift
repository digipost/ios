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

import WebKit

extension WKWebKit {
    
    @objc func setAccessabilityLabelForFileType(_ filetype: String?){
        if let actualFileType = filetype as String? {
            
            if actualFileType == "jpg" || actualFileType == "png" {
                accessibilityLabel = NSLocalizedString("accessability label webview is image", comment: "when webview is image read this text")
                accessibilityHint = NSLocalizedString("accessability label webview is image", comment: "when webview is image read this text")
                accessibilityFrame = CGRect(x: 0, y: 0, width: 100, height: 100);
            }
        }
    }
    
}
