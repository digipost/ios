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

    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var button: UIButton!
    
    var logo = UIImageView()
    var bgImageView = UIImageView()
    // AnimationViews
    var firstAnimationView: DeviceView?
    var secondAnimationView: DeviceView?
    var thirdAnimationView: DeviceView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let screenEdgeOffset = view.frame.width/3
        
        // Set up bacground image & imageView
        let image = UIImage(named: "background-cropped")
        if let img = image {
            bgImageView.image = img
            bgImageView.frame = CGRectMake(-screenEdgeOffset, 0, img.size.width, view.frame.height)
        }
        
        // Set up scrollView
        let pageSize = view.frame.size
        let numOfPages:CGFloat = 5
        scrollView.frame = view.frame
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSizeMake(pageSize.width * numOfPages, pageSize.height)
        
        // Set background position to parallax starting point
        bgImageView.center.x = (scrollView.contentSize.width/2 - scrollView.contentOffset.x)*0.5
        
        view.addSubview(bgImageView)
        
        view.addSubview(scrollView)
        //scrollView.addSubview(bgImageView)
        
        // Setup animation views
        setupAnimationViews()
        
        let logoImg = UIImage(named: "logo")
        if let img = logoImg {
            logo.image = img
            let logoWidth = view.frame.width/4
            logo.frame = CGRectMake(view.frame.midX - logoWidth/2, view.frame.midY - logoWidth, logoWidth, logoWidth)
            logo.center.y = CGFloat(abs(Int32(scrollView.contentOffset.x - ((scrollView.frame.height / 2 ))))) - logo.frame.height
            view.addSubview(logo)
        }
        
        view.bringSubviewToFront(button)
    }
    
    func setupAnimationViews(){
        let viewWidth = view.frame.width/2
        let pageCenter = scrollView.frame.midY - (viewWidth / 2)
        let viewOffset = scrollView.frame.width
        
        firstAnimationView = DeviceView(frame: CGRectMake(viewOffset, 100, viewWidth, viewWidth))
        //firstAnimationView?.backgroundColor = UIColor.redColor()
        scrollView.addSubview(firstAnimationView!)
        
        secondAnimationView = DeviceView(frame: CGRectMake(viewOffset*2, 100, viewWidth, viewWidth))
        //secondAnimationView?.backgroundColor = UIColor.redColor()
        scrollView.addSubview(secondAnimationView!)
        
        thirdAnimationView = DeviceView(frame: CGRectMake(viewOffset*3, 100, viewWidth, viewWidth))
        //thirdAnimationView?.backgroundColor = UIColor.redColor()
        scrollView.addSubview(thirdAnimationView!)
    }
    
    func updateAnimationViewProgress(){
        
        let progress = scrollView.pageProgressInPercentage()
        
        switch progress{
        case -1.0...1.0:
            firstAnimationView?.progress =  progress
            logo.center.y = CGFloat(abs(Int32(scrollView.contentOffset.x - ((scrollView.frame.height / 2 ))))) - logo.frame.height
            logo.alpha = 1 - progress
        case 1.0...2.0:
            secondAnimationView?.progress =  progress - 1
            firstAnimationView?.progress = 2 - progress
        case 2.0...3.0:
            thirdAnimationView?.progress =  progress - 2
            secondAnimationView?.progress = 3 - progress
        case 3.0...5.0:
            thirdAnimationView?.progress = 4 - progress
            button.frame.origin.y = (scrollView.contentSize.width - scrollView.contentOffset.x) - (scrollView.frame.height/4)
            pageControl.frame.origin.y = button.frame.origin.y - button.frame.height
            pageControl.alpha = (4 - progress)*3
        default: break
        }
    }
    
    func panBackground(){
        let contentCenter = scrollView.contentSize.width/2
        let currentContentOffsetX = scrollView.contentOffset.x
        let parallaxRate:CGFloat = 0.5
        bgImageView.center.x = (contentCenter - currentContentOffsetX) * parallaxRate
    }
    
    // MARK: - Scrollview Delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //       println(scrollView.contentOffset.x)
        //       println("total progress in %: \(scrollView.totalOffsetInPercentage())")
        //       println("page progress in %: \(pageProgressInPercentage)")
        
        panBackground()
        updateAnimationViewProgress()
        pageControl.currentPage = scrollView.currentPage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
