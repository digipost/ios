//
//  NewFeaturesViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 16.02.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit



extension UIFont{
    class func fonstSizeForCurrentDevice() -> UIFont{
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Pad:
            return UIFont(name: "HelveticaNeue-Light", size: 40)!
        case .Phone:
            return UIFont(name: "HelveticaNeue", size: 17)!
        case .Unspecified:
            return UIFont(name: "HelveticaNeue", size: 17)!
        }
    }
}

class NewFeaturesViewController: UIViewController, UIScrollViewDelegate {

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
    var setupFeatures_dispatch_token: dispatch_once_t = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        whatsNewGuideItems = Guide.whatsNewGuideItems()
        let device = UIDevice.currentDevice().userInterfaceIdiom
        switch device {
        case .Phone:
            deviceFrameImageView.image = UIImage(named: "newFeatures-phone")
        default: break
        }
        
        doneBarButton.title = NSLocalizedString("new feature barbutton title", comment: "bar button title")
        navBar.title = NSLocalizedString("new feature navbar title", comment: "nav bar title")
        scrollView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        dispatch_once(&setupFeatures_dispatch_token){
            self.setupNewFeatures()
        }
    }
    
    func setupNewFeatures() {
        
        let numOfFeatures = whatsNewGuideItems.count
        let containerWidth:CGFloat = view.frame.width * CGFloat(numOfFeatures)
        pageControl.numberOfPages = numOfFeatures
        labelContainer = UIView(frame: CGRectMake(labelViewContainer.frame.origin.x, labelViewContainer.frame.origin.y, containerWidth, labelViewContainer.frame.height))
        var imageOffset: CGFloat = 0.0
        var labelOffset: CGFloat = 0.0
        
        var frameHeightConstant:CGFloat {
            get {
                // If iphone 4
                if view.bounds.height <= 480 {
                    return 50
                } else {
                    return 0
                }
            }
        }
        
        for whatsNewGuideItem in whatsNewGuideItems {
            // Setup feature imageView
            
            let imageViewFrame = CGRectMake(imageOffset, 0.0, scrollView.frame.size.width, scrollView.frame.size.height+frameHeightConstant)
            let imageView = UIImageView(frame: imageViewFrame)
        
            imageView.image = whatsNewGuideItem.image
            imageView.contentMode = UIViewContentMode.ScaleToFill
            scrollView.addSubview(imageView)
            
            // Setup feature label
            let frame = CGRectMake(labelOffset, 0.0, view.frame.width, labelViewContainer.frame.height)
            let label = UILabel(frame: frame)
            label.text = whatsNewGuideItem.text
            label.font = UIFont.fonstSizeForCurrentDevice()

            label.numberOfLines = 2
            label.textColor = UIColor.whiteColor()
            label.textAlignment = .Center
            labelContainer.addSubview(label)
            
            imageOffset += imageView.frame.size.width
            labelOffset += frame.size.width
        }
        
        view.addSubview(labelContainer)
        scrollView.contentSize = CGSizeMake(imageOffset, scrollView.frame.size.height)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = scrollView.currentPage
        scrollLabels()
    }
    
    func scrollLabels() {
        // Translate the size difference from the scrollview to the label container
        let translationRate: CGFloat =  self.view.frame.width / scrollView.frame.width
        // Scroll the label container
        labelContainer.frame.origin.x = -scrollView.contentOffset.x * translationRate
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func doneButtonAction(sender: AnyObject) {
        
        Guide.setWhatsNewFeaturesHasBeenWatchedForThisVersion()
       
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            NSNotificationCenter.defaultCenter().postNotificationName(kRefreshDocumentsContentNotificationName, object: nil)
        } else {
            var storyboard = UIStoryboard.storyboardForCurrentUserInterfaceIdiom()

            if let resource: POSRootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext) {
                if resource.mailboxes.allObjects.count == 1 {
                    let viewcontroller:POSFoldersViewController = storyboard.instantiateViewControllerWithIdentifier("FoldersViewController") as POSFoldersViewController
                    self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                let viewcontroller:AccountViewController = storyboard.instantiateViewControllerWithIdentifier("accountViewController") as AccountViewController
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
