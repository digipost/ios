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
    @IBOutlet var animationMockView: UIView!
    @IBOutlet var animationMockLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var getStartedButton: UIButton!
    @IBOutlet var pageControll: UIPageControl!
    
    var buttonInitialPostionY:CGFloat = 0
    var buttonEndPositionY:CGFloat = 0
    var logoInitialPositionY:CGFloat = 0
    var welcomeLabelInitialPositionY:CGFloat = 0
    
    // ParallaxRates
    var backgroundParallaxSpeed:CGFloat!
    var mountainParallaxSpeed: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let pageSize = view.frame.size
        let numOfPages:CGFloat = 5
        scrollView.delegate = self
        scrollView.contentSize = CGSizeMake(pageSize.width * numOfPages, pageSize.height)
        
        // Set parallax speed depending on device
        let device = UIDevice.currentDevice().userInterfaceIdiom
        switch device {
        case .Phone:
            backgroundParallaxSpeed = 0.5
            mountainParallaxSpeed = 0.57
            println("iPhone")
        case .Pad:
            backgroundParallaxSpeed = 0.1
            mountainParallaxSpeed = 0.13
            println("iPad")
        default: break
        }
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

    func setupAnimationViews() {
        
        let pageCenter = animationMockView.center
        let viewOffset = scrollView.frame.width
        let viewSize = animationMockView.frame.size
        
        firstAnimationView = DeviceView(frame: animationMockView.frame)
        firstAnimationView.center.x = animationMockView.center.x + viewOffset
        scrollView.addSubview(firstAnimationView!)
        
        let firstAnimationText = UILabel(frame: animationMockLabel.frame)
        firstAnimationText.center.x = animationMockLabel.center.x + viewOffset
        firstAnimationText.textColor = UIColor.blackColor()
        firstAnimationText.textAlignment = .Center
        firstAnimationText.numberOfLines = 2
        firstAnimationText.text = "Ha med deg\npostkassen din overalt" // TODO: Localization
        scrollView.addSubview(firstAnimationText)
        
        secondAnimationView = LockView(frame: animationMockView.frame)
        secondAnimationView.center.x = animationMockView.center.x + viewOffset * 2
        scrollView.addSubview(secondAnimationView!)
        
        let secondAnimationText = UILabel(frame: animationMockLabel.frame)
        secondAnimationText.center.x = animationMockLabel.center.x + viewOffset * 2
        secondAnimationText.textColor = UIColor.blackColor()
        secondAnimationText.textAlignment = .Center
        secondAnimationText.numberOfLines = 2
        secondAnimationText.text = "Trygg oppbevaring\nav viktige dokumenter" // TODO: Localization
        scrollView.addSubview(secondAnimationText)
        
        thirdAnimationView = ReceiptView(frame: animationMockView.frame)
        thirdAnimationView.center.x = animationMockView.center.x + viewOffset * 3
        scrollView.addSubview(thirdAnimationView!)
        
        let thirdAnimationText = UILabel(frame: animationMockLabel.frame)
        thirdAnimationText.center.x = animationMockLabel.center.x + viewOffset * 3
        thirdAnimationText.textColor = UIColor.blackColor()
        thirdAnimationText.textAlignment = .Center
        thirdAnimationText.numberOfLines = 2
        thirdAnimationText.text = "Full kontroll med\nelektroniske kvitteringer" // TODO: Localization
        scrollView.addSubview(thirdAnimationText)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        panBackground()
        updateAnimationViewProgress()
        pageControll.currentPage = scrollView.currentPage
    }
    
    func updateAnimationViewProgress() {
        
        let progress = scrollView.pageProgressInPercentage
        switch progress {
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
            let startPointX = scrollView.contentOffset.x - (scrollView.frame.width * 3)
            // Then we use this translated x offset to increase/decreace the y position of the button
            let translatedXPostitionToY = buttonInitialPostionY - startPointX
            // stop decreasing y when welcome label reaches the middle of the screen
            if startPointX < scrollView.frame.height / 2 {
                getStartedButton.center.y =  translatedXPostitionToY
                buttonEndPositionY = getStartedButton.center.y
            }
            pageControll.alpha = (4 - progress)
            logoImageView.hidden = true
            welcomeLabel.hidden = true
        case 4.0...5.0:
            // get a startpoint where x is zero when on page 5
            let startPointX = scrollView.contentOffset.x - (scrollView.frame.width * 4)
            // If the user over scrolls the scrollview in x, move the button equally in y
            getStartedButton.center.y = buttonEndPositionY - startPointX
        default: break
        }
    }
    
    func panBackground() {
        let translatedOffsetX = -(scrollView.contentOffset.x + scrollView.scrollableEdgeOffset)
        bgImageView.frame.origin.x = translatedOffsetX * backgroundParallaxSpeed
        bgMaskImageView.frame.origin.x = bgImageView.frame.origin.x
        bgParallaxImageView.frame.origin.x = translatedOffsetX * mountainParallaxSpeed
    }
    
//    override func shouldAutorotate() -> Bool {
//        return false
//    }
//    
//    override func supportedInterfaceOrientations() -> Int {
//        
//        let device = UIDevice.currentDevice().userInterfaceIdiom
//        switch device {
//        case .Phone: return UIInterfaceOrientation.Portrait.rawValue
//        case .Pad: return UIInterfaceOrientation.LandscapeRight.rawValue
//        default: return UIInterfaceOrientation.Portrait.rawValue
//        }
//    }
    
}

