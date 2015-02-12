//
//  LockView.swift
//
//  Code generated using QuartzCode on 2015-02-11.
//  www.quartzcodeapp.com
//

import UIKit

class LockView: UIView {
    
    var layerWithAnims : [CALayer]!
    var animationAdded : Bool = false
    var lockView : CALayer!
    var roundedrect : CAShapeLayer!
    var path : CAShapeLayer!
    var oval : CAShapeLayer!
    
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
        lockView = CALayer()
        lockView.frame           = CGRectMake(0, 2.35, 375, 330)
        lockView.backgroundColor = UIColor(red:0.671, green: 0.745, blue:0.855, alpha:0).CGColor
        self.layer.addSublayer(lockView)
        
        var lock = CALayer()
        lock.frame = CGRectMake(140.65, 92.91, 81.45, 144.18)
        
        lockView.addSublayer(lock)
        
        roundedrect = CAShapeLayer()
        roundedrect.frame       = CGRectMake(0, 66.88, 81.45, 77.31)
        roundedrect.fillColor   = nil
        roundedrect.strokeColor = UIColor.blackColor().CGColor
        roundedrect.lineWidth   = 3
        roundedrect.path        = roundedRectPath().CGPath;
        lock.addSublayer(roundedrect)
        
        path = CAShapeLayer()
        path.frame       = CGRectMake(29.17, 86.34, 23.11, 38.38)
        path.fillRule    = kCAFillRuleEvenOdd
        path.fillColor   = nil
        path.strokeColor = UIColor.blackColor().CGColor
        path.lineWidth   = 3
        path.path        = pathPath().CGPath;
        lock.addSublayer(path)
        
        oval = CAShapeLayer()
        oval.frame       = CGRectMake(9.64, 0, 60.67, 53.7)
        oval.lineCap     = kCALineCapRound
        oval.fillColor   = nil
        oval.strokeColor = UIColor.blackColor().CGColor
        oval.lineWidth   = 3
        oval.path        = ovalPath().CGPath;
        lock.addSublayer(oval)
        
        self.layerWithAnims = [lockView, roundedrect, path, oval]
    }
    
    
    @IBAction func startAllAnimations(sender: AnyObject!){
        self.animationAdded = false
        for layer in self.layerWithAnims{
            layer.speed = 1
        }
        lockView?.addAnimation(lockViewAnimation(), forKey:"lockViewAnimation")
        
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
                var totalDuration : CGFloat = 3.39
                var offset = progress * totalDuration
                for layer in self.layerWithAnims{
                    layer.timeOffset = CFTimeInterval(offset)
                }
            }
        }
    }
    
    func lockViewAnimation() -> CAKeyframeAnimation{
        var positionAnim      = CAKeyframeAnimation(keyPath:"position")
        positionAnim.values   = [NSValue(CGPoint: CGPointMake(288, 167.347)), NSValue(CGPoint: CGPointMake(288, 167.347)), NSValue(CGPoint: CGPointMake(187.5, 167.347))]
        positionAnim.keyTimes = [0, 0.55, 1]
        positionAnim.duration = 2.66
        positionAnim.fillMode = kCAFillModeForwards
        positionAnim.removedOnCompletion = false
        
        return positionAnim;
    }
    
    func roundedRectAnimation() -> CAAnimationGroup{
        var strokeEndAnim       = CABasicAnimation(keyPath:"strokeEnd")
        strokeEndAnim.fromValue = 0;
        strokeEndAnim.toValue   = 1.1;
        strokeEndAnim.duration  = 1.98
        strokeEndAnim.beginTime = 1.11
        
        var hiddenAnim       = CABasicAnimation(keyPath:"hidden")
        hiddenAnim.fromValue = true;
        hiddenAnim.toValue   = false;
        hiddenAnim.duration  = 2.23
        
        var roundedrectAnimGroup        = CAAnimationGroup()
        roundedrectAnimGroup.animations = [strokeEndAnim, hiddenAnim]
        roundedrectAnimGroup.animations.map{$0.setValue(kCAFillModeForwards, forKeyPath:"fillMode")}
        roundedrectAnimGroup.fillMode   = kCAFillModeForwards
        roundedrectAnimGroup.removedOnCompletion = false
        roundedrectAnimGroup.duration = QCMethod.maxDurationFromAnimations(roundedrectAnimGroup.animations as [CAAnimation])
        
        
        return roundedrectAnimGroup;
    }
    
    func pathAnimation() -> CAAnimationGroup{
        var transformAnim       = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values    = [NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)),
            NSValue(CATransform3D: CATransform3DIdentity),
            NSValue(CATransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes  = [0, 0.479, 1]
        transformAnim.duration  = 0.491
        transformAnim.beginTime = 2.9
        
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1.1]
        strokeEndAnim.keyTimes = [0, 0.976, 1]
        strokeEndAnim.duration = 2.9
        
        var path5AnimGroup                 = CAAnimationGroup()
        path5AnimGroup.animations          = [transformAnim, strokeEndAnim]
        path5AnimGroup.animations.map{$0.setValue(kCAFillModeForwards, forKeyPath:"fillMode")}
        path5AnimGroup.fillMode            = kCAFillModeForwards
        path5AnimGroup.removedOnCompletion = false
        path5AnimGroup.duration = QCMethod.maxDurationFromAnimations(path5AnimGroup.animations as [CAAnimation])
        
        
        return path5AnimGroup;
    }
    
    func ovalAnimation() -> CAAnimationGroup{
        var strokeEndAnim       = CABasicAnimation(keyPath:"strokeEnd")
        strokeEndAnim.fromValue = 0;
        strokeEndAnim.toValue   = 1;
        strokeEndAnim.duration  = 1.97
        strokeEndAnim.beginTime = 1.12
        
        var hiddenAnim       = CABasicAnimation(keyPath:"hidden")
        hiddenAnim.fromValue = true;
        hiddenAnim.toValue   = false;
        hiddenAnim.duration  = 2.22
        
        var ovalAnimGroup                 = CAAnimationGroup()
        ovalAnimGroup.animations          = [strokeEndAnim, hiddenAnim]
        ovalAnimGroup.animations.map{$0.setValue(kCAFillModeForwards, forKeyPath:"fillMode")}
        ovalAnimGroup.fillMode            = kCAFillModeForwards
        ovalAnimGroup.removedOnCompletion = false
        ovalAnimGroup.duration = QCMethod.maxDurationFromAnimations(ovalAnimGroup.animations as [CAAnimation])
        
        
        return ovalAnimGroup;
    }
    
    //MARK: - Bezier Path
    
    func roundedRectPath() -> UIBezierPath{
        var roundedRectPath = UIBezierPath()
        roundedRectPath.moveToPoint(CGPointMake(14, 0))
        roundedRectPath.addCurveToPoint(CGPointMake(0, 14), controlPoint1:CGPointMake(6.268, 0), controlPoint2:CGPointMake(0, 6.268))
        roundedRectPath.addLineToPoint(CGPointMake(0, 63.306))
        roundedRectPath.addCurveToPoint(CGPointMake(14, 77.306), controlPoint1:CGPointMake(0, 71.038), controlPoint2:CGPointMake(6.268, 77.306))
        roundedRectPath.addLineToPoint(CGPointMake(67.449, 77.306))
        roundedRectPath.addCurveToPoint(CGPointMake(81.449, 63.306), controlPoint1:CGPointMake(75.181, 77.306), controlPoint2:CGPointMake(81.449, 71.038))
        roundedRectPath.addLineToPoint(CGPointMake(81.449, 14))
        roundedRectPath.addCurveToPoint(CGPointMake(67.449, 0), controlPoint1:CGPointMake(81.449, 6.268), controlPoint2:CGPointMake(75.181, 0))
        roundedRectPath.closePath()
        roundedRectPath.moveToPoint(CGPointMake(14, 0))
        
        return roundedRectPath;
    }
    
    func pathPath() -> UIBezierPath{
        var pathPath = UIBezierPath()
        pathPath.moveToPoint(CGPointMake(5.315, 20.976))
        pathPath.addCurveToPoint(CGPointMake(0, 11.389), controlPoint1:CGPointMake(2.118, 18.95), controlPoint2:CGPointMake(0, 15.413))
        pathPath.addCurveToPoint(CGPointMake(11.557, 0), controlPoint1:CGPointMake(0, 5.099), controlPoint2:CGPointMake(5.174, 0))
        pathPath.addCurveToPoint(CGPointMake(23.114, 11.389), controlPoint1:CGPointMake(17.94, 0), controlPoint2:CGPointMake(23.114, 5.099))
        pathPath.addCurveToPoint(CGPointMake(17.929, 20.892), controlPoint1:CGPointMake(23.114, 15.358), controlPoint2:CGPointMake(21.054, 18.853))
        pathPath.addLineToPoint(CGPointMake(21.645, 34.077))
        pathPath.addCurveToPoint(CGPointMake(17.231, 38.384), controlPoint1:CGPointMake(21.645, 36.455), controlPoint2:CGPointMake(19.669, 38.384))
        pathPath.addLineToPoint(CGPointMake(6.423, 38.384))
        pathPath.addCurveToPoint(CGPointMake(2.009, 34.077), controlPoint1:CGPointMake(3.985, 38.384), controlPoint2:CGPointMake(2.009, 36.455))
        pathPath.addLineToPoint(CGPointMake(5.315, 20.976))
        pathPath.closePath()
        pathPath.moveToPoint(CGPointMake(5.315, 20.976))
        
        return pathPath;
    }
    
    func ovalPath() -> UIBezierPath{
        var ovalPath = UIBezierPath()
        ovalPath.moveToPoint(CGPointMake(30.335, 0))
        ovalPath.addCurveToPoint(CGPointMake(0, 26.851), controlPoint1:CGPointMake(13.581, 0), controlPoint2:CGPointMake(0, 12.022))
        ovalPath.addLineToPoint(CGPointMake(0, 53.703))
        ovalPath.moveToPoint(CGPointMake(60.669, 53.703))
        ovalPath.addLineToPoint(CGPointMake(60.669, 26.851))
        ovalPath.addCurveToPoint(CGPointMake(30.335, 0), controlPoint1:CGPointMake(60.669, 12.022), controlPoint2:CGPointMake(47.088, 0))
        
        return ovalPath;
    }
    
}