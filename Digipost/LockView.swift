//
//  LockView.swift
//
//  Code generated using QuartzCode on 2015-02-18.
//  www.quartzcodeapp.com
//

import UIKit

class LockView: UIView {
    
    var layerWithAnims : [CALayer]!
    var animationAdded : Bool = false
    var lock : CALayer!
    var roundedrect : CAShapeLayer!
    var path : CAShapeLayer!
    var oval : CAShapeLayer!
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
        lock = CALayer()
        self.layer.addSublayer(lock)
        
        
        roundedrect = CAShapeLayer()
        lock.addSublayer(roundedrect)
        roundedrect.fillColor   = nil
        roundedrect.strokeColor = UIColor.blackColor().CGColor
        roundedrect.lineWidth   = 3
        
        path = CAShapeLayer()
        lock.addSublayer(path)
        path.fillRule    = kCAFillRuleEvenOdd
        path.fillColor   = nil
        path.strokeColor = UIColor.blackColor().CGColor
        path.lineWidth   = 3
        
        oval = CAShapeLayer()
        lock.addSublayer(oval)
        oval.lineCap     = kCALineCapRound
        oval.fillColor   = nil
        oval.strokeColor = UIColor.blackColor().CGColor
        oval.lineWidth   = 3
        
        animationText = CATextLayer()
        self.layer.addSublayer(animationText)
        animationText.contentsScale   = UIScreen.mainScreen().scale
        animationText.string          = "Hello World!"
        animationText.font            = "HelveticaNeue"
        animationText.fontSize        = 17
        animationText.alignmentMode   = kCAAlignmentCenter;
        animationText.foregroundColor = UIColor.blackColor().CGColor;
        
        setupLayerFrames()
        
        self.layerWithAnims = [lock, roundedrect, path, oval, animationText]
    }
    
    
    func setupLayerFrames(){
        if lock != nil{
            lock.frame = CGRectMake(0.39204 * lock.superlayer.bounds.width, 0.15373 * lock.superlayer.bounds.height, 0.21681 * lock.superlayer.bounds.width, 0.41073 * lock.superlayer.bounds.height)
        }
        if roundedrect != nil{
            roundedrect.frame = CGRectMake(0, 0.43648 * roundedrect.superlayer.bounds.height,  roundedrect.superlayer.bounds.width, 0.56352 * roundedrect.superlayer.bounds.height)
            roundedrect.path  = roundedRectPathWithBounds(roundedrect.bounds).CGPath;
        }
        if path != nil{
            path.frame = CGRectMake(0.35811 * path.superlayer.bounds.width, 0.57834 * path.superlayer.bounds.height, 0.28379 * path.superlayer.bounds.width, 0.2798 * path.superlayer.bounds.height)
            path.path  = pathPathWithBounds(path.bounds).CGPath;
        }
        if oval != nil{
            oval.frame = CGRectMake(0.11835 * oval.superlayer.bounds.width, 0, 0.74488 * oval.superlayer.bounds.width, 0.39146 * oval.superlayer.bounds.height)
            oval.path  = ovalPathWithBounds(oval.bounds).CGPath;
        }
        if animationText != nil{
            animationText.frame = CGRectMake(0.00459 * animationText.superlayer.bounds.width, 0.65859 * animationText.superlayer.bounds.height, 0.98989 * animationText.superlayer.bounds.width, 0.34187 * animationText.superlayer.bounds.height)
        }
    }
    
    
    @IBAction func startAllAnimations(sender: AnyObject!){
        self.animationAdded = false
        for layer in self.layerWithAnims{
            layer.speed = 1
        }
        
        roundedrect?.addAnimation(roundedRectAnimation(), forKey:"roundedRectAnimation")
        path?.addAnimation(pathAnimation(), forKey:"pathAnimation")
        oval?.addAnimation(ovalAnimation(), forKey:"ovalAnimation")
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
                var totalDuration : CGFloat = 3.31
                var offset = progress * totalDuration
                for layer in self.layerWithAnims{
                    layer.timeOffset = CFTimeInterval(offset)
                }
            }
        }
    }
    
    func roundedRectAnimation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.353, 1]
        strokeEndAnim.duration = 3.12
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func pathAnimation() -> CAAnimationGroup{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 2]
        strokeEndAnim.keyTimes = [0, 0.979, 1]
        strokeEndAnim.duration = 2.87
        
        var transformAnim       = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values    = [NSValue(CATransform3D: CATransform3DIdentity),
            NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)),
            NSValue(CATransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes  = [0, 0.484, 1]
        transformAnim.duration  = 0.447
        transformAnim.beginTime = 2.87
        
        var path5AnimGroup                 = CAAnimationGroup()
        path5AnimGroup.animations          = [strokeEndAnim, transformAnim]
        path5AnimGroup.animations.map{$0.setValue(kCAFillModeForwards, forKeyPath:"fillMode")}
        path5AnimGroup.fillMode            = kCAFillModeForwards
        path5AnimGroup.removedOnCompletion = false
        path5AnimGroup.duration = QCMethod.maxDurationFromAnimations(path5AnimGroup.animations as [CAAnimation])
        
        
        return path5AnimGroup;
    }
    
    func ovalAnimation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.545, 1]
        strokeEndAnim.duration = 3.16
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    //MARK: - Bezier Path
    
    func roundedRectPathWithBounds(bound: CGRect) -> UIBezierPath{
        var roundedRectPath = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        roundedRectPath.moveToPoint(CGPointMake(minX + 0.17189 * w, minY))
        roundedRectPath.addCurveToPoint(CGPointMake(minX, minY + 0.1811 * h), controlPoint1:CGPointMake(minX + 0.07696 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.08108 * h))
        roundedRectPath.addLineToPoint(CGPointMake(minX, minY + 0.8189 * h))
        roundedRectPath.addCurveToPoint(CGPointMake(minX + 0.17189 * w, minY + h), controlPoint1:CGPointMake(minX, minY + 0.91892 * h), controlPoint2:CGPointMake(minX + 0.07696 * w, minY + h))
        roundedRectPath.addLineToPoint(CGPointMake(minX + 0.82811 * w, minY + h))
        roundedRectPath.addCurveToPoint(CGPointMake(minX + w, minY + 0.8189 * h), controlPoint1:CGPointMake(minX + 0.92304 * w, minY + h), controlPoint2:CGPointMake(minX + w, minY + 0.91892 * h))
        roundedRectPath.addLineToPoint(CGPointMake(minX + w, minY + 0.1811 * h))
        roundedRectPath.addCurveToPoint(CGPointMake(minX + 0.82811 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.08108 * h), controlPoint2:CGPointMake(minX + 0.92304 * w, minY))
        roundedRectPath.closePath()
        roundedRectPath.moveToPoint(CGPointMake(minX + 0.17189 * w, minY))
        
        return roundedRectPath;
    }
    
    func pathPathWithBounds(bound: CGRect) -> UIBezierPath{
        var pathPath = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        pathPath.moveToPoint(CGPointMake(minX + 0.22996 * w, minY + 0.54648 * h))
        pathPath.addCurveToPoint(CGPointMake(minX, minY + 0.29672 * h), controlPoint1:CGPointMake(minX + 0.09163 * w, minY + 0.4937 * h), controlPoint2:CGPointMake(minX, minY + 0.40156 * h))
        pathPath.addCurveToPoint(CGPointMake(minX + 0.5 * w, minY), controlPoint1:CGPointMake(minX, minY + 0.13284 * h), controlPoint2:CGPointMake(minX + 0.22386 * w, minY))
        pathPath.addCurveToPoint(CGPointMake(minX + w, minY + 0.29672 * h), controlPoint1:CGPointMake(minX + 0.77614 * w, minY), controlPoint2:CGPointMake(minX + w, minY + 0.13284 * h))
        pathPath.addCurveToPoint(CGPointMake(minX + 0.77568 * w, minY + 0.5443 * h), controlPoint1:CGPointMake(minX + w, minY + 0.40013 * h), controlPoint2:CGPointMake(minX + 0.91086 * w, minY + 0.49118 * h))
        pathPath.addLineToPoint(CGPointMake(minX + 0.93645 * w, minY + 0.88778 * h))
        pathPath.addCurveToPoint(CGPointMake(minX + 0.74548 * w, minY + h), controlPoint1:CGPointMake(minX + 0.93645 * w, minY + 0.94976 * h), controlPoint2:CGPointMake(minX + 0.85095 * w, minY + h))
        pathPath.addLineToPoint(CGPointMake(minX + 0.27789 * w, minY + h))
        pathPath.addCurveToPoint(CGPointMake(minX + 0.08691 * w, minY + 0.88778 * h), controlPoint1:CGPointMake(minX + 0.17242 * w, minY + h), controlPoint2:CGPointMake(minX + 0.08691 * w, minY + 0.94976 * h))
        pathPath.addLineToPoint(CGPointMake(minX + 0.22996 * w, minY + 0.54648 * h))
        pathPath.closePath()
        pathPath.moveToPoint(CGPointMake(minX + 0.22996 * w, minY + 0.54648 * h))
        
        return pathPath;
    }
    
    func ovalPathWithBounds(bound: CGRect) -> UIBezierPath{
        var ovalPath = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        ovalPath.moveToPoint(CGPointMake(minX + 0.5 * w, minY))
        ovalPath.addCurveToPoint(CGPointMake(minX, minY + 0.5 * h), controlPoint1:CGPointMake(minX + 0.22386 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.22386 * h))
        ovalPath.addLineToPoint(CGPointMake(minX, minY + h))
        ovalPath.moveToPoint(CGPointMake(minX + w, minY + h))
        ovalPath.addLineToPoint(CGPointMake(minX + w, minY + 0.5 * h))
        ovalPath.addCurveToPoint(CGPointMake(minX + 0.5 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.22386 * h), controlPoint2:CGPointMake(minX + 0.77614 * w, minY))
        
        return ovalPath;
    }
    
}