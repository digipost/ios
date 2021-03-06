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

class UploadMenuViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var menuDataSource = UploadMenuDataSource()
    
    
    lazy var uploadImageController = UploadImageController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = menuDataSource
        tableView.delegate = self
        tableView.reloadData()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        navigationItem.title = NSLocalizedString("upload image Controller title", comment: "Upload")
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            uploadImageController.showCameraCaptureInViewController(self)
        case 1:
            uploadImageController.showPhotoLibraryPickerInViewController(self)
        default:
            assert(false)
        }
    }
}
