//
//  OnboardingViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 27.01.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let panorama = UIImage(named: "panOslo")
        let imageView = UIImageView(image: panorama)
        
        scrollView.contentSize = CGSizeMake(self.view.frame.width*5, self.view.frame.height)
        scrollView.addSubview(imageView)
        
        pageControl.numberOfPages = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updatPageControl()
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
    }
    
    func updatPageControl(){
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        pageControl.currentPage = page
        
        let pageX = scrollView.contentOffset.x - view.frame.width*CGFloat(page)
        let prcnt = pageX / view.frame.width
        println("x: \(pageX) percent: \(prcnt)")
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
