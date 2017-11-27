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

private struct onboardingViewControllerConstants {
    static let showOnboardingLoginViewControllerSegue = "showOnboardingLoginViewControllerSegue"
}

class OnboardingViewController: GAITrackedViewController, UIScrollViewDelegate {
    
    private lazy var __once: () = {
            self.setupAnimationViews()
            // Stor initial consstraint constants for button and login conatiner view
            self.storeInitialConstraints()
        }()
    
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
    var animationViewSetup_dispatch_token: Int = 0
    
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
    
    @IBOutlet var pageControl: UIPageControl!

    var logoInitialPositionY:CGFloat = 0
    var welcomeLabelInitialPositionY:CGFloat = 0
    
    @objc var onboardingLoginViewController : OnboardingLoginViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Onboarding"
        modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        scrollView.delegate = self
        
        welcomeLabel.text = NSLocalizedString("onboarding welcome", comment: "welcome label")
        
        getStartedButton.setTitle(NSLocalizedString("onboarding button", comment: "get started button"), for: UIControlState())
        getStartedButton.accessibilityLabel = "Get started"
        
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        print("rotate view")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup animation views
        _ = self.__once
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoInitialPositionY = logoImageView.center.y
        welcomeLabelInitialPositionY = welcomeLabel.center.y
        panBackground()
    }

    func setupAnimationViews() {
        
        let pageSize = view.frame.size
        let numOfPages:CGFloat = 5
        scrollView.contentSize = CGSize(width: pageSize.width * numOfPages, height: pageSize.height)
        
        let viewOffset = scrollView.frame.width
        let animationFrame = animationMockView.frame

        firstAnimationView = PeopleView(frame: animationFrame)
        firstAnimationView.center.x = animationMockView.center.x + viewOffset
        firstAnimationView.animationText.string = Guide.onboardingText(forIndex: 1)
        scrollView.addSubview(firstAnimationView!)
        
        secondAnimationView = UploadView(frame: animationFrame)
        secondAnimationView.center.x = animationMockView.center.x + viewOffset * 2
        secondAnimationView.animationText.string = Guide.onboardingText(forIndex: 2)
        scrollView.addSubview(secondAnimationView!)
        
        thirdAnimationView = ReceiptView(frame: animationFrame)
        thirdAnimationView.center.x = animationMockView.center.x + viewOffset * 3
        thirdAnimationView.animationText.string = Guide.onboardingText(forIndex: 3)
        scrollView.addSubview(thirdAnimationView!)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        panBackground()
        updateAnimationViewProgress()
        pageControl.currentPage = scrollView.currentPage
    }
    
    func updateAnimationViewProgress() {
        
        let progress = scrollView.pageProgressInPercentage
        switch progress {
        case -1.0...1.0:
            firstAnimationView.progress =  progress
            logoImageView.center.y = logoInitialPositionY + scrollView.contentOffset.x
            welcomeLabel.center.y = welcomeLabelInitialPositionY + scrollView.contentOffset.x
            logoImageView.alpha = 1 - progress
            logoImageView.isHidden = false
            welcomeLabel.isHidden = false
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
            let scrollRateMultiplier:CGFloat = self.view.frame.height <= 480 ? 1.2 : 1.36
            let scrollRateMultiplierIPAD:CGFloat = 0.515
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
            pageControl.alpha = (4 - progress)
            getStartedButton.alpha = (4 - progress)
            logoImageView.isHidden = true
            welcomeLabel.isHidden = true
            
        default: break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == onboardingViewControllerConstants.showOnboardingLoginViewControllerSegue {
            onboardingLoginViewController = segue.destination as? OnboardingLoginViewController
        }
    }
    
    @IBAction func getStartedButtonAction(_ sender: AnyObject) {
        let lastPageRect = CGRect(x: 0, y: 0, width: scrollView.pageSize.width*5, height: scrollView.pageSize.height)
        scrollView.scrollRectToVisible(lastPageRect, animated: true)
    }

    func panBackground() {
        let translatedOffsetX = -(scrollView.contentOffset.x + scrollView.scrollableEdgeOffset)
        bgImageView.frame.origin.x = translatedOffsetX * parallaxSpeedForCurrentDevice().backgroundSpeed - 50
        bgMaskImageView.frame.origin.x = bgImageView.frame.origin.x
        bgParallaxImageView.frame.origin.x = translatedOffsetX * parallaxSpeedForCurrentDevice().mountainSpeed - 50
    }
    
    func storeInitialConstraints() {
        getStartedButtonInitialBottomConstraint = getStartedButtonBottomConstraint.constant
        getStartedButtonInitialBottomConstraintIPAD = getStartedButtonBottomConstraintIPAD.constant
        loginContainerViewTopConstant.constant = self.view.frame.height
        loginContainerViewInitialTopConstant = loginContainerViewTopConstant.constant
        loginContainerViewTopConstantIPAD.constant = self.view.frame.height
        loginContainerViewInitialTopConstantIPAD = loginContainerViewTopConstant.constant
    }
    
    func parallaxSpeedForCurrentDevice() -> (backgroundSpeed: CGFloat, mountainSpeed: CGFloat){
        // Set parallax speed depending on device
        
        // ParallaxRates
        var backgroundParallaxSpeed:CGFloat!
        var mountainParallaxSpeed: CGFloat!
        
        let device = UIDevice.current.userInterfaceIdiom
        switch device {
        case .phone:
            backgroundParallaxSpeed = 0.5
            mountainParallaxSpeed = 0.57
        case .pad:
            backgroundParallaxSpeed = 0.1
            mountainParallaxSpeed = 0.13
        default: break
        }
        
        return (backgroundParallaxSpeed, mountainParallaxSpeed)
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        let device = UIDevice.current.userInterfaceIdiom
        
        switch device {
        case .phone:
            return UIInterfaceOrientationMask.portrait
        case .pad:
            return UIInterfaceOrientationMask.landscape
        default:
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
}

