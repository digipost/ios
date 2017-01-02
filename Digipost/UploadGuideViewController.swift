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

class UploadGuideViewController: UIViewController {
    @IBOutlet weak var uploadImage: UIImageView!
    
    @IBOutlet weak var horizontalUploadImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("upload guide navgationtiem title", comment: "title for navigation item on upload")
        self.uploadImage.accessibilityLabel = NSLocalizedString("upload guide image accessability hint", comment: "when user taps on image, this text should be read")
        self.uploadImage.isAccessibilityElement = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "kFolderViewControllerNavigatedInList"), object: nil, queue: nil) { note in
            self.dismiss(animated: false, completion: nil)
        }
        if (UIDevice.current.userInterfaceIdiom == .pad ){
            uploadImage.image = UIImage.localizedImage(UIInterfaceOrientation.portrait)
        } else {
            uploadImage.image = UIImage.localizedImage(UIApplication.shared.statusBarOrientation)
            self.setImageForOrientation(UIApplication.shared.statusBarOrientation)
        }
        view.updateConstraints()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "kFolderViewControllerNavigatedInList"), object: nil)
    }

    func setImageForOrientation(_ forOrientation: UIInterfaceOrientation){
        if let horizontalImage = horizontalUploadImage {
            if (UIInterfaceOrientationIsLandscape(forOrientation)){
                horizontalImage.isHidden = false
            } else {
                horizontalImage.isHidden = true
            }
        }
        if let verticalImage = uploadImage {
            if (UIInterfaceOrientationIsLandscape(forOrientation)){
                verticalImage.isHidden = true
            } else {
                verticalImage.isHidden = false
            }
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if (UIDevice.current.userInterfaceIdiom == .pad ){
            uploadImage.image = UIImage.localizedImage(UIInterfaceOrientation.portrait)
        }else {
            uploadImage.image = UIImage.localizedImage(toInterfaceOrientation)
            horizontalUploadImage.image = UIImage.localizedImage(toInterfaceOrientation)
            setImageForOrientation(toInterfaceOrientation)
            
        }
    }
}
