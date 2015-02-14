//
//  OnboardingViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 27.01.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit



class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    
    // Backgrounds
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var bgMaskImageView: UIImageView!
    @IBOutlet var bgParallaxImageView: UIImageView!
    // First page elements
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var welcomeLabel: UILabel!
    // AnimationViews
    var firstAnimationView: DeviceView!
    var secondAnimationView: LockView!
    var thirdAnimationView: ReceiptView!
    // ParallaxRates
    let backgroundParallaxRate:CGFloat = 0.5 // 0.4 for ipad
    let mountainParallaxRate: CGFloat = 0.57 // 0.45 for ipad
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var getStartedButton: UIButton!
    @IBOutlet var pageControll: UIPageControl!
    
    var buttonInitialPostionY:CGFloat = 0
    var buttonEndPositionY:CGFloat = 0
    var logoInitialPositionY:CGFloat = 0
    var welcomeLabelInitialPositionY:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let pageSize = view.frame.size
        let numOfPages:CGFloat = 5
        scrollView.delegate = self
        scrollView.contentSize = CGSizeMake(pageSize.width * numOfPages, pageSize.height)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Setup animation views
        setupAnimationViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        buttonInitialPostionY = getStartedButton.center.y
        logoInitialPositionY = logoImageView.center.y
        welcomeLabelInitialPositionY = welcomeLabel.center.y
        panBackground()
    }

    func setupAnimationViews(){
        
        let pageCenter = scrollView.frame.midY - (view.frame.width/4)
        let viewOffset = scrollView.frame.width
        let viewSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height)
        
        firstAnimationView = DeviceView(frame: CGRectMake(viewOffset, 0, viewSize.width, viewSize.height))
        scrollView.addSubview(firstAnimationView!)
        
        let firstAnimationText = UILabel(frame: CGRectMake(firstAnimationView.frame.origin.x, firstAnimationView.frame.origin.y + viewSize.width/3 , viewSize.width/2, viewSize.height/2))
        firstAnimationText.center = CGPointMake(firstAnimationView.center.x, firstAnimationText.center.y)
        firstAnimationText.textColor = UIColor.blackColor()
        firstAnimationText.textAlignment = .Center
        firstAnimationText.numberOfLines = 2
        firstAnimationText.text = "Ha med deg\npostkassen din overalt"
        scrollView.addSubview(firstAnimationText)
        
        secondAnimationView = LockView(frame: CGRectMake(viewOffset*2, 0, viewSize.width, viewSize.height))
        scrollView.addSubview(secondAnimationView!)
        secondAnimationView.constraints()
        
        let secondAnimationText = UILabel(frame: CGRectMake(secondAnimationView.frame.origin.x, secondAnimationView.frame.origin.y + viewSize.width/3 , viewSize.width/2, viewSize.height/2))
        secondAnimationText.center = CGPointMake(secondAnimationView.center.x, secondAnimationText.center.y)
        secondAnimationText.textColor = UIColor.blackColor()
        secondAnimationText.textAlignment = .Center
        secondAnimationText.numberOfLines = 2
        secondAnimationText.text = "Trygg oppbevaring\nav viktige dokumenter"
        scrollView.addSubview(secondAnimationText)
        
        thirdAnimationView = ReceiptView(frame: CGRectMake(viewOffset*3, 0, viewSize.width, viewSize.height))
        scrollView.addSubview(thirdAnimationView!)
        
        let thirdAnimationText = UILabel(frame: CGRectMake(thirdAnimationView.frame.origin.x, thirdAnimationView.frame.origin.y + viewSize.width/3 , viewSize.width/2, viewSize.height/2))
        thirdAnimationText.center = CGPointMake(thirdAnimationView.center.x, thirdAnimationText.center.y)
        thirdAnimationText.textColor = UIColor.blackColor()
        thirdAnimationText.textAlignment = .Center
        thirdAnimationText.numberOfLines = 2
        thirdAnimationText.text = "Full kontroll med\nelektroniske kvittering"
        scrollView.addSubview(thirdAnimationText)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        panBackground()
        updateAnimationViewProgress()
        pageControll.currentPage = scrollView.currentPage
    }
    
    func updateAnimationViewProgress(){
        
        let progress = scrollView.pageProgressInPercentage
        
        switch progress{
        case -1.0...1.0:
            firstAnimationView.progress =  progress
            logoImageView.center.y = logoInitialPositionY + scrollView.contentOffset.x
            welcomeLabel.center.y = welcomeLabelInitialPositionY + scrollView.contentOffset.x
            logoImageView.alpha = 1 - progress
            logoImageView.hidden = false
            welcomeLabel.hidden = false
        case 1.0...2.0:
            secondAnimationView.progress =  progress - 1
            firstAnimationView.progress = 2 - progress
        case 2.0...3.0:
            thirdAnimationView.progress =  progress - 2
            secondAnimationView.progress = 3 - progress
        case 3.0...4.0:
            thirdAnimationView.progress = 4 - progress
            // get a startpoint where x is zero when on page 4, increasing the content offsett will give value from 0 to the size of one frame.width
            let startPoint = scrollView.contentOffset.x - (scrollView.frame.width * 3)
            // Then we use this translated x offset to increase/decreace the y position of the button
            let translatedXPostitionToY = buttonInitialPostionY - startPoint
            // stop decreasing y when welcome label reaches the middle of the screen
            if startPoint < scrollView.frame.height / 2 {
                getStartedButton.center.y =  translatedXPostitionToY
                buttonEndPositionY = getStartedButton.center.y
            }
            pageControll.alpha = (4 - progress)
            logoImageView.hidden = true
            welcomeLabel.hidden = true
        case 4.0...5.0:
            // get a startpoint where x is zero when on page 4
            let startPoint = scrollView.contentOffset.x - (scrollView.frame.width * 4)
            // If the user over scrolls the scrollview in x, move the button equally in y
            getStartedButton.center.y = buttonEndPositionY - startPoint
        default: break
        }
    }
    
    func panBackground(){
        let translatedOffsetX = -(scrollView.contentOffset.x + scrollView.scrollableEdgeOffset)
        bgImageView.frame.origin.x = translatedOffsetX * backgroundParallaxRate
        bgMaskImageView.frame.origin.x = bgImageView.frame.origin.x
        bgParallaxImageView.frame.origin.x = translatedOffsetX * mountainParallaxRate
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        let device = UIDevice.currentDevice().userInterfaceIdiom
        switch device{
        case .Phone: return UIInterfaceOrientation.Portrait.rawValue
        case .Pad: return UIInterfaceOrientation.LandscapeLeft.rawValue
        default: return UIInterfaceOrientation.Portrait.rawValue
        }
    }
    
}

