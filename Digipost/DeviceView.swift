//
//  DeviceView.swift
//
//  Code generated using QuartzCode on 2015-02-10.
//  www.quartzcodeapp.com
//

import UIKit

class DeviceView: UIView {
    
    var layerWithAnims : [CALayer]!
    var animationAdded : Bool = false
    var roundedrect2 : CAShapeLayer!
    var path2 : CAShapeLayer!
    var oval2 : CAShapeLayer!
    
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
        roundedrect2 = CAShapeLayer()
        roundedrect2.frame       = CGRectMake(101.41, 129.69, 81.13, 70.05)
        roundedrect2.fillColor   = nil
        roundedrect2.strokeColor = UIColor.blackColor().CGColor
        roundedrect2.lineWidth   = 3
        roundedrect2.path        = roundedRect2Path().CGPath;
        self.layer.addSublayer(roundedrect2)
        
        path2 = CAShapeLayer()
        path2.frame       = CGRectMake(129.83, 144.67, 22.89, 40.11)
        path2.fillRule    = kCAFillRuleEvenOdd
        path2.fillColor   = nil
        path2.strokeColor = UIColor.blackColor().CGColor
        path2.lineWidth   = 3
        path2.path        = path2Path().CGPath;
        self.layer.addSublayer(path2)
        
        oval2 = CAShapeLayer()
        oval2.frame       = CGRectMake(113.17, 80.66, 56.23, 44.39)
        oval2.lineCap     = kCALineCapRound
        oval2.fillColor   = nil
        oval2.strokeColor = UIColor.blackColor().CGColor
        oval2.lineWidth   = 3
        oval2.path        = oval2Path().CGPath;
        self.layer.addSublayer(oval2)
        
        self.layerWithAnims = [roundedrect2, path2, oval2]
    }
    
    
    @IBAction func startAllAnimations(sender: AnyObject!){
        self.animationAdded = false
        for layer in self.layerWithAnims{
            layer.speed = 1
        }
        roundedrect2?.addAnimation(roundedRect2Animation(), forKey:"roundedRect2Animation")
        path2?.addAnimation(path2Animation(), forKey:"path2Animation")
        oval2?.addAnimation(oval2Animation(), forKey:"oval2Animation")
    }
    
    
    @IBAction func startReverseAnimations(sender: AnyObject!){
        self.animationAdded = false
        for layer in self.layerWithAnims{
            layer.speed = 1
        }
        var totalDuration = CGFloat(3)
        roundedrect2?.addAnimation(QCMethod.reverseAnimation(roundedRect2Animation(), totalDuration:totalDuration), forKey:"roundedRect2Animation")
        path2?.addAnimation(QCMethod.reverseAnimation(path2Animation(), totalDuration:totalDuration), forKey:"path2Animation")
        oval2?.addAnimation(QCMethod.reverseAnimation(oval2Animation(), totalDuration:totalDuration), forKey:"oval2Animation")
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
                var totalDuration : CGFloat = 3
                var offset = progress * totalDuration
                for layer in self.layerWithAnims{
                    layer.timeOffset = CFTimeInterval(offset)
                }
            }
        }
    }
    
    func roundedRect2Animation() -> CABasicAnimation{
        var strokeEndAnim       = CABasicAnimation(keyPath:"strokeEnd")
        strokeEndAnim.fromValue = 0;
        strokeEndAnim.toValue   = 1.1;
        strokeEndAnim.duration  = 1.29
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func path2Animation() -> CAAnimationGroup{
        var transformAnim       = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values    = [NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeScale(1.2, 1.2, 1.2)),
            NSValue(CATransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes  = [0, 0.514, 1]
        transformAnim.duration  = 0.925
        transformAnim.beginTime = 1.24
        
        var hiddenAnim       = CABasicAnimation(keyPath:"hidden")
        hiddenAnim.fromValue = true;
        hiddenAnim.toValue   = false;
        hiddenAnim.duration  = 3
        
        var path5AnimGroup                 = CAAnimationGroup()
        path5AnimGroup.animations          = [transformAnim, hiddenAnim]
        path5AnimGroup.animations.map{$0.setValue(kCAFillModeForwards, forKeyPath:"fillMode")}
        path5AnimGroup.fillMode            = kCAFillModeForwards
        path5AnimGroup.removedOnCompletion = false
        path5AnimGroup.duration = QCMethod.maxDurationFromAnimations(path5AnimGroup.animations as [CAAnimation])
        
        
        return path5AnimGroup;
    }
    
    func oval2Animation() -> CABasicAnimation{
        var strokeEndAnim       = CABasicAnimation(keyPath:"strokeEnd")
        strokeEndAnim.fromValue = 0;
        strokeEndAnim.toValue   = 1;
        strokeEndAnim.duration  = 1.29
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.removedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    //MARK: - Bezier Path
    
    func roundedRect2Path() -> UIBezierPath{
        var roundedRect2Path = UIBezierPath()
        roundedRect2Path.moveToPoint(CGPointMake(14, 0))
        roundedRect2Path.addCurveToPoint(CGPointMake(0, 14), controlPoint1:CGPointMake(6.268, 0), controlPoint2:CGPointMake(0, 6.268))
        roundedRect2Path.addLineToPoint(CGPointMake(0, 56.055))
        roundedRect2Path.addCurveToPoint(CGPointMake(14, 70.055), controlPoint1:CGPointMake(0, 63.787), controlPoint2:CGPointMake(6.268, 70.055))
        roundedRect2Path.addLineToPoint(CGPointMake(67.131, 70.055))
        roundedRect2Path.addCurveToPoint(CGPointMake(81.131, 56.055), controlPoint1:CGPointMake(74.863, 70.055), controlPoint2:CGPointMake(81.131, 63.787))
        roundedRect2Path.addLineToPoint(CGPointMake(81.131, 14))
        roundedRect2Path.addCurveToPoint(CGPointMake(67.131, 0), controlPoint1:CGPointMake(81.131, 6.268), controlPoint2:CGPointMake(74.863, 0))
        roundedRect2Path.closePath()
        roundedRect2Path.moveToPoint(CGPointMake(14, 0))
        
        return roundedRect2Path;
    }
    
    func path2Path() -> UIBezierPath{
        var path2Path = UIBezierPath()
        path2Path.moveToPoint(CGPointMake(5.264, 21.918))
        path2Path.addCurveToPoint(CGPointMake(0, 11.9), controlPoint1:CGPointMake(2.098, 19.801), controlPoint2:CGPointMake(0, 16.105))
        path2Path.addCurveToPoint(CGPointMake(11.446, 0), controlPoint1:CGPointMake(0, 5.328), controlPoint2:CGPointMake(5.125, 0))
        path2Path.addCurveToPoint(CGPointMake(22.892, 11.9), controlPoint1:CGPointMake(17.768, 0), controlPoint2:CGPointMake(22.892, 5.328))
        path2Path.addCurveToPoint(CGPointMake(17.757, 21.83), controlPoint1:CGPointMake(22.892, 16.048), controlPoint2:CGPointMake(20.852, 19.7))
        path2Path.addLineToPoint(CGPointMake(21.438, 35.606))
        path2Path.addCurveToPoint(CGPointMake(17.066, 40.107), controlPoint1:CGPointMake(21.438, 38.092), controlPoint2:CGPointMake(19.48, 40.107))
        path2Path.addLineToPoint(CGPointMake(6.362, 40.107))
        path2Path.addCurveToPoint(CGPointMake(1.99, 35.606), controlPoint1:CGPointMake(3.947, 40.107), controlPoint2:CGPointMake(1.99, 38.092))
        path2Path.addLineToPoint(CGPointMake(5.264, 21.918))
        path2Path.closePath()
        path2Path.moveToPoint(CGPointMake(5.264, 21.918))
        
        return path2Path;
    }
    
    func oval2Path() -> UIBezierPath{
        var oval2Path = UIBezierPath()
        oval2Path.moveToPoint(CGPointMake(28.114, 0))
        oval2Path.addCurveToPoint(CGPointMake(0, 22.193), controlPoint1:CGPointMake(12.587, 0), controlPoint2:CGPointMake(0, 9.936))
        oval2Path.addLineToPoint(CGPointMake(0, 44.386))
        oval2Path.moveToPoint(CGPointMake(56.228, 44.386))
        oval2Path.addLineToPoint(CGPointMake(56.228, 22.193))
        oval2Path.addCurveToPoint(CGPointMake(28.114, 0), controlPoint1:CGPointMake(56.228, 9.936), controlPoint2:CGPointMake(43.641, 0))
        
        return oval2Path;
    }
    
}