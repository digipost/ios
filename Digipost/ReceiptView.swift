//
//  ReceiptView.swift
//
//  Code generated using QuartzCode on 2015-02-18.
//  www.quartzcodeapp.com
//

import UIKit

class ReceiptView: UIView {
    
    var layerWithAnims : [CALayer]!
    var animationAdded : Bool = false
    var kvitto : CALayer!
    var path : CAShapeLayer!
    var rectangle : CAShapeLayer!
    var rectangle2 : CAShapeLayer!
    var rectangle3 : CAShapeLayer!
    var kort : CALayer!
    var path2 : CAShapeLayer!
    var rectangle4 : CAShapeLayer!
    var litenkvadrat : CALayer!
    var roundedrect : CAShapeLayer!
    var rectangle5 : CAShapeLayer!
    var rectangle6 : CAShapeLayer!
    var animationText : CATextLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupLayers()
    }
    
    override var frame: CGRect {
        didSet{
            setupLayerFrames()
        }
    }
    
    func setupLayers(){
        kvitto = CALayer()
        self.layer.addSublayer(kvitto)
        kvitto.setValue(8.8 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        
        
        path = CAShapeLayer()
        kvitto.addSublayer(path)
        path.fillRule    = kCAFillRuleEvenOdd
        path.fillColor   = nil
        path.strokeColor = UIColor.blackColor().CGColor
        path.lineWidth   = 3
        
        rectangle = CAShapeLayer()
        kvitto.addSublayer(rectangle)
        rectangle.setValue(179.6 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        rectangle.lineCap     = kCALineCapRound
        rectangle.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
        rectangle.strokeColor = UIColor.blackColor().CGColor
        rectangle.lineWidth   = 3
        
        rectangle2 = CAShapeLayer()
        kvitto.addSublayer(rectangle2)
        rectangle2.setValue(179.6 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        rectangle2.lineCap     = kCALineCapRound
        rectangle2.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
        rectangle2.strokeColor = UIColor.blackColor().CGColor
        rectangle2.lineWidth   = 3
        
        rectangle3 = CAShapeLayer()
        kvitto.addSublayer(rectangle3)
        rectangle3.setValue(179.6 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        rectangle3.lineCap     = kCALineCapRound
        rectangle3.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
        rectangle3.strokeColor = UIColor.blackColor().CGColor
        rectangle3.lineWidth   = 3
        
        kort = CALayer()
        self.layer.addSublayer(kort)
        kort.setValue(356 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        
        
        path2 = CAShapeLayer()
        kort.addSublayer(path2)
        path2.fillColor   = nil
        path2.strokeColor = UIColor.blackColor().CGColor
        path2.lineWidth   = 3
        
        rectangle4 = CAShapeLayer()
        kort.addSublayer(rectangle4)
        rectangle4.fillColor = UIColor.blackColor().CGColor
        rectangle4.lineWidth = 0
        
        litenkvadrat = CALayer()
        kort.addSublayer(litenkvadrat)
        
        
        roundedrect = CAShapeLayer()
        litenkvadrat.addSublayer(roundedrect)
        roundedrect.fillColor   = nil
        roundedrect.strokeColor = UIColor.blackColor().CGColor
        roundedrect.lineWidth   = 3
        
        rectangle5 = CAShapeLayer()
        kort.addSublayer(rectangle5)
        rectangle5.setValue(180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        rectangle5.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
        rectangle5.strokeColor = UIColor.blackColor().CGColor
        rectangle5.lineWidth   = 3
        
        rectangle6 = CAShapeLayer()
        kort.addSublayer(rectangle6)
        rectangle6.setValue(180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        rectangle6.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
        rectangle6.strokeColor = UIColor.blackColor().CGColor
        rectangle6.lineWidth   = 3
        
        animationText = CATextLayer()
        self.layer.addSublayer(animationText)
        animationText.contentsScale   = UIScreen.mainScreen().scale
        animationText.string          = "Hello World!"
        animationText.font            = "HelveticaNeue"
        animationText.fontSize        = 17
        animationText.alignmentMode   = kCAAlignmentCenter;
        animationText.foregroundColor = UIColor.blackColor().CGColor;
        
        setupLayerFrames()
        
        self.layerWithAnims = [kvitto, path, rectangle, rectangle2, rectangle3, kort, path2, rectangle4, litenkvadrat, roundedrect, rectangle5, rectangle6, animationText]
    }
    
    
    func setupLayerFrames(){
        if kvitto != nil{
            kvitto.setValue(0, forKeyPath:"transform.rotation")
            kvitto.frame = CGRectMake(0.49887 * kvitto.superlayer.bounds.width, 0.16268 * kvitto.superlayer.bounds.height, 0.17319 * kvitto.superlayer.bounds.width, 0.28291 * kvitto.superlayer.bounds.height)
            kvitto.setValue(8.8 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        }
        if path != nil{
            path.frame = CGRectMake(0, 0,  path.superlayer.bounds.width,  path.superlayer.bounds.height)
            path.path  = pathPathWithBounds(path.bounds).CGPath;
        }
        if rectangle != nil{
            rectangle.setValue(0, forKeyPath:"transform.rotation")
            rectangle.frame = CGRectMake(0.15504 * rectangle.superlayer.bounds.width, 0.2364 * rectangle.superlayer.bounds.height, 0.68991 * rectangle.superlayer.bounds.width, 0 * rectangle.superlayer.bounds.height)
            rectangle.setValue(179.6 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
            rectangle.path  = rectanglePathWithBounds(rectangle.bounds).CGPath;
        }
        if rectangle2 != nil{
            rectangle2.setValue(0, forKeyPath:"transform.rotation")
            rectangle2.frame = CGRectMake(0.15504 * rectangle2.superlayer.bounds.width, 0.30342 * rectangle2.superlayer.bounds.height, 0.68991 * rectangle2.superlayer.bounds.width, 0 * rectangle2.superlayer.bounds.height)
            rectangle2.setValue(179.6 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
            rectangle2.path  = rectangle2PathWithBounds(rectangle2.bounds).CGPath;
        }
        if rectangle3 != nil{
            rectangle3.setValue(0, forKeyPath:"transform.rotation")
            rectangle3.frame = CGRectMake(0.16367 * rectangle3.superlayer.bounds.width, 0.49835 * rectangle3.superlayer.bounds.height, 0.68991 * rectangle3.superlayer.bounds.width, 0 * rectangle3.superlayer.bounds.height)
            rectangle3.setValue(179.6 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
            rectangle3.path  = rectangle3PathWithBounds(rectangle3.bounds).CGPath;
        }
        if kort != nil{
            kort.setValue(0, forKeyPath:"transform.rotation")
            kort.frame = CGRectMake(0.28414 * kort.superlayer.bounds.width, 0.33865 * kort.superlayer.bounds.height, 0.27942 * kort.superlayer.bounds.width, 0.201 * kort.superlayer.bounds.height)
            kort.setValue(356 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        }
        if path2 != nil{
            path2.frame = CGRectMake(0, 0, 0.98549 * path2.superlayer.bounds.width,  path2.superlayer.bounds.height)
            path2.path  = path2PathWithBounds(path2.bounds).CGPath;
        }
        if rectangle4 != nil{
            rectangle4.frame = CGRectMake(0.00901 * rectangle4.superlayer.bounds.width, 0.21224 * rectangle4.superlayer.bounds.height, 0.99099 * rectangle4.superlayer.bounds.width, 0.10734 * rectangle4.superlayer.bounds.height)
            rectangle4.path  = rectangle4PathWithBounds(rectangle4.bounds).CGPath;
        }
        if litenkvadrat != nil{
            litenkvadrat.frame = CGRectMake(0.08387 * litenkvadrat.superlayer.bounds.width, 0.46287 * litenkvadrat.superlayer.bounds.height, 0.18491 * litenkvadrat.superlayer.bounds.width, 0.20749 * litenkvadrat.superlayer.bounds.height)
        }
        if roundedrect != nil{
            roundedrect.frame = CGRectMake(0.03569 * roundedrect.superlayer.bounds.width, 0.21791 * roundedrect.superlayer.bounds.height, 1.04772 * roundedrect.superlayer.bounds.width, 1.09459 * roundedrect.superlayer.bounds.height)
            roundedrect.path  = roundedRectPathWithBounds(roundedrect.bounds).CGPath;
        }
        if rectangle5 != nil{
            rectangle5.setValue(0, forKeyPath:"transform.rotation")
            rectangle5.frame = CGRectMake(0.31406 * rectangle5.superlayer.bounds.width, 0.53133 * rectangle5.superlayer.bounds.height, 0.57592 * rectangle5.superlayer.bounds.width, 0 * rectangle5.superlayer.bounds.height)
            rectangle5.setValue(180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
            rectangle5.path  = rectangle5PathWithBounds(rectangle5.bounds).CGPath;
        }
        if rectangle6 != nil{
            rectangle6.setValue(0, forKeyPath:"transform.rotation")
            rectangle6.frame = CGRectMake(0.32196 * rectangle6.superlayer.bounds.width, 0.68135 * rectangle6.superlayer.bounds.height, 0.22417 * rectangle6.superlayer.bounds.width, 0 * rectangle6.superlayer.bounds.height)
            rectangle6.setValue(180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
            rectangle6.path  = rectangle6PathWithBounds(rectangle6.bounds).CGPath;
        }
        if animationText != nil{
            animationText.frame = CGRectMake(0.0042 * animationText.superlayer.bounds.width, 0.65664 * animationText.superlayer.bounds.height, 0.99283 * animationText.superlayer.bounds.width, 0.34402 * animationText.superlayer.bounds.height)
        }
    }
    
    
    @IBAction func startAllAnimations(sender: AnyObject!){
        self.animationAdded = false
        for layer in self.layerWithAnims{
            layer.speed = 1
        }
        
        path?.addAnimation(pathAnimation(), forKey:"pathAnimation")
        rectangle?.addAnimation(rectangleAnimation(), forKey:"rectangleAnimation")
        rectangle2?.addAnimation(rectangle2Animation(), forKey:"rectangle2Animation")
        rectangle3?.addAnimation(rectangle3Animation(), forKey:"rectangle3Animation")
        
        path2?.addAnimation(path2Animation(), forKey:"path2Animation")
        rectangle4?.addAnimation(rectangle4Animation(), forKey:"rectangle4Animation")
        litenkvadrat?.addAnimation(litenKvadratAnimation(), forKey:"litenKvadratAnimation")
        rectangle5?.addAnimation(rectangle5Animation(), forKey:"rectangle5Animation")
        rectangle6?.addAnimation(rectangle6Animation(), forKey:"rectangle6Animation")
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
                var totalDuration : CGFloat = 3.52
                var offset = progress * totalDuration
                for layer in self.layerWithAnims{
                    layer.timeOffset = CFTimeInterval(offset)
                }
            }
        }
    }
    
    func pathAnimation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 0.551, 0.551, 1.1]
        strokeEndAnim.keyTimes = [0, 0.531, 0.724, 0.86, 1]
        strokeEndAnim.duration = 3.03
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
    
    func rectangle5Animation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.868, 1]
        strokeEndAnim.duration = 2.82
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func rectangle6Animation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.877, 1]
        strokeEndAnim.duration = 2.79
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    //MARK: - Bezier Path
    
    func pathPathWithBounds(bound: CGRect) -> UIBezierPath{
        var pathPath = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        pathPath.moveToPoint(CGPointMake(minX + 0.72545 * w, minY + 0.00016 * h))
        pathPath.addLineToPoint(CGPointMake(minX + 0.72545 * w, minY))
        pathPath.addLineToPoint(CGPointMake(minX + w, minY + 0.00016 * h))
        pathPath.addLineToPoint(CGPointMake(minX + w, minY + h))
        pathPath.addLineToPoint(CGPointMake(minX + 0.49502 * w, minY + h))
        pathPath.moveToPoint(CGPointMake(minX, minY + 0.645 * h))
        pathPath.addLineToPoint(CGPointMake(minX, minY + 0.00016 * h))
        pathPath.addLineToPoint(CGPointMake(minX + 0.26834 * w, minY + 0.00016 * h))
        pathPath.addLineToPoint(CGPointMake(minX + 0.26834 * w, minY + 0.02476 * h))
        pathPath.addCurveToPoint(CGPointMake(minX + 0.33184 * w, minY + 0.06919 * h), controlPoint1:CGPointMake(minX + 0.26834 * w, minY + 0.0493 * h), controlPoint2:CGPointMake(minX + 0.29677 * w, minY + 0.06919 * h))
        pathPath.addLineToPoint(CGPointMake(minX + 0.66816 * w, minY + 0.06919 * h))
        pathPath.addCurveToPoint(CGPointMake(minX + 0.72545 * w, minY + 0.02476 * h), controlPoint1:CGPointMake(minX + 0.70323 * w, minY + 0.06919 * h), controlPoint2:CGPointMake(minX + 0.72545 * w, minY + 0.0493 * h))
        pathPath.addLineToPoint(CGPointMake(minX + 0.72545 * w, minY + 0.00016 * h))
        pathPath.addLineToPoint(CGPointMake(minX + 0.72545 * w, minY + 0.00016 * h))
        
        return pathPath;
    }
    
    func rectanglePathWithBounds(bound: CGRect) -> UIBezierPath{
        var rectanglePath = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        rectanglePath.moveToPoint(CGPointMake(minX + w, minY * h))
        rectanglePath.addLineToPoint(CGPointMake(minX, minY * h))
        rectanglePath.closePath()
        rectanglePath.moveToPoint(CGPointMake(minX + w, minY * h))
        
        return rectanglePath;
    }
    
    func rectangle2PathWithBounds(bound: CGRect) -> UIBezierPath{
        var rectangle2Path = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        rectangle2Path.moveToPoint(CGPointMake(minX + w, minY * h))
        rectangle2Path.addLineToPoint(CGPointMake(minX, minY * h))
        rectangle2Path.closePath()
        rectangle2Path.moveToPoint(CGPointMake(minX + w, minY * h))
        
        return rectangle2Path;
    }
    
    func rectangle3PathWithBounds(bound: CGRect) -> UIBezierPath{
        var rectangle3Path = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        rectangle3Path.moveToPoint(CGPointMake(minX + w, minY * h))
        rectangle3Path.addLineToPoint(CGPointMake(minX, minY * h))
        rectangle3Path.closePath()
        rectangle3Path.moveToPoint(CGPointMake(minX + w, minY * h))
        
        return rectangle3Path;
    }
    
    func path2PathWithBounds(bound: CGRect) -> UIBezierPath{
        var path2Path = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        path2Path.moveToPoint(CGPointMake(minX + 0.04842 * w, minY))
        path2Path.addCurveToPoint(CGPointMake(minX, minY + 0.07448 * h), controlPoint1:CGPointMake(minX + 0.02168 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.03335 * h))
        path2Path.addLineToPoint(CGPointMake(minX, minY + 0.92552 * h))
        path2Path.addCurveToPoint(CGPointMake(minX + 0.04842 * w, minY + h), controlPoint1:CGPointMake(minX, minY + 0.96665 * h), controlPoint2:CGPointMake(minX + 0.02168 * w, minY + h))
        path2Path.addLineToPoint(CGPointMake(minX + 0.95158 * w, minY + h))
        path2Path.addCurveToPoint(CGPointMake(minX + w, minY + 0.92552 * h), controlPoint1:CGPointMake(minX + 0.97832 * w, minY + h), controlPoint2:CGPointMake(minX + w, minY + 0.96665 * h))
        path2Path.addLineToPoint(CGPointMake(minX + w, minY + 0.07448 * h))
        path2Path.addCurveToPoint(CGPointMake(minX + 0.95158 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.03335 * h), controlPoint2:CGPointMake(minX + 0.97832 * w, minY))
        path2Path.closePath()
        path2Path.moveToPoint(CGPointMake(minX + 0.04842 * w, minY))
        
        return path2Path;
    }
    
    func rectangle4PathWithBounds(bound: CGRect) -> UIBezierPath{
        var rectangle4Path = UIBezierPath(rect: bound)
        return rectangle4Path;
    }
    
    func roundedRectPathWithBounds(bound: CGRect) -> UIBezierPath{
        var roundedRectPath = UIBezierPath(roundedRect:bound, cornerRadius:3)
        return roundedRectPath;
    }
    
    func rectangle5PathWithBounds(bound: CGRect) -> UIBezierPath{
        var rectangle5Path = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        rectangle5Path.moveToPoint(CGPointMake(minX + w, minY * h))
        rectangle5Path.addLineToPoint(CGPointMake(minX, minY * h))
        rectangle5Path.closePath()
        rectangle5Path.moveToPoint(CGPointMake(minX + w, minY * h))
        
        return rectangle5Path;
    }
    
    func rectangle6PathWithBounds(bound: CGRect) -> UIBezierPath{
        var rectangle6Path = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        rectangle6Path.moveToPoint(CGPointMake(minX + w, minY * h))
        rectangle6Path.addLineToPoint(CGPointMake(minX, minY * h))
        rectangle6Path.closePath()
        rectangle6Path.moveToPoint(CGPointMake(minX + w, minY * h))
        
        return rectangle6Path;
    }
    
}