//
//  OnboardingViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 27.01.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

private struct onboardingViewControllerConstants {
    static let showOnboardingLoginViewControllerSegue = "showOnboardingLoginViewControllerSegue"
}

class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    
    // Backgrounds
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var bgMaskImageView: UIImageView!
    @IBOutlet var bgParallaxImageView: UIImageView!
    
    // First page elements
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var welcomeLabel: UILabel!
    
    // AnimationViews
    var firstAnimationView: PeopleView!
    var secondAnimationView: UploadView!
    var thirdAnimationView: ReceiptView!
    @IBOutlet var animationMockView: UIView!
    var animationViewSetup_dispatch_token: dispatch_once_t = 0
    
    // Login view
    @IBOutlet var loginContainerView: UIView!
    // Login view iPhone Constraints
    @IBOutlet var loginContainerViewTopConstant: NSLayoutConstraint!
    var loginContainerViewInitialTopConstant:CGFloat!
    // Login view iPad Constraints
    @IBOutlet var loginContainerViewTopConstantIPAD: NSLayoutConstraint!
    var loginContainerViewInitialTopConstantIPAD:CGFloat!
    
    @IBOutlet var scrollView: UIScrollView!
    
    // Get started button
    @IBOutlet var getStartedButton: UIButton!
    // Get started Button iPhone Constraints
    @IBOutlet var getStartedButtonBottomConstraint: NSLayoutConstraint!
    var getStartedButtonInitialBottomConstraint:CGFloat!
    //  ConstraintsiPad Constraints
     @IBOutlet var getStartedButtonBottomConstraintIPAD: NSLayoutConstraint!
    var getStartedButtonInitialBottomConstraintIPAD:CGFloat!
    
    @IBOutlet var pageControll: UIPageControl!

    var logoInitialPositionY:CGFloat = 0
    var welcomeLabelInitialPositionY:CGFloat = 0
    
    // ParallaxRates
    var backgroundParallaxSpeed:CGFloat!
    var mountainParallaxSpeed: CGFloat!
    
    var onboardingLoginViewController : OnboardingLoginViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        let pageSize = view.frame.size
        let numOfPages:CGFloat = 5
        scrollView.delegate = self
        scrollView.contentSize = CGSizeMake(pageSize.width * numOfPages, pageSize.height)
        
        welcomeLabel.text = NSLocalizedString("onboarding welcome", comment: "welcome label")
        welcomeLabel.textColor = UIColor.digipostAnimationGrey()
        
        getStartedButton.setTitle(NSLocalizedString("onboarding button", comment: "get started button"), forState: .Normal)
        
        // Set parallax speed depending on device
        let device = UIDevice.currentDevice().userInterfaceIdiom
        switch device {
        case .Phone:
            backgroundParallaxSpeed = 0.5
            mountainParallaxSpeed = 0.57
        case .Pad:
            backgroundParallaxSpeed = 0.1
            mountainParallaxSpeed = 0.13
        default: break
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Setup animation views
        dispatch_once(&animationViewSetup_dispatch_token){
            self.setupAnimationViews()
            // Stor initial consstraint constants for button and login conatiner view
            self.storeInitialConstraints()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoInitialPositionY = logoImageView.center.y
        welcomeLabelInitialPositionY = welcomeLabel.center.y
        panBackground()
    }
    
    func setupAnimationViews() {
        
        let viewOffset = scrollView.frame.width
        let animationFrame = animationMockView.frame

        firstAnimationView = PeopleView(frame: animationFrame)
        firstAnimationView.center.x = animationMockView.center.x + viewOffset
        firstAnimationView.animationText.string = Guide.onboardingText(forIndex: 1)
        
        // NSLocalizedString("onboarding first animation", comment: "bring your\n mailbox everywhere")
        scrollView.addSubview(firstAnimationView!)
        
        
        secondAnimationView = UploadView(frame: animationFrame)
        secondAnimationView.center.x = animationMockView.center.x + viewOffset * 2
        secondAnimationView.animationText.string = Guide.onboardingText(forIndex: 2)
        scrollView.addSubview(secondAnimationView!)
        
        thirdAnimationView = ReceiptView(frame: animationFrame)
        thirdAnimationView.center.x = animationMockView.center.x + viewOffset * 3
        thirdAnimationView.animationText.string = NSLocalizedString("onboarding third animation", comment: "full control")
        scrollView.addSubview(thirdAnimationView!)
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
        case 3.0...5.0:
            thirdAnimationView.progress = 4 - progress
            // get a startpoint where x is zero when on page 4, increasing the content offsett will give value from 0 to the size of one frame.width
            let startPointX = scrollView.contentOffset.x - (scrollView.frame.width * 3)
            // Then we use this translated x offset to increase/decreace the y position of the button
            let translatedButtonConstant = getStartedButtonInitialBottomConstraint - startPointX
            // Scroll mulitpliers to increase the scroll rate of the translated startpoint
            let scrollRateMultiplier:CGFloat = self.view.frame.height <= 480 ? 1.45 : 1.72
            let scrollRateMultiplierIPAD:CGFloat = 0.7
            let translatedLoginContainerConstant = loginContainerViewInitialTopConstant - (startPointX * scrollRateMultiplier)
            let translatedLoginContainerConstantIPAD = loginContainerViewInitialTopConstantIPAD - (startPointX * scrollRateMultiplierIPAD)
            // Move button off screen bottom
            getStartedButtonBottomConstraint.constant =  translatedButtonConstant
            getStartedButtonBottomConstraintIPAD.constant = translatedButtonConstant
            getStartedButton.setNeedsUpdateConstraints()
            // Move login container up from buttom
            loginContainerViewTopConstant.constant = translatedLoginContainerConstant
            loginContainerViewTopConstantIPAD.constant = translatedLoginContainerConstantIPAD
            loginContainerView.setNeedsUpdateConstraints()
            // Fade out on leaving screen bottom
            pageControll.alpha = (4 - progress)
            getStartedButton.alpha = (4 - progress)
            logoImageView.hidden = true
            welcomeLabel.hidden = true
            
        default: break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == onboardingViewControllerConstants.showOnboardingLoginViewControllerSegue {
            onboardingLoginViewController = segue.destinationViewController as? OnboardingLoginViewController
        }
    }
    
    @IBAction func getStartedButtonAction(sender: AnyObject) {
        
        let lastPageRect = CGRectMake(0, 0, scrollView.pageSize.width*5, scrollView.pageSize.height)
        scrollView.scrollRectToVisible(lastPageRect, animated: true)

    }

    func panBackground() {
        let translatedOffsetX = -(scrollView.contentOffset.x + scrollView.scrollableEdgeOffset)
        bgImageView.frame.origin.x = translatedOffsetX * backgroundParallaxSpeed
        bgMaskImageView.frame.origin.x = bgImageView.frame.origin.x
        bgParallaxImageView.frame.origin.x = translatedOffsetX * mountainParallaxSpeed
    }
    
    func storeInitialConstraints() {
        getStartedButtonInitialBottomConstraint = getStartedButtonBottomConstraint.constant
        getStartedButtonInitialBottomConstraintIPAD = getStartedButtonBottomConstraintIPAD.constant
        loginContainerViewTopConstant.constant = self.view.frame.height
        loginContainerViewInitialTopConstant = loginContainerViewTopConstant.constant
        loginContainerViewTopConstantIPAD.constant = self.view.frame.height
        loginContainerViewInitialTopConstantIPAD = loginContainerViewTopConstant.constant
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
//        default: return UIInterfaceOrientation.LandscapeRight.rawValue
//        }
//    }
    
}

