//
//  NewFeaturesViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 16.02.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

struct Feature {
    var imageName:String
    var featureText:String
    init(imageName: String, featureText:String) {
        self.imageName = imageName
        self.featureText = featureText
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
    var features = [Feature]()
    var hasSetUpFeatures = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let device = UIDevice.currentDevice().userInterfaceIdiom
        switch device {
        case .Phone:
            configureIphone()
            deviceFrameImageView.image = UIImage(named: "newFeatures-phone")
            println("iPhone")
        case .Pad:
            configureIpad()
            println("iPad")
        default: break
        }
        
        doneBarButton.title = NSLocalizedString("new feature barbutton title", comment: "bar button title")
        navBar.title = NSLocalizedString("new feature navbar title", comment: "nav bar title")
        scrollView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetUpFeatures{
            setupNewFeatures()
            hasSetUpFeatures = true
        }
    }
    
    func configureIphone() {
        
        // Set up new features
        features.append(Feature(imageName: "first", featureText:  NSLocalizedString("new feature share", comment: "text for share feature")))
        features.append(Feature(imageName: "vise_mapper", featureText:  NSLocalizedString("new feature folders", comment: "text for folders feature")))
        features.append(Feature(imageName: "last", featureText:  NSLocalizedString("new feature archive", comment: "text for archive feature")))
    }
    
    func configureIpad() {
    
        // Set up new features
        features.append(Feature(imageName: "ipad1", featureText:  NSLocalizedString("new feature share", comment: "text for share feature")))
        features.append(Feature(imageName: "ipad2", featureText:  NSLocalizedString("new feature folders", comment: "text for folders feature")))
        features.append(Feature(imageName: "ipad3", featureText:  NSLocalizedString("new feature archive", comment: "text for archive feature")))
    }
    
    func setupNewFeatures() {
        
        let numOfFeatures = features.count
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
        
        var deviceFont:UIFont {
            get {
                // If iPad
                if view.bounds.width >= 768.0 {
                    return UIFont(name: "HelveticaNeue-Light", size: 40)!
                } else {
                    return UIFont(name: "HelveticaNeue", size: 17)!
                }
            }
        }
        
        for feature in features {
            // Setup feature imageView
            
            let imageViewFrame = CGRectMake(imageOffset, 0.0, scrollView.frame.size.width, scrollView.frame.size.height+frameHeightConstant)
            let imageView = UIImageView(frame: imageViewFrame)
            let image = UIImage(named: feature.imageName)
            imageView.image = image
            imageView.contentMode = UIViewContentMode.ScaleToFill
            scrollView.addSubview(imageView)
            
            // Setup feature label
            let frame = CGRectMake(labelOffset, 0.0, view.frame.width, labelViewContainer.frame.height)
            let label = UILabel(frame: frame)
            label.text = feature.featureText
            label.font = deviceFont

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
        
        var storyboard:UIStoryboard!
        let device = UIDevice.currentDevice().userInterfaceIdiom
        switch device {
        case .Phone:
            storyboard = UIStoryboard(name: "Main_iPhone", bundle: nil)
        case .Pad:
            storyboard = UIStoryboard(name: "Main_iPad", bundle: nil)
        default: break
        }
        
        let viewcontroller:UIViewController = storyboard.instantiateInitialViewController() as UIViewController
        self.presentViewController(viewcontroller, animated: false) { () -> Void in
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
