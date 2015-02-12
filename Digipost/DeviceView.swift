//
//  DeviceView.swift
//
//  Code generated using QuartzCode on 2015-02-11.
//  www.quartzcodeapp.com
//

import UIKit

class DeviceView: UIView {
    
    var layerWithAnims : [CALayer]!
    var animationAdded : Bool = false
    var deviceView : CALayer!
    var desktop : CALayer!
    var roundedrect : CAShapeLayer!
    var rectangle : CAShapeLayer!
    var oval : CAShapeLayer!
    var tablet : CALayer!
    var roundedrect2 : CAShapeLayer!
    var oval2 : CAShapeLayer!
    var roundedrect3 : CAShapeLayer!
    var phone : CALayer!
    var roundedrect4 : CAShapeLayer!
    var oval3 : CAShapeLayer!
    var roundedrect5 : CAShapeLayer!
    
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
        deviceView = CALayer()
        self.layer.addSublayer(deviceView)
        deviceView.backgroundColor = UIColor(red:0.671, green: 0.745, blue:0.855, alpha:0).CGColor
        
        desktop = CALayer()
        deviceView.addSublayer(desktop)
        
        
        roundedrect = CAShapeLayer()
        desktop.addSublayer(roundedrect)
        roundedrect.fillColor   = nil
        roundedrect.strokeColor = UIColor.blackColor().CGColor
        roundedrect.lineWidth   = 3
        
        rectangle = CAShapeLayer()
        desktop.addSublayer(rectangle)
        rectangle.fillColor   = nil
        rectangle.strokeColor = UIColor.blackColor().CGColor
        rectangle.lineWidth   = 3
        
        oval = CAShapeLayer()
        desktop.addSublayer(oval)
        oval.fillColor = UIColor.blackColor().CGColor
        oval.lineWidth = 0
        
        tablet = CALayer()
        deviceView.addSublayer(tablet)
        
        
        roundedrect2 = CAShapeLayer()
        tablet.addSublayer(roundedrect2)
        roundedrect2.fillColor   = nil
        roundedrect2.strokeColor = UIColor.blackColor().CGColor
        roundedrect2.lineWidth   = 3
        
        oval2 = CAShapeLayer()
        tablet.addSublayer(oval2)
        oval2.fillColor = UIColor.blackColor().CGColor
        oval2.lineWidth = 0
        
        roundedrect3 = CAShapeLayer()
        tablet.addSublayer(roundedrect3)
        roundedrect3.fillColor   = nil
        roundedrect3.strokeColor = UIColor.blackColor().CGColor
        
        phone = CALayer()
        deviceView.addSublayer(phone)
        
        
        roundedrect4 = CAShapeLayer()
        phone.addSublayer(roundedrect4)
        roundedrect4.setValue(90 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        roundedrect4.fillColor   = nil
        roundedrect4.strokeColor = UIColor.blackColor().CGColor
        roundedrect4.lineWidth   = 3
        
        oval3 = CAShapeLayer()
        phone.addSublayer(oval3)
        oval3.fillColor = UIColor.blackColor().CGColor
        oval3.lineWidth = 0
        
        roundedrect5 = CAShapeLayer()
        phone.addSublayer(roundedrect5)
        roundedrect5.setValue(90 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        roundedrect5.fillColor   = nil
        roundedrect5.strokeColor = UIColor.blackColor().CGColor
        
        setupLayerFrames()
        
        self.layerWithAnims = [deviceView, desktop, roundedrect, rectangle, oval, tablet, roundedrect2, oval2, roundedrect3, phone, roundedrect4, oval3, roundedrect5]
    }
    
    
    func setupLayerFrames(){
        if deviceView != nil{
            deviceView.frame = CGRectMake(0, 0.00351 * deviceView.superlayer.bounds.height, 0.99734 * deviceView.superlayer.bounds.width, 0.49401 * deviceView.superlayer.bounds.height)
        }
        if desktop != nil{
            desktop.frame = CGRectMake(0.19853 * desktop.superlayer.bounds.width, 0.3856 * desktop.superlayer.bounds.height, 0.30287 * desktop.superlayer.bounds.width, 0.33789 * desktop.superlayer.bounds.height)
        }
        if roundedrect != nil{
            roundedrect.frame = CGRectMake(0, 0,  roundedrect.superlayer.bounds.width, 0.68901 * roundedrect.superlayer.bounds.height)
            roundedrect.path  = roundedRectPathWithBounds(roundedrect.bounds).CGPath;
        }
        if rectangle != nil{
            rectangle.frame = CGRectMake(0.3778 * rectangle.superlayer.bounds.width, 0.73661 * rectangle.superlayer.bounds.height, 0.25178 * rectangle.superlayer.bounds.width, 0.26339 * rectangle.superlayer.bounds.height)
            rectangle.path  = rectanglePathWithBounds(rectangle.bounds).CGPath;
        }
        if oval != nil{
            oval.frame = CGRectMake(0.48239 * oval.superlayer.bounds.width, 0.04933 * oval.superlayer.bounds.height, 0.03522 * oval.superlayer.bounds.width, 0.03468 * oval.superlayer.bounds.height)
            oval.path  = ovalPathWithBounds(oval.bounds).CGPath;
        }
        if tablet != nil{
            tablet.frame = CGRectMake(0.6316 * tablet.superlayer.bounds.width, 0.5257 * tablet.superlayer.bounds.height, 0.10965 * tablet.superlayer.bounds.width, 0.19779 * tablet.superlayer.bounds.height)
        }
        if roundedrect2 != nil{
            roundedrect2.frame = CGRectMake(0, 0,  roundedrect2.superlayer.bounds.width,  roundedrect2.superlayer.bounds.height)
            roundedrect2.path  = roundedRect2PathWithBounds(roundedrect2.bounds).CGPath;
        }
        if oval2 != nil{
            oval2.frame = CGRectMake(0.4075 * oval2.superlayer.bounds.width, 0.87033 * oval2.superlayer.bounds.height, 0.13637 * oval2.superlayer.bounds.width, 0.09686 * oval2.superlayer.bounds.height)
            oval2.path  = oval2PathWithBounds(oval2.bounds).CGPath;
        }
        if roundedrect3 != nil{
            roundedrect3.frame = CGRectMake(0.28823 * roundedrect3.superlayer.bounds.width, 0.08008 * roundedrect3.superlayer.bounds.height, 0.3749 * roundedrect3.superlayer.bounds.width, 0.01185 * roundedrect3.superlayer.bounds.height)
            roundedrect3.path  = roundedRect3PathWithBounds(roundedrect3.bounds).CGPath;
        }
        if phone != nil{
            phone.frame = CGRectMake(0.83853 * phone.superlayer.bounds.width, 0.6155 * phone.superlayer.bounds.height, 0.10745 * phone.superlayer.bounds.width, 0.13478 * phone.superlayer.bounds.height)
        }
        if roundedrect4 != nil{
            roundedrect4.setValue(0, forKeyPath:"transform.rotation")
            roundedrect4.frame = CGRectMake(0.33681 * roundedrect4.superlayer.bounds.width, 0, 0.60682 * roundedrect4.superlayer.bounds.width,  roundedrect4.superlayer.bounds.height)
            roundedrect4.setValue(90 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
            roundedrect4.path  = roundedRect4PathWithBounds(roundedrect4.bounds).CGPath;
        }
        if oval3 != nil{
            oval3.frame = CGRectMake(0.98493 * oval3.superlayer.bounds.width, 0.44017 * oval3.superlayer.bounds.height, 0.11434 * oval3.superlayer.bounds.width, 0.11966 * oval3.superlayer.bounds.height)
            oval3.path  = oval3PathWithBounds(oval3.bounds).CGPath;
        }
        if roundedrect5 != nil{
            roundedrect5.setValue(0, forKeyPath:"transform.rotation")
            roundedrect5.frame = CGRectMake(0.14146 * roundedrect5.superlayer.bounds.width, 0.49131 * roundedrect5.superlayer.bounds.height, 0.15923 * roundedrect5.superlayer.bounds.width, 0.01739 * roundedrect5.superlayer.bounds.height)
            roundedrect5.setValue(90 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
            roundedrect5.path  = roundedRect5PathWithBounds(roundedrect5.bounds).CGPath;
        }
    }
    
    
    @IBAction func startAllAnimations(sender: AnyObject!){
        self.animationAdded = false
        for layer in self.layerWithAnims{
            layer.speed = 1
        }
        deviceView?.addAnimation(deviceViewAnimation(), forKey:"deviceViewAnimation")
        
        roundedrect?.addAnimation(roundedRectAnimation(), forKey:"roundedRectAnimation")
        rectangle?.addAnimation(rectangleAnimation(), forKey:"rectangleAnimation")
        oval?.addAnimation(ovalAnimation(), forKey:"ovalAnimation")
        tablet?.addAnimation(tabletAnimation(), forKey:"tabletAnimation")
        roundedrect2?.addAnimation(roundedRect2Animation(), forKey:"roundedRect2Animation")
        oval2?.addAnimation(oval2Animation(), forKey:"oval2Animation")
        roundedrect3?.addAnimation(roundedRect3Animation(), forKey:"roundedRect3Animation")
        phone?.addAnimation(phoneAnimation(), forKey:"phoneAnimation")
        roundedrect4?.addAnimation(roundedRect4Animation(), forKey:"roundedRect4Animation")
        oval3?.addAnimation(oval3Animation(), forKey:"oval3Animation")
        roundedrect5?.addAnimation(roundedRect5Animation(), forKey:"roundedRect5Animation")
    }
    
    
    @IBAction func startReverseAnimations(sender: AnyObject!){
        self.animationAdded = false
        for layer in self.layerWithAnims{
            layer.speed = 1
        }
        var totalDuration = CGFloat(6.16)
        deviceView?.addAnimation(QCMethod.reverseAnimation(deviceViewAnimation(), totalDuration:totalDuration), forKey:"deviceViewAnimation")
        
        roundedrect?.addAnimation(QCMethod.reverseAnimation(roundedRectAnimation(), totalDuration:totalDuration), forKey:"roundedRectAnimation")
        rectangle?.addAnimation(QCMethod.reverseAnimation(rectangleAnimation(), totalDuration:totalDuration), forKey:"rectangleAnimation")
        oval?.addAnimation(QCMethod.reverseAnimation(ovalAnimation(), totalDuration:totalDuration), forKey:"ovalAnimation")
        tablet?.addAnimation(QCMethod.reverseAnimation(tabletAnimation(), totalDuration:totalDuration), forKey:"tabletAnimation")
        roundedrect2?.addAnimation(QCMethod.reverseAnimation(roundedRect2Animation(), totalDuration:totalDuration), forKey:"roundedRect2Animation")
        oval2?.addAnimation(QCMethod.reverseAnimation(oval2Animation(), totalDuration:totalDuration), forKey:"oval2Animation")
        roundedrect3?.addAnimation(QCMethod.reverseAnimation(roundedRect3Animation(), totalDuration:totalDuration), forKey:"roundedRect3Animation")
        phone?.addAnimation(QCMethod.reverseAnimation(phoneAnimation(), totalDuration:totalDuration), forKey:"phoneAnimation")
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
                var totalDuration : CGFloat = 6.16
                var offset = progress * totalDuration
                for layer in self.layerWithAnims{
                    layer.timeOffset = CFTimeInterval(offset)
                }
            }
        }
    }
    
    func deviceViewAnimation() -> CAKeyframeAnimation{
        var positionAnim      = CAKeyframeAnimation(keyPath:"position")
        positionAnim.values   = [NSValue(CGPoint: CGPointMake(0.76596 * deviceView.superlayer.bounds.width, 0.25052 * deviceView.superlayer.bounds.height)), NSValue(CGPoint: CGPointMake(0.76596 * deviceView.superlayer.bounds.width, 0.25052 * deviceView.superlayer.bounds.height)), NSValue(CGPoint: CGPointMake(0.49867 * deviceView.superlayer.bounds.width, 0.25052 * deviceView.superlayer.bounds.height))]
        positionAnim.keyTimes = [0, 0.486, 1]
        positionAnim.duration = 3.09
        positionAnim.fillMode = kCAFillModeForwards
        positionAnim.removedOnCompletion = false
        
        return positionAnim;
    }
    
    func roundedRectAnimation() -> CABasicAnimation{
        var strokeEndAnim       = CABasicAnimation(keyPath:"strokeEnd")
        strokeEndAnim.fromValue = 0;
        strokeEndAnim.toValue   = 1;
        strokeEndAnim.duration  = 3.98
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func rectangleAnimation() -> CAAnimationGroup{
        var strokeEndAnim       = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values    = [0, 1]
        strokeEndAnim.keyTimes  = [0, 1]
        strokeEndAnim.duration  = 2.32
        strokeEndAnim.beginTime = 0.151
        
        var rectangleAnimGroup                 = CAAnimationGroup()
        rectangleAnimGroup.animations          = [strokeEndAnim]
        rectangleAnimGroup.animations.map{$0.setValue(kCAFillModeForwards, forKeyPath:"fillMode")}
        rectangleAnimGroup.fillMode            = kCAFillModeForwards
        rectangleAnimGroup.removedOnCompletion = false
        rectangleAnimGroup.duration = QCMethod.maxDurationFromAnimations(rectangleAnimGroup.animations as [CAAnimation])
        
        
        return rectangleAnimGroup;
    }
    
    func ovalAnimation() -> CAKeyframeAnimation{
        var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)),
            NSValue(CATransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes = [0, 0.911, 0.956, 1]
        transformAnim.duration = 4.41
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.removedOnCompletion = false
        
        return transformAnim;
    }
    
    func tabletAnimation() -> CAAnimationGroup{
        var positionAnim            = CAKeyframeAnimation(keyPath:"position")
        positionAnim.values         = [NSValue(CGPoint: CGPointMake(0.58667 * tablet.superlayer.bounds.width, 0.56865 * tablet.superlayer.bounds.height)), NSValue(CGPoint: CGPointMake(0.58667 * tablet.superlayer.bounds.width, 0.56865 * tablet.superlayer.bounds.height)), NSValue(CGPoint: CGPointMake(0.58667 * tablet.superlayer.bounds.width, 0.6246 * tablet.superlayer.bounds.height))]
        positionAnim.keyTimes       = [0, 0.56, 1]
        positionAnim.duration       = 1.28
        positionAnim.beginTime      = 2.93
        positionAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
        
        var GroupAnimGroup                 = CAAnimationGroup()
        GroupAnimGroup.animations          = [positionAnim]
        GroupAnimGroup.animations.map{$0.setValue(kCAFillModeForwards, forKeyPath:"fillMode")}
        GroupAnimGroup.fillMode            = kCAFillModeForwards
        GroupAnimGroup.removedOnCompletion = false
        GroupAnimGroup.duration = QCMethod.maxDurationFromAnimations(GroupAnimGroup.animations as [CAAnimation])
        
        
        return GroupAnimGroup;
    }
    
    func roundedRect2Animation() -> CAKeyframeAnimation{
        var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.772, 1]
        strokeEndAnim.duration = 4.13
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func oval2Animation() -> CAAnimationGroup{
        var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)),
            NSValue(CATransform3D: CATransform3DMakeScale(0.8, 0.8, 1))]
        transformAnim.keyTimes = [0, 0.931, 0.963, 1]
        transformAnim.duration = 4.44
        
        var hiddenAnim       = CABasicAnimation(keyPath:"hidden")
        hiddenAnim.fromValue = true;
        hiddenAnim.toValue   = false;
        hiddenAnim.duration  = 6.16
        
        var ovalAnimGroup                 = CAAnimationGroup()
        ovalAnimGroup.animations          = [transformAnim, hiddenAnim]
        ovalAnimGroup.animations.map{$0.setValue(kCAFillModeForwards, forKeyPath:"fillMode")}
        ovalAnimGroup.fillMode            = kCAFillModeForwards
        ovalAnimGroup.removedOnCompletion = false
        ovalAnimGroup.duration = QCMethod.maxDurationFromAnimations(ovalAnimGroup.animations as [CAAnimation])
        
        
        return ovalAnimGroup;
    }
    
    func roundedRect3Animation() -> CAKeyframeAnimation{
        var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0, 0, 0), CATransform3DMakeRotation(-CGFloat(M_PI), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0, 0, 0), CATransform3DMakeRotation(-CGFloat(M_PI), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(1.5, 1.5, 1.5), CATransform3DMakeRotation(-CGFloat(M_PI), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0.4, 1, 1), CATransform3DMakeRotation(-CGFloat(M_PI), 0, 0, 1)))]
        transformAnim.keyTimes = [0, 0.917, 0.958, 1]
        transformAnim.duration = 4.48
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.removedOnCompletion = false
        
        return transformAnim;
    }
    
    func phoneAnimation() -> CAAnimationGroup{
        var positionAnim            = CAKeyframeAnimation(keyPath:"position")
        positionAnim.values         = [NSValue(CGPoint: CGPointMake(0.72 * phone.superlayer.bounds.width, 0.62925 * phone.superlayer.bounds.height)), NSValue(CGPoint: CGPointMake(0.72 * phone.superlayer.bounds.width, 0.62925 * phone.superlayer.bounds.height)), NSValue(CGPoint: CGPointMake(0.72 * phone.superlayer.bounds.width, 0.6829 * phone.superlayer.bounds.height))]
        positionAnim.keyTimes       = [0, 0.505, 1]
        positionAnim.duration       = 1.24
        positionAnim.beginTime      = 4.12
        positionAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
        
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
        strokeEndAnim.keyTimes = [0, 0.809, 1]
        strokeEndAnim.duration = 5.08
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func oval3Animation() -> CAKeyframeAnimation{
        var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 1.2)),
            NSValue(CATransform3D: CATransform3DMakeScale(1.2, 1.2, 1.2)),
            NSValue(CATransform3D: CATransform3DMakeScale(0.6, 0.6, 0.6))]
        transformAnim.keyTimes = [0, 0.933, 0.969, 1]
        transformAnim.duration = 5.36
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.removedOnCompletion = false
        
        return transformAnim;
    }
    
    func roundedRect5Animation() -> CAKeyframeAnimation{
        var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0, 0, 0), CATransform3DMakeRotation(-CGFloat(M_PI_2), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0, 0, 0), CATransform3DMakeRotation(-CGFloat(M_PI_2), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(1.1, 1.1, 1.5), CATransform3DMakeRotation(-CGFloat(M_PI_2), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(0.7, 1, 1), CATransform3DMakeRotation(-CGFloat(M_PI_2), 0, 0, 1)))]
        transformAnim.keyTimes = [0, 0.93, 0.965, 1]
        transformAnim.duration = 5.39
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.removedOnCompletion = false
        
        return transformAnim;
    }
    
    //MARK: - Bezier Path
    
    func roundedRectPathWithBounds(bound: CGRect) -> UIBezierPath{
        var roundedRectPath = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        roundedRectPath.moveToPoint(CGPointMake(minX + 0.17609 * w, minY))
        roundedRectPath.addCurveToPoint(CGPointMake(minX, minY + 0.26033 * h), controlPoint1:CGPointMake(minX + 0.07884 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.11655 * h))
        roundedRectPath.addLineToPoint(CGPointMake(minX, minY + 0.73967 * h))
        roundedRectPath.addCurveToPoint(CGPointMake(minX + 0.17609 * w, minY + h), controlPoint1:CGPointMake(minX, minY + 0.88345 * h), controlPoint2:CGPointMake(minX + 0.07884 * w, minY + h))
        roundedRectPath.addLineToPoint(CGPointMake(minX + 0.82391 * w, minY + h))
        roundedRectPath.addCurveToPoint(CGPointMake(minX + w, minY + 0.73967 * h), controlPoint1:CGPointMake(minX + 0.92116 * w, minY + h), controlPoint2:CGPointMake(minX + w, minY + 0.88345 * h))
        roundedRectPath.addLineToPoint(CGPointMake(minX + w, minY + 0.26033 * h))
        roundedRectPath.addCurveToPoint(CGPointMake(minX + 0.82391 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.11655 * h), controlPoint2:CGPointMake(minX + 0.92116 * w, minY))
        roundedRectPath.closePath()
        roundedRectPath.moveToPoint(CGPointMake(minX + 0.17609 * w, minY))
        
        return roundedRectPath;
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
    
    func ovalPathWithBounds(bound: CGRect) -> UIBezierPath{
        var ovalPath = UIBezierPath(ovalInRect: bound)
        return ovalPath;
    }
    
    func roundedRect2PathWithBounds(bound: CGRect) -> UIBezierPath{
        var roundedRect2Path = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        roundedRect2Path.moveToPoint(CGPointMake(minX + 0.17023 * w, minY))
        roundedRect2Path.addCurveToPoint(CGPointMake(minX, minY + 0.10725 * h), controlPoint1:CGPointMake(minX + 0.07622 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.04802 * h))
        roundedRect2Path.addLineToPoint(CGPointMake(minX, minY + 0.89275 * h))
        roundedRect2Path.addCurveToPoint(CGPointMake(minX + 0.17023 * w, minY + h), controlPoint1:CGPointMake(minX, minY + 0.95198 * h), controlPoint2:CGPointMake(minX + 0.07622 * w, minY + h))
        roundedRect2Path.addLineToPoint(CGPointMake(minX + 0.82977 * w, minY + h))
        roundedRect2Path.addCurveToPoint(CGPointMake(minX + w, minY + 0.89275 * h), controlPoint1:CGPointMake(minX + 0.92378 * w, minY + h), controlPoint2:CGPointMake(minX + w, minY + 0.95198 * h))
        roundedRect2Path.addLineToPoint(CGPointMake(minX + w, minY + 0.10725 * h))
        roundedRect2Path.addCurveToPoint(CGPointMake(minX + 0.82977 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.04802 * h), controlPoint2:CGPointMake(minX + 0.92378 * w, minY))
        roundedRect2Path.closePath()
        roundedRect2Path.moveToPoint(CGPointMake(minX + 0.17023 * w, minY))
        
        return roundedRect2Path;
    }
    
    func oval2PathWithBounds(bound: CGRect) -> UIBezierPath{
        var oval2Path = UIBezierPath(ovalInRect: bound)
        return oval2Path;
    }
    
    func roundedRect3PathWithBounds(bound: CGRect) -> UIBezierPath{
        var roundedRect3Path = UIBezierPath(roundedRect:bound, cornerRadius:1)
        return roundedRect3Path;
    }
    
    func roundedRect4PathWithBounds(bound: CGRect) -> UIBezierPath{
        var roundedRect4Path = UIBezierPath()
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        roundedRect4Path.moveToPoint(CGPointMake(minX + 0.15798 * w, minY))
        roundedRect4Path.addCurveToPoint(CGPointMake(minX, minY + 0.09999 * h), controlPoint1:CGPointMake(minX + 0.07073 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.04477 * h))
        roundedRect4Path.addLineToPoint(CGPointMake(minX, minY + 0.90001 * h))
        roundedRect4Path.addCurveToPoint(CGPointMake(minX + 0.15798 * w, minY + h), controlPoint1:CGPointMake(minX, minY + 0.95523 * h), controlPoint2:CGPointMake(minX + 0.07073 * w, minY + h))
        roundedRect4Path.addLineToPoint(CGPointMake(minX + 0.84202 * w, minY + h))
        roundedRect4Path.addCurveToPoint(CGPointMake(minX + w, minY + 0.90001 * h), controlPoint1:CGPointMake(minX + 0.92927 * w, minY + h), controlPoint2:CGPointMake(minX + w, minY + 0.95523 * h))
        roundedRect4Path.addLineToPoint(CGPointMake(minX + w, minY + 0.09999 * h))
        roundedRect4Path.addCurveToPoint(CGPointMake(minX + 0.84202 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.04477 * h), controlPoint2:CGPointMake(minX + 0.92927 * w, minY))
        roundedRect4Path.closePath()
        roundedRect4Path.moveToPoint(CGPointMake(minX + 0.15798 * w, minY))
        
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