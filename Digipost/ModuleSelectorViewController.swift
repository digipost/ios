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

protocol ModuleSelectorViewControllerDelegate{
    func moduleSelectorViewController(_ moduleSelectorViewController: ModuleSelectorViewController, didSelectModule module: ComposerModule)
    func moduleSelectorViewControllerWasDismissed(_ moduleSelectorViewController: ModuleSelectorViewController)
}

class ModuleSelectorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    var textAttributes : [TextAttribute]

    required init(coder aDecoder: NSCoder) {
        self.textAttributes = [TextAttribute]()
        super.init(coder: aDecoder)!
    }

    class func setup(textAttributes: [TextAttribute]) -> ModuleSelectorViewController {
        let moduleSelectorViewController = UIStoryboard(name: "DocumentComposer", bundle: Bundle.main).instantiateViewController(withIdentifier: "moduleSelectorViewController") as! ModuleSelectorViewController
        moduleSelectorViewController.textAttributes = textAttributes
        return moduleSelectorViewController
    }

    var imagePicker = UIImagePickerController()
    var delegate: ModuleSelectorViewControllerDelegate?
    @IBOutlet weak var moduleSelectorView: UIView!
    @IBOutlet weak var moduleSelectorViewTitle: UILabel!

    let moduleTypeStrings = [NSLocalizedString("normal text table view cell title", comment: "Title for table view cell"),
                            NSLocalizedString("image table view cell title", comment: "Title for table view cell")]
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let tblView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView?.isHidden = true
        tableView.isScrollEnabled = false
        tableView.rowHeight = 50
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.delegate?.moduleSelectorViewControllerWasDismissed(self)
    }
    
    func addTextModule(_ textStyle: String){
        let selectedModule = TextComposerModule(moduleWithFont: UIFont.preferredFont(forTextStyle: UIFontTextStyle(rawValue: textStyle)))
        delegate?.moduleSelectorViewController(self, didSelectModule: selectedModule)
    }
    
    func addImage() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        let selectedModule = ImageComposerModule(image: image)
        dismiss(animated: true, completion: nil)
        delegate?.moduleSelectorViewController(self, didSelectModule: selectedModule)
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let module : ComposerModule? = {
            switch indexPath.row {
            case 0:
                return TextComposerModule.paragraphModule()
            case 1:
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
                    self.imagePicker.delegate = self
                    self.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
                    self.imagePicker.allowsEditing = true
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
                break
            case 2:
                fallthrough
            case 3:
                fallthrough
            default:
                break;
            }
            return nil
        }()
        if let selectedModule = module {
            delegate?.moduleSelectorViewController(self, didSelectModule: selectedModule)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moduleTypeStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "moduleCell", for: indexPath)
        cell.textLabel?.text = moduleTypeStrings[indexPath.row]
        return cell
    }
}
