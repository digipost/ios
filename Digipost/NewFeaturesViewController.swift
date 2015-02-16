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

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var labelViewContainer: UIView!
    var labelContainer:UIView!
    var imageNames = [String]()
    var labelTexts = [String]()
    var features = [Feature]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        configureNewFeatures()
    }
    
    func configureNewFeatures() {
        
        // Set up new features
        features.append(Feature(imageName: "last", featureText: "Del postkassen din med\nandre i familien"))
        features.append(Feature(imageName: "vise_mapper", featureText: "Bruk mapper for å\norganisere dine eposter"))
        features.append(Feature(imageName: "last", featureText: "Et helt eget arkiv\ndu kan fylle opp"))
    }
    
    func setupNewFeatures() {
        
        let numOfFeatures = features.count
        let containerWidth:CGFloat = view.frame.width * CGFloat(numOfFeatures)
        labelContainer = UIView(frame: CGRectMake(labelViewContainer.frame.origin.x, labelViewContainer.frame.origin.y, containerWidth, labelViewContainer.frame.height))
        var imageOffset: CGFloat = 0.0
        var labelOffset: CGFloat = 0.0
        
        for feature in features {
            // Setup feature imageView
            let imageViewFrame = CGRectMake(imageOffset, 0.0, scrollView.frame.size.width, scrollView.frame.size.height)
            let imageView = UIImageView(frame: imageViewFrame)
            let image = UIImage(named: feature.imageName)
            imageView.image = image
            imageView.contentMode = UIViewContentMode.ScaleToFill
            scrollView.addSubview(imageView)
            
            // Setup feature label
            let frame = CGRectMake(labelOffset, 0.0, view.frame.width, labelViewContainer.frame.height)
            let label = UILabel(frame: frame)
            label.text = feature.featureText
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
    
    override func viewDidLayoutSubviews() {
        setupNewFeatures()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
