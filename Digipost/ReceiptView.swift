//
//  ReceiptView.swift
//
//  Code generated using QuartzCode on 2015-02-11.
//  www.quartzcodeapp.com
//

import UIKit

class ReceiptView: UIView {
    
    var layerWithAnims : [CALayer]!
    var animationAdded : Bool = false
    var receiptView : CALayer!
    var path : CAShapeLayer!
    var rectangle : CAShapeLayer!
    var rectangle2 : CAShapeLayer!
    var rectangle3 : CAShapeLayer!
    var path2 : CAShapeLayer!
    var rectangle4 : CAShapeLayer!
    var litenkvadrat : CALayer!
    var rectangle6 : CAShapeLayer!
    var rectangle7 : CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupLayers()
    }
    
    func setupLayers(){
        receiptView = CALayer()
        receiptView.frame           = CGRectMake(0.33, 3.5, 375, 330)
        receiptView.backgroundColor = UIColor(red:0.671, green: 0.745, blue:0.855, alpha:0).CGColor
        self.layer.addSublayer(receiptView)
        
        var kvitto = CALayer()
        kvitto.frame = CGRectMake(192.45, 107.32, 64.94, 94.49)
        kvitto.setValue(8.8 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        
        receiptView.addSublayer(kvitto)
        
        path = CAShapeLayer()
        path.frame       = CGRectMake(0, 0, 64.94, 94.49)
        path.fillRule    = kCAFillRuleEvenOdd
        path.fillColor   = nil
        path.strokeColor = UIColor.blackColor().CGColor
        path.lineWidth   = 3
        path.path        = pathPath().CGPath;
        kvitto.addSublayer(path)
        
        rectangle = CAShapeLayer()
        rectangle.frame       = CGRectMake(10.07, 22.34, 44.81, 0)
        rectangle.setValue(179.6 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        rectangle.lineCap     = kCALineCapRound
        rectangle.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
        rectangle.strokeColor = UIColor.blackColor().CGColor
        rectangle.lineWidth   = 3
        rectangle.path        = rectanglePath().CGPath;
        kvitto.addSublayer(rectangle)
        
        rectangle2 = CAShapeLayer()
        rectangle2.frame       = CGRectMake(10.07, 28.67, 44.81, 0)
        rectangle2.setValue(179.6 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        rectangle2.lineCap     = kCALineCapRound
        rectangle2.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
        rectangle2.strokeColor = UIColor.blackColor().CGColor
        rectangle2.lineWidth   = 3
        rectangle2.path        = rectangle2Path().CGPath;
        kvitto.addSublayer(rectangle2)
        
        rectangle3 = CAShapeLayer()
        rectangle3.frame       = CGRectMake(10.63, 47.09, 44.81, 0)
        rectangle3.setValue(179.6 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        rectangle3.lineCap     = kCALineCapRound
        rectangle3.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
        rectangle3.strokeColor = UIColor.blackColor().CGColor
        rectangle3.lineWidth   = 3
        rectangle3.path        = rectangle3Path().CGPath;
        kvitto.addSublayer(rectangle3)
        
        var kort = CALayer()
        kort.frame = CGRectMake(112.86, 164.61, 103.84, 67.13)
        kort.setValue(356 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        
        receiptView.addSublayer(kort)
        
        path2 = CAShapeLayer()
        path2.frame       = CGRectMake(0.29, 0, 103.26, 67.13)
        path2.fillColor   = nil
        path2.strokeColor = UIColor.blackColor().CGColor
        path2.lineWidth   = 3
        path2.path        = path2Path().CGPath;
        kort.addSublayer(path2)
        
        rectangle4 = CAShapeLayer()
        rectangle4.frame     = CGRectMake(0, 15.74, 103.84, 7.21)
        rectangle4.fillColor = UIColor.blackColor().CGColor
        rectangle4.lineWidth = 0
        rectangle4.path      = rectangle4Path().CGPath;
        kort.addSublayer(rectangle4)
        
        litenkvadrat = CALayer()
        litenkvadrat.frame = CGRectMake(7.84, 32.57, 19.38, 13.93)
        
        kort.addSublayer(litenkvadrat)
        
        var roundedrect = CAShapeLayer()
        roundedrect.frame       = CGRectMake(0.79, 3.07, 20.3, 15.25)
        roundedrect.fillColor   = nil
        roundedrect.strokeColor = UIColor.blackColor().CGColor
        roundedrect.lineWidth   = 3
        roundedrect.path        = roundedRectPath().CGPath;
        litenkvadrat.addSublayer(roundedrect)
        
        rectangle6 = CAShapeLayer()
        rectangle6.frame       = CGRectMake(31.96, 34.28, 60.35, 0)
        rectangle6.setValue(180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        rectangle6.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
        rectangle6.strokeColor = UIColor.blackColor().CGColor
        rectangle6.lineWidth   = 3
        rectangle6.path        = rectangle6Path().CGPath;
        kort.addSublayer(rectangle6)
        
        rectangle7 = CAShapeLayer()
        rectangle7.frame       = CGRectMake(32.79, 43.25, 23.49, 0)
        rectangle7.setValue(180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        rectangle7.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
        rectangle7.strokeColor = UIColor.blackColor().CGColor
        rectangle7.lineWidth   = 3
        rectangle7.path        = rectangle7Path().CGPath;
        kort.addSublayer(rectangle7)
        
        self.layerWithAnims = [receiptView, path, rectangle, rectangle2, rectangle3, path2, rectangle4, litenkvadrat, rectangle6, rectangle7]
    }
    
    
    @IBAction func startAllAnimations(sender: AnyObject!){
        self.animationAdded = false
        for layer in self.layerWithAnims{
            layer.speed = 1
        }
        receiptView?.addAnimation(receiptViewAnimation(), forKey:"receiptViewAnimation")
        
        path?.addAnimation(pathAnimation(), forKey:"pathAnimation")
        rectangle?.addAnimation(rectangleAnimation(), forKey:"rectangleAnimation")
        rectangle2?.addAnimation(rectangle2Animation(), forKey:"rectangle2Animation")
        rectangle3?.addAnimation(rectangle3Animation(), forKey:"rectangle3Animation")
        
        path2?.addAnimation(path2Animation(), forKey:"path2Animation")
        rectangle4?.addAnimation(rectangle4Animation(), forKey:"rectangle4Animation")
        litenkvadrat?.addAnimation(litenKvadratAnimation(), forKey:"litenKvadratAnimation")
        rectangle6?.addAnimation(rectangle6Animation(), forKey:"rectangle6Animation")
        rectangle7?.addAnimation(rectangle7Animation(), forKey:"rectangle7Animation")
    }
    
    var progress: CGFloat = 0 {
        didSet{
            if(!self.animationAdded){
                startAllAnimations(nil)
                self.animationAdded = true
                for layer in self.layerWithAnims{
                    layer.speed = 0
                    layer.timeOffset = 0
                }
            }
            else{
                var totalDuration : CGFloat = 3.54
                var offset = progress * totalDuration
                for layer in self.layerWithAnims{
                    layer.timeOffset = CFTimeInterval(offset)
                }
            }
        }
    }
    
    func receiptViewAnimation() -> CAKeyframeAnimation{
        var positionAnim      = CAKeyframeAnimation(keyPath:"position")
        positionAnim.values   = [NSValue(CGPoint: CGPointMake(288, 168.5)), NSValue(CGPoint: CGPointMake(288, 168.5)), NSValue(CGPoint: CGPointMake(187.833, 168.5))]
        positionAnim.keyTimes = [0, 0.396, 1]
        positionAnim.duration = 3.54
        positionAnim.fillMode = kCAFillModeForwards
        positionAnim.removedOnCompletion = false
        
        return positionAnim;
    }
    
    func pathAnimation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 0.551, 0.551, 1.1]
        strokeEndAnim.keyTimes = [0, 0.531, 0.724, 0.86, 1]
        strokeEndAnim.duration = 3.28
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func rectangleAnimation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.849, 1]
        strokeEndAnim.duration = 3.52
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func rectangle2Animation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.851, 1]
        strokeEndAnim.duration = 3.52
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func rectangle3Animation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.857, 1]
        strokeEndAnim.duration = 3.48
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func path2Animation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.348, 1]
        strokeEndAnim.duration = 3.12
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func rectangle4Animation() -> CAKeyframeAnimation{
        var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(CATransform3D: CATransform3DMakeScale(0, 1, 1)),
            NSValue(CATransform3D: CATransform3DMakeScale(0, 1, 1)),
            NSValue(CATransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes = [0, 0.871, 1]
        transformAnim.duration = 2.82
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.removedOnCompletion = false
        
        return transformAnim;
    }
    
    func litenKvadratAnimation() -> CAKeyframeAnimation{
        var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeScale(1.2, 1.2, 1.2)),
            NSValue(CATransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes = [0, 0.845, 0.919, 1]
        transformAnim.duration = 3.43
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.removedOnCompletion = false
        
        return transformAnim;
    }
    
    func rectangle6Animation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.868, 1]
        strokeEndAnim.duration = 2.82
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func rectangle7Animation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.877, 1]
        strokeEndAnim.duration = 2.79
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    //MARK: - Bezier Path
    
    func pathPath() -> UIBezierPath{
        var pathPath = UIBezierPath()
        pathPath.moveToPoint(CGPointMake(47.114, 0.015))
        pathPath.addLineToPoint(CGPointMake(47.114, 0))
        pathPath.addLineToPoint(CGPointMake(64.945, 0.015))
        pathPath.addLineToPoint(CGPointMake(64.945, 94.492))
        pathPath.addLineToPoint(CGPointMake(32.149, 94.492))
        pathPath.moveToPoint(CGPointMake(0, 60.947))
        pathPath.addLineToPoint(CGPointMake(0, 0.015))
        pathPath.addLineToPoint(CGPointMake(17.428, 0.015))
        pathPath.addLineToPoint(CGPointMake(17.428, 2.339))
        pathPath.addCurveToPoint(CGPointMake(21.551, 6.538), controlPoint1:CGPointMake(17.428, 4.658), controlPoint2:CGPointMake(19.274, 6.538))
        pathPath.addLineToPoint(CGPointMake(43.394, 6.538))
        pathPath.addCurveToPoint(CGPointMake(47.114, 2.339), controlPoint1:CGPointMake(45.671, 6.538), controlPoint2:CGPointMake(47.114, 4.658))
        pathPath.addLineToPoint(CGPointMake(47.114, 0.015))
        pathPath.addLineToPoint(CGPointMake(47.114, 0.015))
        
        return pathPath;
    }
    
    func rectanglePath() -> UIBezierPath{
        var rectanglePath = UIBezierPath()
        rectanglePath.moveToPoint(CGPointMake(44.806, 0))
        rectanglePath.addLineToPoint(CGPointMake(0, 0))
        rectanglePath.closePath()
        rectanglePath.moveToPoint(CGPointMake(44.806, 0))
        
        return rectanglePath;
    }
    
    func rectangle2Path() -> UIBezierPath{
        var rectangle2Path = UIBezierPath()
        rectangle2Path.moveToPoint(CGPointMake(44.806, 0))
        rectangle2Path.addLineToPoint(CGPointMake(0, 0))
        rectangle2Path.closePath()
        rectangle2Path.moveToPoint(CGPointMake(44.806, 0))
        
        return rectangle2Path;
    }
    
    func rectangle3Path() -> UIBezierPath{
        var rectangle3Path = UIBezierPath()
        rectangle3Path.moveToPoint(CGPointMake(44.806, 0))
        rectangle3Path.addLineToPoint(CGPointMake(0, 0))
        rectangle3Path.closePath()
        rectangle3Path.moveToPoint(CGPointMake(44.806, 0))
        
        return rectangle3Path;
    }
    
    func path2Path() -> UIBezierPath{
        var path2Path = UIBezierPath()
        path2Path.moveToPoint(CGPointMake(5, 0))
        path2Path.addCurveToPoint(CGPointMake(0, 5), controlPoint1:CGPointMake(2.239, 0), controlPoint2:CGPointMake(0, 2.239))
        path2Path.addLineToPoint(CGPointMake(0, 62.134))
        path2Path.addCurveToPoint(CGPointMake(5, 67.134), controlPoint1:CGPointMake(0, 64.895), controlPoint2:CGPointMake(2.239, 67.134))
        path2Path.addLineToPoint(CGPointMake(98.262, 67.134))
        path2Path.addCurveToPoint(CGPointMake(103.262, 62.134), controlPoint1:CGPointMake(101.023, 67.134), controlPoint2:CGPointMake(103.262, 64.895))
        path2Path.addLineToPoint(CGPointMake(103.262, 5))
        path2Path.addCurveToPoint(CGPointMake(98.262, 0), controlPoint1:CGPointMake(103.262, 2.239), controlPoint2:CGPointMake(101.023, 0))
        path2Path.closePath()
        path2Path.moveToPoint(CGPointMake(5, 0))
        
        return path2Path;
    }
    
    func rectangle4Path() -> UIBezierPath{
        var rectangle4Path = UIBezierPath(rect: CGRectMake(0, 0, 104, 7))
        return rectangle4Path;
    }
    
    func roundedRectPath() -> UIBezierPath{
        var roundedRectPath = UIBezierPath(roundedRect:CGRectMake(0, 0, 19, 14), cornerRadius:3)
        return roundedRectPath;
    }
    
    func rectangle6Path() -> UIBezierPath{
        var rectangle6Path = UIBezierPath()
        rectangle6Path.moveToPoint(CGPointMake(60.346, 0))
        rectangle6Path.addLineToPoint(CGPointMake(0, 0))
        rectangle6Path.closePath()
        rectangle6Path.moveToPoint(CGPointMake(60.346, 0))
        
        return rectangle6Path;
    }
    
    func rectangle7Path() -> UIBezierPath{
        var rectangle7Path = UIBezierPath()
        rectangle7Path.moveToPoint(CGPointMake(23.489, 0))
        rectangle7Path.addLineToPoint(CGPointMake(0, 0))
        rectangle7Path.closePath()
        rectangle7Path.moveToPoint(CGPointMake(23.489, 0))
        
        return rectangle7Path;
    }
    
}