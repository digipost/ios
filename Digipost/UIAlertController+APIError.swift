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

extension UIAlertController {
    @objc class func presentAlertControllerWithAPIError(_ apiError: APIError, presentingViewController: UIViewController) {
        presentAlertControllerWithAPIError(apiError, presentingViewController: presentingViewController, didTapOkClosure: nil)
    }
    
    class func presentAlertControllerWithAPIError(_ apiError: APIError, presentingViewController: UIViewController, didTapOkClosure: (() -> Void)? = nil) {
        if apiError.shouldBeShownToUser {
            let alertController = UIAlertController(title: apiError.alertTitle, message: apiError.altertMessage, preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in
                didTapOkClosure?()
            })

            alertController.addAction(okAction)

            if presentingViewController.navigationController?.topViewController == presentingViewController && presentingViewController.presentedViewController == nil {
                presentingViewController.present(alertController, animated: true, completion:nil)
                Logger.dpostLogWarning("A web request failed and returned a an API error with code: \(apiError.code) , internal Digipost error-code: \(String(describing: apiError.digipostErrorCode))", location: "Unknown", UI: "User got an error popup with title \(apiError.alertTitle)", cause: "Cause can be translated from the error code")
            }
        }
    }

    class func forcedLogoutAlertController() -> UIAlertController {
        let alertController = UIAlertController(title:NSLocalizedString("Oauth login error title", comment:""), message: NSLocalizedString("Oauth login error message", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(alertAction)
        return alertController
    }
}
