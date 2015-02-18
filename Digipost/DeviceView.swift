//
//  DeviceView.swift
//
//  Code generated using QuartzCode on 2015-02-18.
//  www.quartzcodeapp.com
//

import UIKit

class DeviceView: UIView {
    
    var layerWithAnims : [CALayer]!
    var animationAdded : Bool = false
    var phone : CALayer!
    var roundedrect : CAShapeLayer!
    var oval : CAShapeLayer!
    var roundedrect2 : CAShapeLayer!
    var desktop : CALayer!
    var roundedrect3 : CAShapeLayer!
    var rectangle : CAShapeLayer!
    var oval2 : CAShapeLayer!
    var tablet : CALayer!
    var roundedrect4 : CAShapeLayer!
    var oval3 : CAShapeLayer!
    var roundedrect5 : CAShapeLayer!
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
        phone = CALayer()
        self.layer.addSublayer(phone)
        
        
        roundedrect = CAShapeLayer()
        phone.addSublayer(roundedrect)
        roundedrect.setValue(90 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        roundedrect.fillColor   = nil
        roundedrect.strokeColor = UIColor.blackColor().CGColor
        roundedrect.lineWidth   = 3
        
        oval = CAShapeLayer()
        phone.addSublayer(oval)
        oval.fillColor = UIColor.blackColor().CGColor
        oval.lineWidth = 0
        
        roundedrect2 = CAShapeLayer()
        phone.addSublayer(roundedrect2)
        roundedrect2.setValue(90 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        roundedrect2.fillColor   = nil
        roundedrect2.strokeColor = UIColor.blackColor().CGColor
        
        desktop = CALayer()
        self.layer.addSublayer(desktop)
        
        
        roundedrect3 = CAShapeLayer()
        desktop.addSublayer(roundedrect3)
        roundedrect3.fillColor   = nil
        roundedrect3.strokeColor = UIColor.blackColor().CGColor
        roundedrect3.lineWidth   = 3
        
        rectangle = CAShapeLayer()
        desktop.addSublayer(rectangle)
        rectangle.fillColor   = nil
        rectangle.strokeColor = UIColor.blackColor().CGColor
        rectangle.lineWidth   = 3
        
        oval2 = CAShapeLayer()
        desktop.addSublayer(oval2)
        oval2.fillColor = UIColor.blackColor().CGColor
        oval2.lineWidth = 0
        
        tablet = CALayer()
        self.layer.addSublayer(tablet)
        
        
        roundedrect4 = CAShapeLayer()
        tablet.addSublayer(roundedrect4)
        roundedrect4.fillColor   = nil
        roundedrect4.strokeColor = UIColor.blackColor().CGColor
        roundedrect4.lineWidth   = 3
        
        oval3 = CAShapeLayer()
        tablet.addSublayer(oval3)
        oval3.fillColor = UIColor.blackColor().CGColor
        oval3.lineWidth = 0
        
        roundedrect5 = CAShapeLayer()
        tablet.addSublayer(roundedrect5)
        roundedrect5.fillColor   = nil
        roundedrect5.strokeColor = UIColor.blackColor().CGColor
        
        animationText = CATextLayer()
        self.layer.addSublayer(animationText)
        animationText.contentsScale   = UIScreen.mainScreen().scale
        animationText.string          = "Hello World!"
        animationText.font            = "HelveticaNeue"
        animationText.fontSize        = 17
        animationText.alignmentMode   = kCAAlignmentCenter;
        animationText.foregroundColor = UIColor.blackColor().CGColor;
        
        setupLayerFrames()
        
        self.layerWithAnims = [phone, roundedrect, oval, roundedrect2, desktop, roundedrect3, rectangle, oval2, tablet, roundedrect4, oval3, roundedrect5, animationText]
    }
    
    
    func setupLayerFrames(){
        if phone != nil{
            phone.frame = CGRectMake(0.67614 * phone.superlayer.bounds.width, 0.398 * phone.superlayer.bounds.height, 0.10292 * phone.superlayer.bounds.width, 0.13317 * phone.superlayer.bounds.height)
        }
        if roundedrect != nil{
            roundedrect.setValue(0, forKeyPath:"transform.rotation")
            roundedrect.frame = CGRectMake(0.20395 * roundedrect.superlayer.bounds.width, 0, 0.63355 * roundedrect.superlayer.bounds.width,  roundedrect.superlayer.bounds.height)
            roundedrect.setValue(90 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
            roundedrect.path  = roundedRectPathWithBounds(roundedrect.bounds).CGPath;
        }
        if oval != nil{
            oval.frame = CGRectMake(0.88062 * oval.superlayer.bounds.width, 0.44017 * oval.superlayer.bounds.height, 0.11938 * oval.superlayer.bounds.width, 0.11966 * oval.superlayer.bounds.height)
            oval.path  = ovalPathWithBounds(oval.bounds).CGPath;
        }
        if roundedrect2 != nil{
            roundedrect2.setValue(0, forKeyPath:"transform.rotation")
            roundedrect2.frame = CGRectMake(0, 0.49131 * roundedrect2.superlayer.bounds.height, 0.16624 * roundedrect2.superlayer.bounds.width, 0.01739 * roundedrect2.superlayer.bounds.height)
            roundedrect2.setValue(90 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
            roundedrect2.path  = roundedRect2PathWithBounds(roundedrect2.bounds).CGPath;
        }
        if desktop != nil{
            desktop.frame = CGRectMake(0.2006 * desktop.superlayer.bounds.width, 0.23108 * desktop.superlayer.bounds.height, 0.30287 * desktop.superlayer.bounds.width, 0.33384 * desktop.superlayer.bounds.height)
        }
        if roundedrect3 != nil{
            roundedrect3.frame = CGRectMake(0, 0,  roundedrect3.superlayer.bounds.width, 0.68901 * roundedrect3.superlayer.bounds.height)
            roundedrect3.path  = roundedRect3PathWithBounds(roundedrect3.bounds).CGPath;
        }
        if rectangle != nil{
            rectangle.frame = CGRectMake(0.3778 * rectangle.superlayer.bounds.width, 0.73661 * rectangle.superlayer.bounds.height, 0.25178 * rectangle.superlayer.bounds.width, 0.26339 * rectangle.superlayer.bounds.height)
            rectangle.path  = rectanglePathWithBounds(rectangle.bounds).CGPath;
        }
        if oval2 != nil{
            oval2.frame = CGRectMake(0.48239 * oval2.superlayer.bounds.width, 0.04933 * oval2.superlayer.bounds.height, 0.03522 * oval2.superlayer.bounds.width, 0.03468 * oval2.superlayer.bounds.height)
            oval2.path  = oval2PathWithBounds(oval2.bounds).CGPath;
        }
        if tablet != nil{
            tablet.frame = CGRectMake(0.53199 * tablet.superlayer.bounds.width, 0.30458 * tablet.superlayer.bounds.height, 0.10965 * tablet.superlayer.bounds.width, 0.19542 * tablet.superlayer.bounds.height)
        }
        if roundedrect4 != nil{
            roundedrect4.frame = CGRectMake(0, 0,  roundedrect4.superlayer.bounds.width,  roundedrect4.superlayer.bounds.height)
            roundedrect4.path  = roundedRect4PathWithBounds(roundedrect4.bounds).CGPath;
        }
        if oval3 != nil{
            oval3.frame = CGRectMake(0.4075 * oval3.superlayer.bounds.width, 0.87033 * oval3.superlayer.bounds.height, 0.13637 * oval3.superlayer.bounds.width, 0.09686 * oval3.superlayer.bounds.height)
            oval3.path  = oval3PathWithBounds(oval3.bounds).CGPath;
        }
        if roundedrect5 != nil{
            roundedrect5.frame = CGRectMake(0.28823 * roundedrect5.superlayer.bounds.width, 0.08008 * roundedrect5.superlayer.bounds.height, 0.3749 * roundedrect5.superlayer.bounds.width, 0.01185 * roundedrect5.superlayer.bounds.height)
            roundedrect5.path  = roundedRect5PathWithBounds(roundedrect5.bounds).CGPath;
        }
        if animationText != nil{
            animationText.frame = CGRectMake(0.0046 * animationText.superlayer.bounds.width, 0.61859 * animationText.superlayer.bounds.height, 0.99165 * animationText.superlayer.bounds.width, 0.34187 * animationText.superlayer.bounds.height)
        }
    }
    
    
    @IBAction func startAllAnimations(sender: AnyObject!){
        self.animationAdded = false
        for layer in self.layerWithAnims{
            layer.speed = 1
        }
        phone?.addAnimation(phoneAnimation(), forKey:"phoneAnimation")
        roundedrect?.addAnimation(roundedRectAnimation(), forKey:"roundedRectAnimation")
        oval?.addAnimation(ovalAnimation(), forKey:"ovalAnimation")
        roundedrect2?.addAnimation(roundedRect2Animation(), forKey:"roundedRect2Animation")
        
        roundedrect3?.addAnimation(roundedRect3Animation(), forKey:"roundedRect3Animation")
        rectangle?.addAnimation(rectangleAnimation(), forKey:"rectangleAnimation")
        oval2?.addAnimation(oval2Animation(), forKey:"oval2Animation")
        tablet?.addAnimation(tabletAnimation(), forKey:"tabletAnimation")
        roundedrect4?.addAnimation(roundedRect4Animation(), forKey:"roundedRect4Animation")
        oval3?.addAnimation(oval3Animation(), forKey:"oval3Animation")
        roundedrect5?.addAnimation(roundedRect5Animation(), forKey:"roundedRect5Animation")
    }
    
    
    @IBAction func startReverseAnimations(sender: AnyObject!){
        self.animationAdded = false
        for layer in self.layerWithAnims{
            layer.speed = 1
        }
        var totalDuration = CGFloat(4)
        phone?.addAnimation(QCMethod.reverseAnimation(phoneAnimation(), totalDuration:totalDuration), forKey:"phoneAnimation")
        roundedrect?.addAnimation(QCMethod.reverseAnimation(roundedRectAnimation(), totalDuration:totalDuration), forKey:"roundedRectAnimation")
        oval?.addAnimation(QCMethod.reverseAnimation(ovalAnimation(), totalDuration:totalDuration), forKey:"ovalAnimation")
        roundedrect2?.addAnimation(QCMethod.reverseAnimation(roundedRect2Animation(), totalDuration:totalDuration), forKey:"roundedRect2Animation")
        
        roundedrect3?.addAnimation(QCMethod.reverseAnimation(roundedRect3Animation(), totalDuration:totalDuration), forKey:"roundedRect3Animation")
        rectangle?.addAnimation(QCMethod.reverseAnimation(rectangleAnimation(), totalDuration:totalDuration), forKey:"rectangleAnimation")
        oval2?.addAnimation(QCMethod.reverseAnimation(oval2Animation(), totalDuration:totalDuration), forKey:"oval2Animation")
        tablet?.addAnimation(QCMethod.reverseAnimation(tabletAnimation(), totalDuration:totalDuration), forKey:"tabletAnimation")
        roundedrect4?.addAnimation(QCMethod.reverseAnimation(roundedRect4Animation(), totalDuration:totalDuration), forKey:"roundedRect4Animation")
        oval3?.addAnimation(QCMethod.reverseAnimation(oval3Animation(), totalDuration:totalDuration), forKey:"oval3Animation")
        roundedrect5?.addAnimation(QCMethod.reverseAnimation(roundedRect5Animation(), totalDuration:totalDuration), forKey:"roundedRect5Animation")
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
                var totalDuration : CGFloat = 4
                var offset = progress * totalDuration
                for layer in self.layerWithAnims{
                    layer.timeOffset = CFTimeInterval(offset)
                }
            }
        }
    }
    
    func phoneAnimation() -> CAAnimationGroup{
        var positionAnim       = CABasicAnimation(keyPath:"position")
        positionAnim.toValue   = NSValue(CGPoint: CGPointMake(0.7276 * phone.superlayer.bounds.width, 0.53892 * phone.superlayer.bounds.height));
        positionAnim.duration  = 0.342
        positionAnim.beginTime = 3.11
        
        var GroupAnimGroup                 = CAAnimationGroup()
        GroupAnimGroup.animations          = [positionAnim]
        GroupAnimGroup.animations.map{$0.setValue(kCAFillModeForwards, forKeyPath:"fillMode")}
        GroupAnimGroup.fillMode            = kCAFillModeForwards
        GroupAnimGroup.removedOnCompletion = false
        GroupAnimGroup.duration = QCMethod.maxDurationFromAnimations(GroupAnimGroup.animations as [CAAnimation])
        
        
        return GroupAnimGroup;
    }
    
    func roundedRectAnimation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.677, 1]
        strokeEndAnim.duration = 3.09
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func ovalAnimation() -> CAKeyframeAnimation{
        var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 1.2)),
            NSValue(CATransform3D: CATransform3DMakeScale(1.2, 1.2, 1.2)),
            NSValue(CATransform3D: CATransform3DMakeScale(0.6, 0.6, 0.6))]
        transformAnim.keyTimes = [0, 0.913, 0.957, 1]
        transformAnim.duration = 4
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.removedOnCompletion = false
        
        return transformAnim;
    }
    
    func roundedRect2Animation() -> CAKeyframeAnimation{
        var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0, 0, 0), CATransform3DMakeRotation(-CGFloat(M_PI_2), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0, 0, 0), CATransform3DMakeRotation(-CGFloat(M_PI_2), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(1.1, 1.1, 1.5), CATransform3DMakeRotation(-CGFloat(M_PI_2), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0.7, 1, 1), CATransform3DMakeRotation(-CGFloat(M_PI_2), 0, 0, 1)))]
        transformAnim.keyTimes = [0, 0.912, 0.954, 1]
        transformAnim.duration = 3.9
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.removedOnCompletion = false
        
        return transformAnim;
    }
    
    func roundedRect3Animation() -> CABasicAnimation{
        var strokeEndAnim       = CABasicAnimation(keyPath:"strokeEnd")
        strokeEndAnim.fromValue = 0;
        strokeEndAnim.toValue   = 1;
        strokeEndAnim.duration  = 1.08
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func rectangleAnimation() -> CAAnimationGroup{
        var strokeEndAnim       = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values    = [0, 1]
        strokeEndAnim.keyTimes  = [0, 1]
        strokeEndAnim.duration  = 1.03
        strokeEndAnim.beginTime = 0.151
        
        var rectangleAnimGroup                 = CAAnimationGroup()
        rectangleAnimGroup.animations          = [strokeEndAnim]
        rectangleAnimGroup.animations.map{$0.setValue(kCAFillModeForwards, forKeyPath:"fillMode")}
        rectangleAnimGroup.fillMode            = kCAFillModeForwards
        rectangleAnimGroup.removedOnCompletion = false
        rectangleAnimGroup.duration = QCMethod.maxDurationFromAnimations(rectangleAnimGroup.animations as [CAAnimation])
        
        
        return rectangleAnimGroup;
    }
    
    func oval2Animation() -> CAKeyframeAnimation{
        var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)),
            NSValue(CATransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes = [0, 0.767, 0.869, 1]
        transformAnim.duration = 1.6
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.removedOnCompletion = false
        
        return transformAnim;
    }
    
    func tabletAnimation() -> CAAnimationGroup{
        var positionAnim       = CABasicAnimation(keyPath:"position")
        positionAnim.toValue   = NSValue(CGPoint: CGPointMake(0.58682 * tablet.superlayer.bounds.width, 0.47904 * tablet.superlayer.bounds.height));
        positionAnim.duration  = 0.312
        positionAnim.beginTime = 2.11
        
        var GroupAnimGroup                 = CAAnimationGroup()
        GroupAnimGroup.animations          = [positionAnim]
        GroupAnimGroup.animations.map{$0.setValue(kCAFillModeForwards, forKeyPath:"fillMode")}
        GroupAnimGroup.fillMode            = kCAFillModeForwards
        GroupAnimGroup.removedOnCompletion = false
        GroupAnimGroup.duration = QCMethod.maxDurationFromAnimations(GroupAnimGroup.animations as [CAAnimation])
        
        
        return GroupAnimGroup;
    }
    
    func roundedRect4Animation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.528, 1]
        strokeEndAnim.duration = 2.08
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func oval3Animation() -> CAKeyframeAnimation{
        var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)),
            NSValue(CATransform3D: CATransform3DMakeScale(0.8, 0.8, 1))]
        transformAnim.keyTimes = [0, 0.905, 0.95, 1]
        transformAnim.duration = 2.7
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.removedOnCompletion = false
        
        return transformAnim;
    }
    
    func roundedRect5Animation() -> CAKeyframeAnimation{
        var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0, 0, 0), CATransform3DMakeRotation(-CGFloat(M_PI), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0, 0, 0), CATransform3DMakeRotation(-CGFloat(M_PI), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(1.5, 1.5, 1.5), CATransform3DMakeRotation(-CGFloat(M_PI), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0.4, 1, 1), CATransform3DMakeRotation(-CGFloat(M_PI), 0, 0, 1)))]
        transformAnim.keyTimes = [0, 0.875, 0.944, 1]
        transformAnim.duration = 2.79
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.removedOnCompletion = false
        
        return transformAnim;
    }
    
    //MARK: - Bezier Path
    
    func roundedRectPathWithBounds(bound: CGRect) -> UIBezierPath{
        var roundedRectPath = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        roundedRectPath.moveToPoint(CGPointMake(minX + 0.15798 * w, minY))
        roundedRectPath.addCurveToPoint(CGPointMake(minX, minY + 0.09999 * h), controlPoint1:CGPointMake(minX + 0.07073 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.04477 * h))
        roundedRectPath.addLineToPoint(CGPointMake(minX, minY + 0.90001 * h))
        roundedRectPath.addCurveToPoint(CGPointMake(minX + 0.15798 * w, minY + h), controlPoint1:CGPointMake(minX, minY + 0.95523 * h), controlPoint2:CGPointMake(minX + 0.07073 * w, minY + h))
        roundedRectPath.addLineToPoint(CGPointMake(minX + 0.84202 * w, minY + h))
        roundedRectPath.addCurveToPoint(CGPointMake(minX + w, minY + 0.90001 * h), controlPoint1:CGPointMake(minX + 0.92927 * w, minY + h), controlPoint2:CGPointMake(minX + w, minY + 0.95523 * h))
        roundedRectPath.addLineToPoint(CGPointMake(minX + w, minY + 0.09999 * h))
        roundedRectPath.addCurveToPoint(CGPointMake(minX + 0.84202 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.04477 * h), controlPoint2:CGPointMake(minX + 0.92927 * w, minY))
        roundedRectPath.closePath()
        roundedRectPath.moveToPoint(CGPointMake(minX + 0.15798 * w, minY))
        
        return roundedRectPath;
    }
    
    func ovalPathWithBounds(bound: CGRect) -> UIBezierPath{
        var ovalPath = UIBezierPath(ovalInRect: bound)
        return ovalPath;
    }
    
    func roundedRect2PathWithBounds(bound: CGRect) -> UIBezierPath{
        var roundedRect2Path = UIBezierPath(roundedRect:bound, cornerRadius:1)
        return roundedRect2Path;
    }
    
    func roundedRect3PathWithBounds(bound: CGRect) -> UIBezierPath{
        var roundedRect3Path = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        roundedRect3Path.moveToPoint(CGPointMake(minX + 0.17609 * w, minY))
        roundedRect3Path.addCurveToPoint(CGPointMake(minX, minY + 0.26033 * h), controlPoint1:CGPointMake(minX + 0.07884 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.11655 * h))
        roundedRect3Path.addLineToPoint(CGPointMake(minX, minY + 0.73967 * h))
        roundedRect3Path.addCurveToPoint(CGPointMake(minX + 0.17609 * w, minY + h), controlPoint1:CGPointMake(minX, minY + 0.88345 * h), controlPoint2:CGPointMake(minX + 0.07884 * w, minY + h))
        roundedRect3Path.addLineToPoint(CGPointMake(minX + 0.82391 * w, minY + h))
        roundedRect3Path.addCurveToPoint(CGPointMake(minX + w, minY + 0.73967 * h), controlPoint1:CGPointMake(minX + 0.92116 * w, minY + h), controlPoint2:CGPointMake(minX + w, minY + 0.88345 * h))
        roundedRect3Path.addLineToPoint(CGPointMake(minX + w, minY + 0.26033 * h))
        roundedRect3Path.addCurveToPoint(CGPointMake(minX + 0.82391 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.11655 * h), controlPoint2:CGPointMake(minX + 0.92116 * w, minY))
        roundedRect3Path.closePath()
        roundedRect3Path.moveToPoint(CGPointMake(minX + 0.17609 * w, minY))
        
        return roundedRect3Path;
    }
    
    func rectanglePathWithBounds(bound: CGRect) -> UIBezierPath{
        var rectanglePath = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        rectanglePath.moveToPoint(CGPointMake(minX + 0.02019 * w, minY + h))
        rectanglePath.addCurveToPoint(CGPointMake(minX + 0.00724 * w, minY + h), controlPoint1:CGPointMake(minX + 0.02743 * w, minY + h), controlPoint2:CGPointMake(minX, minY + h))
        rectanglePath.addCurveToPoint(CGPointMake(minX + w, minY + h), controlPoint1:CGPointMake(minX + 0.24495 * w, minY + h), controlPoint2:CGPointMake(minX + 0.76228 * w, minY + h))
        rectanglePath.addLineToPoint(CGPointMake(minX + 0.75293 * w, minY))
        rectanglePath.addLineToPoint(CGPointMake(minX + 0.21788 * w, minY))
        rectanglePath.addLineToPoint(CGPointMake(minX, minY + 0.99998 * h))
        rectanglePath.addLineToPoint(CGPointMake(minX + 0.02019 * w, minY + h))
        rectanglePath.closePath()
        rectanglePath.moveToPoint(CGPointMake(minX + 0.02019 * w, minY + h))
        
        return rectanglePath;
    }
    
    func oval2PathWithBounds(bound: CGRect) -> UIBezierPath{
        var oval2Path = UIBezierPath(ovalInRect: bound)
        return oval2Path;
    }
    
    func roundedRect4PathWithBounds(bound: CGRect) -> UIBezierPath{
        var roundedRect4Path = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        roundedRect4Path.moveToPoint(CGPointMake(minX + 0.17023 * w, minY))
        roundedRect4Path.addCurveToPoint(CGPointMake(minX, minY + 0.10725 * h), controlPoint1:CGPointMake(minX + 0.07622 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.04802 * h))
        roundedRect4Path.addLineToPoint(CGPointMake(minX, minY + 0.89275 * h))
        roundedRect4Path.addCurveToPoint(CGPointMake(minX + 0.17023 * w, minY + h), controlPoint1:CGPointMake(minX, minY + 0.95198 * h), controlPoint2:CGPointMake(minX + 0.07622 * w, minY + h))
        roundedRect4Path.addLineToPoint(CGPointMake(minX + 0.82977 * w, minY + h))
        roundedRect4Path.addCurveToPoint(CGPointMake(minX + w, minY + 0.89275 * h), controlPoint1:CGPointMake(minX + 0.92378 * w, minY + h), controlPoint2:CGPointMake(minX + w, minY + 0.95198 * h))
        roundedRect4Path.addLineToPoint(CGPointMake(minX + w, minY + 0.10725 * h))
        roundedRect4Path.addCurveToPoint(CGPointMake(minX + 0.82977 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.04802 * h), controlPoint2:CGPointMake(minX + 0.92378 * w, minY))
        roundedRect4Path.closePath()
        roundedRect4Path.moveToPoint(CGPointMake(minX + 0.17023 * w, minY))
        
        return roundedRect4Path;
    }
    
    func oval3PathWithBounds(bound: CGRect) -> UIBezierPath{
        var oval3Path = UIBezierPath(ovalInRect: bound)
        return oval3Path;
    }
    
    func roundedRect5PathWithBounds(bound: CGRect) -> UIBezierPath{
        var roundedRect5Path = UIBezierPath(roundedRect:bound, cornerRadius:1)
        return roundedRect5Path;
    }
    
}