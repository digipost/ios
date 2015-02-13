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
    let backgroundParallaxRate:CGFloat = 0.5
    let mountainParallaxRate: CGFloat = 0.57
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var getStartedButton: UIButton!
    @IBOutlet var pageControll: UIPageControl!
    
    var initialButtonPostionY:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialButtonPostionY = getStartedButton.center.y
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let pageSize = view.frame.size
        let numOfPages:CGFloat = 5
        scrollView.delegate = self
        scrollView.contentSize = CGSizeMake(pageSize.width * numOfPages, pageSize.height)
        
        panBackground()
      
        println(bgImageView.frame)
        println(bgMaskImageView.frame)
        println(bgParallaxImageView.frame)
     
        // Setup animation views
        setupAnimationViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
            logoImageView.center.y = CGFloat(abs(Int32(scrollView.contentOffset.x + ((scrollView.frame.height / 2 ))))) - logoImageView.frame.height
            welcomeLabel.center.y = logoImageView.center.y + welcomeLabel.frame.height/3
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
            getStartedButton.frame.origin.y = (scrollView.frame.width*4.2 - scrollView.contentOffset.x)
            //pageControll.frame.origin.y = getStartedButton.frame.origin.y - getStartedButton.frame.height
            pageControll.alpha = (4 - progress)*3
            logoImageView.hidden = true
            welcomeLabel.hidden = true
        default: break
        }
    }
    
    func panBackground(){
        let translatedOffsetX = -(scrollView.contentOffset.x + scrollView.scrollableEdgeOffset)
        bgImageView.frame.origin.x = translatedOffsetX * backgroundParallaxRate
        bgMaskImageView.frame.origin.x = bgImageView.frame.origin.x
        bgParallaxImageView.frame.origin.x = translatedOffsetX * mountainParallaxRate
    }
    
}

