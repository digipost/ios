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

@objc
protocol NewFeaturesViewControllerDelegate {
    func newFeaturesViewControllerDidDismiss(_ newFeaturesViewController: NewFeaturesViewController)
}

extension UIFont{
    class func fonstSizeForCurrentDevice() -> UIFont{
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return UIFont(name: "HelveticaNeue-Light", size: 30)!
        case .phone:
            return UIFont(name: "HelveticaNeue", size: 17)!
        case .unspecified:
            return UIFont(name: "HelveticaNeue", size: 17)!
        default:
            return UIFont(name: "HelveticaNeue", size: 17)!
        }
    }
}

class NewFeaturesViewController: GAITrackedViewController, UIScrollViewDelegate {

    private lazy var __once: () = {
            self.setupNewFeatures()
        }()

    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet var doneBarButton: UIBarButtonItem!
    @IBOutlet var deviceFrameImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var labelViewContainer: UIView!
    var labelContainer:UIView!
    var imageNames = [String]()
    var labelTexts = [String]()
    var whatsNewGuideItems = [WhatsNewGuideItem]()
    var setupFeatures_dispatch_token: Int = 0
    weak var delegate : NewFeaturesViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "NewFeatures"
        
        whatsNewGuideItems = Guide.whatsNewGuideItems()
        let device = UIDevice.current.userInterfaceIdiom
        switch device {
        case .phone:
            deviceFrameImageView.image = UIImage(named: "newFeatures-phone")
        default: break
        }
        
        doneBarButton.title = NSLocalizedString("new feature barbutton title", comment: "bar button title")
        navBar.title = NSLocalizedString("new feature navbar title", comment: "nav bar title")
        scrollView.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = self.__once
    }
    
    func setupNewFeatures() {
        
        let numOfFeatures = whatsNewGuideItems.count
        let containerWidth:CGFloat = view.frame.width * CGFloat(numOfFeatures)
        pageControl.numberOfPages = numOfFeatures
        labelContainer = UIView(frame: CGRect(x: labelViewContainer.frame.origin.x, y: labelViewContainer.frame.origin.y, width: containerWidth, height: labelViewContainer.frame.height))
        var imageOffset: CGFloat = 0.0
        var labelOffset: CGFloat = 0.0
        
        var frameHeightConstant:CGFloat {
            // If iphone 4
            if view.bounds.height <= 480 {
                return 50
            } else {
                return 0
            }
        }
        
        for whatsNewGuideItem in whatsNewGuideItems {
            // Setup feature imageView
            
            let imageViewFrame = CGRect(x: imageOffset, y: 0.0, width: scrollView.frame.size.width, height: scrollView.frame.size.height+frameHeightConstant)
            let imageView = UIImageView(frame: imageViewFrame)
        
            imageView.image = whatsNewGuideItem.image
            imageView.contentMode = UIViewContentMode.scaleToFill
            scrollView.addSubview(imageView)
            
            // Setup feature label
            let frame = CGRect(x: labelOffset, y: 0.0, width: view.frame.width, height: labelViewContainer.frame.height)
            let label = UILabel(frame: frame)
            label.text = whatsNewGuideItem.text
            label.font = UIFont.fonstSizeForCurrentDevice()

            label.numberOfLines = 2
            label.textColor = UIColor.white
            label.textAlignment = .center
            labelContainer.addSubview(label)
            
            imageOffset += imageView.frame.size.width
            labelOffset += frame.size.width
        }
        
        view.addSubview(labelContainer)
        scrollView.contentSize = CGSize(width: imageOffset, height: scrollView.frame.size.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = scrollView.currentPage
        scrollLabels()
    }
    
    func scrollLabels() {
        // Translate the size difference from the scrollview to the label container
        let translationRate: CGFloat =  self.view.frame.width / scrollView.frame.width
        // Scroll the label container
        labelContainer.frame.origin.x = -scrollView.contentOffset.x * translationRate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func doneButtonAction(_ sender: AnyObject) {
        
        Guide.setWhatsNewFeaturesHasBeenWatchedForThisVersion()
       
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            self.navigationController?.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: kRefreshDocumentsContentNotificationName), object: nil)
        } else {
            self.delegate?.newFeaturesViewControllerDidDismiss(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
