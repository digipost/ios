//
//  OnboardingViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 27.01.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension UIScrollView{
    
    func totalOffsetInPercentage() -> CGFloat{
        let maxHorizontalOffset = self.contentSize.width - pageSize().width
        let currentHorizontalOffset = self.contentOffset.x
        return currentHorizontalOffset / maxHorizontalOffset
    }
    
    func pageProgressInPercentage() -> CGFloat{
        return self.contentOffset.x / pageSize().width
    }
    
    func pageSize() -> CGSize{
        return self.frame.size
    }
    
    func currentPage() -> Int{
        return Int(floor((self.contentOffset.x * 2.0 + self.frame.width) / (self.frame.width * 2.0)))
    }
}

class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    
    // Backgrounds
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var bgMaskImageView: UIImageView!
    @IBOutlet var bgParallaxImageView: UIImageView!
    // First page
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var welcomeLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    var deviceView: DeviceView?
    
    
    // AnimationViews
    var firstAnimationView: DeviceView!
    var secondAnimationView: LockView!
    var thirdAnimationView: ReceiptView!
    
    
    @IBOutlet var getStartedButton: UIButton!
    @IBOutlet var pageControll: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set up scrollView
        let pageSize = view.frame.size
        let numOfPages:CGFloat = 5
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSizeMake(pageSize.width * numOfPages, pageSize.height)
        println(scrollView.constraints())
        // Setup bacground images & imageViews
        let screenEdgeOffset = view.frame.width/3
        
        if let backgroundImage = UIImage(named: "background-cropped") {
            bgImageView.image = backgroundImage
            bgImageView.frame = CGRectMake(-screenEdgeOffset, 0, backgroundImage.size.width, view.frame.height)
          //  view.addSubview(bgImageView)
        }
        
        if let logoImg = UIImage(named: "logo-text") {
            logoImageView.image = logoImg
            let logoWidth = view.frame.width/2
            logoImageView.frame = CGRectMake(view.frame.midX - logoWidth/2, view.frame.midY - logoWidth, logoWidth, logoWidth)
            logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
            logoImageView.center.y = CGFloat(abs(Int32(scrollView.contentOffset.x - ((scrollView.frame.height / 2 ))))) - logoImageView.frame.height
         //   view.addSubview(logoImageView)
        }
        
        welcomeLabel.frame = CGRectMake(0, 0, view.frame.width/2, view.frame.width/2)
        welcomeLabel.center = CGPointMake(logoImageView.center.x, logoImageView.center.y + welcomeLabel.frame.height/3)
        welcomeLabel.textColor = UIColor.blackColor()
        welcomeLabel.numberOfLines = 2
        welcomeLabel.textAlignment = .Center
        welcomeLabel.text = "Velkommen til din\nsikre digitale postkasse"
      //  view.addSubview(welcomeLabel)
        
        
        if let backgroundMaskImage = UIImage(named: "background-mask") {
            bgMaskImageView.image = backgroundMaskImage
            bgMaskImageView.frame = CGRectMake(-screenEdgeOffset, 0, backgroundMaskImage.size.width, view.frame.height)
          //  view.addSubview(bgMaskImageView)
        }
//        if let backgroundParallaxImage = UIImage(named: "background-mountain") {
//            bgParallaxImageView.image = backgroundParallaxImage
//            bgParallaxImageView.frame = CGRectMake(-screenEdgeOffset, 0, backgroundParallaxImage.size.width, view.frame.height)
//            
//          //  view.addSubview(bgParallaxImageView)
//        }
        let initialBackgroundHeight = bgParallaxImageView.frame.height
        bgParallaxImageView.transform = CGAffineTransformMakeScale(1.15, 1.15)
        let newBackgroundHeight = bgParallaxImageView.frame.height
        let newOriginY = newBackgroundHeight - initialBackgroundHeight
        bgParallaxImageView.frame.origin.y = -newOriginY
        
        
        // Set background positions to parallax starting point
        bgImageView.center.x = (scrollView.contentSize.width/2 - scrollView.contentOffset.x)*0.5
        bgMaskImageView.center = bgImageView.center
        bgParallaxImageView.center.x = (((scrollView.contentSize.width/2)) - scrollView.contentOffset.x)*0.55
        
        view.addSubview(scrollView)
        
        // Setup animation views
        setupAnimationViews()
        
        view.bringSubviewToFront(pageControll)
        view.bringSubviewToFront(getStartedButton)
    }
    
    func setupAnimationViews(){
        let pageCenter = scrollView.frame.midY - (view.frame.width/4)
        let viewOffset = scrollView.frame.width
        let viewSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height)
        
        firstAnimationView = DeviceView(frame: CGRectMake(viewOffset, 0, viewSize.width, viewSize.height))
        //firstAnimationView.backgroundColor = UIColor.redColor()
        scrollView.addSubview(firstAnimationView!)
        
        let firstAnimationText = UILabel(frame: CGRectMake(firstAnimationView.frame.origin.x, firstAnimationView.frame.origin.y + viewSize.width/3 , viewSize.width/2, viewSize.height/2))
        firstAnimationText.center = CGPointMake(firstAnimationView.center.x, firstAnimationText.center.y)
        firstAnimationText.textColor = UIColor.blackColor()
        firstAnimationText.textAlignment = .Center
        firstAnimationText.numberOfLines = 2
        firstAnimationText.text = "Ha med deg\npostkassen din overalt"
        scrollView.addSubview(firstAnimationText)
        
        secondAnimationView = LockView(frame: CGRectMake(viewOffset*2, 0, viewSize.width, viewSize.height))
        //secondAnimationView.backgroundColor = UIColor.redColor()
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
        //thirdAnimationView.backgroundColor = UIColor.redColor()
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
        //       println(scrollView.contentOffset.x)
        //       println("total progress in %: \(scrollView.totalOffsetInPercentage())")
        //       println("page progress in %: \(pageProgressInPercentage)")
        
        panBackground()
        updateAnimationViewProgress()
        pageControll.currentPage = scrollView.currentPage()
    }
    
    @IBAction func startAnimation(sender: AnyObject) {
        deviceView?.startAllAnimations(self)
    }
    
    func updateAnimationViewProgress(){
        
        let progress = scrollView.pageProgressInPercentage()
        
        switch progress{
        case -1.0...1.0:
            firstAnimationView.progress =  progress
            logoImageView.center.y = CGFloat(abs(Int32(scrollView.contentOffset.x + ((scrollView.frame.height / 2 ))))) - logoImageView.frame.height
            welcomeLabel.center.y = logoImageView.center.y + welcomeLabel.frame.height/3
            //logoImageView.alpha = 1 - progress
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
            //getStartedButton.frame.origin.y = (scrollView.contentSize.width - scrollView.contentOffset.x) - (scrollView.frame.height/4)
            //pageControll.frame.origin.y = getStartedButton.frame.origin.y - getStartedButton.frame.height
            pageControll.alpha = (4 - progress)*3
            logoImageView.hidden = true
            welcomeLabel.hidden = true
        default: break
        }
    }
    
    func panBackground(){
        let contentCenter = scrollView.contentSize.width/2
        let currentContentOffsetX = scrollView.contentOffset.x
        let backgroundParallaxRate:CGFloat = 0.5
        let mountainParallaxRate: CGFloat = 0.55
        bgImageView.center.x = (contentCenter - currentContentOffsetX) * backgroundParallaxRate
        bgMaskImageView.center = bgImageView.center
        bgParallaxImageView.center.x = ((contentCenter) - currentContentOffsetX ) * mountainParallaxRate
    }
    
}

