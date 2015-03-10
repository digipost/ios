//
//  ReceiptView.swift
//
//  Code generated using QuartzCode on 2015-03-10.
//  www.quartzcodeapp.com
//

import UIKit

class ReceiptView: UIView {
	
	var layerWithAnims : [CALayer]!
	var animationAdded : Bool = false
	var kvitto : CALayer!
	var receiptbody : CAShapeLayer!
	var receiptline1 : CAShapeLayer!
	var receiptline2 : CAShapeLayer!
	var receiptline3 : CAShapeLayer!
	var receiptline4 : CAShapeLayer!
	var kort : CALayer!
	var cardbody : CAShapeLayer!
	var magneticstripe : CAShapeLayer!
	var litenkvadrat : CALayer!
	var hologram : CAShapeLayer!
	var hologramline : CAShapeLayer!
	var hologramline2 : CAShapeLayer!
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
	
	override var bounds: CGRect {
		didSet{
			setupLayerFrames()
		}
	}
	
	func setupLayers(){
		kvitto = CALayer()
		self.layer.addSublayer(kvitto)
		
		
		receiptbody = CAShapeLayer()
		kvitto.addSublayer(receiptbody)
		receiptbody.fillRule    = kCAFillRuleEvenOdd
		receiptbody.fillColor   = nil
		receiptbody.strokeColor = UIColor.digipostAnimationGrey().CGColor
		receiptbody.lineWidth   = 3
		
		receiptline1 = CAShapeLayer()
		kvitto.addSublayer(receiptline1)
		receiptline1.fillColor   = nil
		receiptline1.strokeColor = UIColor.digipostAnimationGrey().CGColor
		receiptline1.lineWidth   = 3
		
		receiptline2 = CAShapeLayer()
		kvitto.addSublayer(receiptline2)
		receiptline2.fillColor   = nil
		receiptline2.strokeColor = UIColor.digipostAnimationGrey().CGColor
		receiptline2.lineWidth   = 3
		
		receiptline3 = CAShapeLayer()
		kvitto.addSublayer(receiptline3)
		receiptline3.fillColor   = nil
		receiptline3.strokeColor = UIColor.digipostAnimationGrey().CGColor
		receiptline3.lineWidth   = 3
		
		receiptline4 = CAShapeLayer()
		kvitto.addSublayer(receiptline4)
		receiptline4.fillColor   = nil
		receiptline4.strokeColor = UIColor.digipostAnimationGrey().CGColor
		receiptline4.lineWidth   = 3
		
		kort = CALayer()
		self.layer.addSublayer(kort)
		kort.setValue(-4 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
		
		
		cardbody = CAShapeLayer()
		kort.addSublayer(cardbody)
		cardbody.fillColor   = nil
		cardbody.strokeColor = UIColor.digipostAnimationGrey().CGColor
		cardbody.lineWidth   = 3
		
		magneticstripe = CAShapeLayer()
		kort.addSublayer(magneticstripe)
		magneticstripe.fillColor = UIColor.digipostAnimationGrey().CGColor
		magneticstripe.lineWidth = 0
		
		litenkvadrat = CALayer()
		kort.addSublayer(litenkvadrat)
		
		
		hologram = CAShapeLayer()
		litenkvadrat.addSublayer(hologram)
		hologram.fillColor   = nil
		hologram.strokeColor = UIColor.digipostAnimationGrey().CGColor
		hologram.lineWidth   = 3
		
		hologramline = CAShapeLayer()
		kort.addSublayer(hologramline)
		hologramline.setValue(-180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
		hologramline.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
		hologramline.strokeColor = UIColor.digipostAnimationGrey().CGColor
		hologramline.lineWidth   = 3
		
		hologramline2 = CAShapeLayer()
		kort.addSublayer(hologramline2)
		hologramline2.setValue(-180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
		hologramline2.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
		hologramline2.strokeColor = UIColor.digipostAnimationGrey().CGColor
		hologramline2.lineWidth   = 3
		
		animationText = CATextLayer()
		self.layer.addSublayer(animationText)
		animationText.contentsScale   = UIScreen.mainScreen().scale
		animationText.string          = "Hello World!"
		animationText.font            = "HelveticaNeue"
		animationText.fontSize        = 17
		animationText.alignmentMode   = kCAAlignmentCenter;
		animationText.foregroundColor = UIColor.digipostAnimationGrey().CGColor;
		
		setupLayerFrames()
		
		self.layerWithAnims = [kvitto, receiptbody, receiptline1, receiptline2, receiptline3, receiptline4, kort, cardbody, magneticstripe, litenkvadrat, hologram, hologramline, hologramline2, animationText]
	}
	
	
	func setupLayerFrames(){
		if kvitto != nil{
			kvitto.frame = CGRectMake(0.52926 * kvitto.superlayer.bounds.width, 0.25353 * kvitto.superlayer.bounds.height, 0.11058 * kvitto.superlayer.bounds.width, 0.16411 * kvitto.superlayer.bounds.height)
		}
		if receiptbody != nil{
			receiptbody.frame = CGRectMake(0, 0,  receiptbody.superlayer.bounds.width,  receiptbody.superlayer.bounds.height)
			receiptbody.path  = receiptbodyPathWithBounds(receiptbody.bounds).CGPath;
		}
		if receiptline1 != nil{
			receiptline1.frame = CGRectMake(0.14209 * receiptline1.superlayer.bounds.width, 0.23395 * receiptline1.superlayer.bounds.height, 0.71582 * receiptline1.superlayer.bounds.width, 0.00521 * receiptline1.superlayer.bounds.height)
			receiptline1.path  = receiptline1PathWithBounds(receiptline1.bounds).CGPath;
		}
		if receiptline2 != nil{
			receiptline2.frame = CGRectMake(0.14209 * receiptline2.superlayer.bounds.width, 0.3373 * receiptline2.superlayer.bounds.height, 0.71582 * receiptline2.superlayer.bounds.width, 0.00521 * receiptline2.superlayer.bounds.height)
			receiptline2.path  = receiptline2PathWithBounds(receiptline2.bounds).CGPath;
		}
		if receiptline3 != nil{
			receiptline3.frame = CGRectMake(0.14209 * receiptline3.superlayer.bounds.width, 0.439 * receiptline3.superlayer.bounds.height, 0.45943 * receiptline3.superlayer.bounds.width, 0.00649 * receiptline3.superlayer.bounds.height)
			receiptline3.path  = receiptline3PathWithBounds(receiptline3.bounds).CGPath;
		}
		if receiptline4 != nil{
			receiptline4.frame = CGRectMake(0.71905 * receiptline4.superlayer.bounds.width, 0.74761 * receiptline4.superlayer.bounds.height, 0.14604 * receiptline4.superlayer.bounds.width, 0 * receiptline4.superlayer.bounds.height)
			receiptline4.path  = receiptline4PathWithBounds(receiptline4.bounds).CGPath;
		}
		if kort != nil{
			kort.setValue(0, forKeyPath:"transform.rotation")
			kort.frame = CGRectMake(0.29749 * kort.superlayer.bounds.width, 0.35561 * kort.superlayer.bounds.height, 0.19086 * kort.superlayer.bounds.width, 0.12454 * kort.superlayer.bounds.height)
			kort.setValue(-4 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
		}
		if cardbody != nil{
			cardbody.frame = CGRectMake(0.02118 * cardbody.superlayer.bounds.width, 0, 0.97882 * cardbody.superlayer.bounds.width,  cardbody.superlayer.bounds.height)
			cardbody.path  = cardbodyPathWithBounds(cardbody.bounds).CGPath;
		}
		if magneticstripe != nil{
			magneticstripe.frame = CGRectMake(0, 0.17773 * magneticstripe.superlayer.bounds.height, 0.97806 * magneticstripe.superlayer.bounds.width, 0.1412 * magneticstripe.superlayer.bounds.height)
			magneticstripe.path  = magneticstripePathWithBounds(magneticstripe.bounds).CGPath;
		}
		if litenkvadrat != nil{
			litenkvadrat.frame = CGRectMake(0.09455 * litenkvadrat.superlayer.bounds.width, 0.46439 * litenkvadrat.superlayer.bounds.height, 0.13016 * litenkvadrat.superlayer.bounds.width, 0.19831 * litenkvadrat.superlayer.bounds.height)
		}
		if hologram != nil{
			hologram.frame = CGRectMake(-0.04324 * hologram.superlayer.bounds.width, -0.24421 * hologram.superlayer.bounds.height, 1.05952 * hologram.superlayer.bounds.width, 1.0761 * hologram.superlayer.bounds.height)
			hologram.path  = hologramPathWithBounds(hologram.bounds).CGPath;
		}
		if hologramline != nil{
			hologramline.setValue(0, forKeyPath:"transform.rotation")
			hologramline.frame = CGRectMake(0.27767 * hologramline.superlayer.bounds.width, 0.46101 * hologramline.superlayer.bounds.height, 0.50564 * hologramline.superlayer.bounds.width, 0 * hologramline.superlayer.bounds.height)
			hologramline.setValue(-180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
			hologramline.path  = hologramlinePathWithBounds(hologramline.bounds).CGPath;
		}
		if hologramline2 != nil{
			hologramline2.setValue(0, forKeyPath:"transform.rotation")
			hologramline2.frame = CGRectMake(0.28461 * hologramline2.superlayer.bounds.width, 0.61608 * hologramline2.superlayer.bounds.height, 0.19681 * hologramline2.superlayer.bounds.width, 0 * hologramline2.superlayer.bounds.height)
			hologramline2.setValue(-180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
			hologramline2.path  = hologramline2PathWithBounds(hologramline2.bounds).CGPath;
		}
		if animationText != nil{
			animationText.frame = CGRectMake(0.00464 * animationText.superlayer.bounds.width, 0.60015 * animationText.superlayer.bounds.height, 0.99071 * animationText.superlayer.bounds.width, 0.28032 * animationText.superlayer.bounds.height)
		}
	}
	
	
	@IBAction func startAllAnimations(sender: AnyObject!){
		self.animationAdded = false
		for layer in self.layerWithAnims{
			layer.speed = 1
		}
		
		receiptbody?.addAnimation(receiptbodyAnimation(), forKey:"receiptbodyAnimation")
		receiptline1?.addAnimation(receiptline1Animation(), forKey:"receiptline1Animation")
		receiptline2?.addAnimation(receiptline2Animation(), forKey:"receiptline2Animation")
		receiptline3?.addAnimation(receiptline3Animation(), forKey:"receiptline3Animation")
		receiptline4?.addAnimation(receiptline4Animation(), forKey:"receiptline4Animation")
		
		cardbody?.addAnimation(cardbodyAnimation(), forKey:"cardbodyAnimation")
		magneticstripe?.addAnimation(magneticstripeAnimation(), forKey:"magneticstripeAnimation")
		
		hologram?.addAnimation(hologramAnimation(), forKey:"hologramAnimation")
		hologramline?.addAnimation(hologramlineAnimation(), forKey:"hologramlineAnimation")
		hologramline2?.addAnimation(hologramline2Animation(), forKey:"hologramline2Animation")
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
				var totalDuration : CGFloat = 2.3
				var offset = progress * totalDuration
				for layer in self.layerWithAnims{
					layer.timeOffset = CFTimeInterval(offset)
				}
			}
		}
	}
	
	func receiptbodyAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1.1]
		strokeEndAnim.keyTimes = [0, 0.625, 1]
		strokeEndAnim.duration = 2.11
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func receiptline1Animation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.909, 1]
		strokeEndAnim.duration = 2.11
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func receiptline2Animation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [1, 0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.0162, 0.907, 1]
		strokeEndAnim.duration = 2.11
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func receiptline3Animation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.902, 1]
		strokeEndAnim.duration = 2.1
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func receiptline4Animation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.903, 1]
		strokeEndAnim.duration = 2.1
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func cardbodyAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.623, 1]
		strokeEndAnim.duration = 1.73
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func magneticstripeAnimation() -> CAKeyframeAnimation{
		var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
		transformAnim.values   = [NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)), 
			 NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)), 
			 NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)), 
			 NSValue(CATransform3D: CATransform3DIdentity)]
		transformAnim.keyTimes = [0, 0.874, 0.94, 1]
		transformAnim.duration = 1.95
		transformAnim.fillMode = kCAFillModeBoth
		transformAnim.removedOnCompletion = false
		
		return transformAnim;
	}
	
	func hologramAnimation() -> CAKeyframeAnimation{
		var transformAnim      = CAKeyframeAnimation(keyPath:"transform")
		transformAnim.values   = [NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)), 
			 NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0)), 
			 NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)), 
			 NSValue(CATransform3D: CATransform3DIdentity)]
		transformAnim.keyTimes = [0, 0.856, 0.909, 1]
		transformAnim.duration = 2.3
		transformAnim.fillMode = kCAFillModeBoth
		transformAnim.removedOnCompletion = false
		
		return transformAnim;
	}
	
	func hologramlineAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.868, 1]
		strokeEndAnim.duration = 2.28
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func hologramline2Animation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.877, 1]
		strokeEndAnim.duration = 2.27
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	//MARK: - Bezier Path
	
	func receiptbodyPathWithBounds(bound: CGRect) -> UIBezierPath{
		var receiptbodyPath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		receiptbodyPath.moveToPoint(CGPointMake(minX + 0.72742 * w, minY))
		receiptbodyPath.addLineToPoint(CGPointMake(minX + w, minY))
		receiptbodyPath.addLineToPoint(CGPointMake(minX + w, minY + h))
		receiptbodyPath.addLineToPoint(CGPointMake(minX, minY + h))
		receiptbodyPath.addLineToPoint(CGPointMake(minX, minY))
		receiptbodyPath.addLineToPoint(CGPointMake(minX + 0.27258 * w, minY))
		receiptbodyPath.addLineToPoint(CGPointMake(minX + 0.27258 * w, minY + 0.05153 * h))
		receiptbodyPath.addCurveToPoint(CGPointMake(minX + 0.33099 * w, minY + 0.09271 * h), controlPoint1:CGPointMake(minX + 0.27258 * w, minY + 0.07427 * h), controlPoint2:CGPointMake(minX + 0.29873 * w, minY + 0.09271 * h))
		receiptbodyPath.addLineToPoint(CGPointMake(minX + 0.66901 * w, minY + 0.09271 * h))
		receiptbodyPath.addCurveToPoint(CGPointMake(minX + 0.72742 * w, minY + 0.05153 * h), controlPoint1:CGPointMake(minX + 0.70127 * w, minY + 0.09271 * h), controlPoint2:CGPointMake(minX + 0.72742 * w, minY + 0.07427 * h))
		receiptbodyPath.addLineToPoint(CGPointMake(minX + 0.72742 * w, minY))
		receiptbodyPath.closePath()
		receiptbodyPath.moveToPoint(CGPointMake(minX + 0.72742 * w, minY))
		
		return receiptbodyPath;
	}
	
	func receiptline1PathWithBounds(bound: CGRect) -> UIBezierPath{
		var receiptline1Path = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		receiptline1Path.moveToPoint(CGPointMake(minX, minY))
		receiptline1Path.addLineToPoint(CGPointMake(minX + w, minY + h))
		
		return receiptline1Path;
	}
	
	func receiptline2PathWithBounds(bound: CGRect) -> UIBezierPath{
		var receiptline2Path = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		receiptline2Path.moveToPoint(CGPointMake(minX, minY))
		receiptline2Path.addLineToPoint(CGPointMake(minX + w, minY + h))
		
		return receiptline2Path;
	}
	
	func receiptline3PathWithBounds(bound: CGRect) -> UIBezierPath{
		var receiptline3Path = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		receiptline3Path.moveToPoint(CGPointMake(minX, minY))
		receiptline3Path.addLineToPoint(CGPointMake(minX + w, minY + h))
		
		return receiptline3Path;
	}
	
	func receiptline4PathWithBounds(bound: CGRect) -> UIBezierPath{
		var receiptline4Path = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		receiptline4Path.moveToPoint(CGPointMake(minX, minY * h))
		receiptline4Path.addLineToPoint(CGPointMake(minX + w, minY * h))
		
		return receiptline4Path;
	}
	
	func cardbodyPathWithBounds(bound: CGRect) -> UIBezierPath{
		var cardbodyPath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		cardbodyPath.moveToPoint(CGPointMake(minX + 0.04842 * w, minY))
		cardbodyPath.addCurveToPoint(CGPointMake(minX, minY + 0.07448 * h), controlPoint1:CGPointMake(minX + 0.02168 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.03335 * h))
		cardbodyPath.addLineToPoint(CGPointMake(minX, minY + 0.92552 * h))
		cardbodyPath.addCurveToPoint(CGPointMake(minX + 0.04842 * w, minY + h), controlPoint1:CGPointMake(minX, minY + 0.96665 * h), controlPoint2:CGPointMake(minX + 0.02168 * w, minY + h))
		cardbodyPath.addLineToPoint(CGPointMake(minX + 0.95158 * w, minY + h))
		cardbodyPath.addCurveToPoint(CGPointMake(minX + w, minY + 0.92552 * h), controlPoint1:CGPointMake(minX + 0.97832 * w, minY + h), controlPoint2:CGPointMake(minX + w, minY + 0.96665 * h))
		cardbodyPath.addLineToPoint(CGPointMake(minX + w, minY + 0.07448 * h))
		cardbodyPath.addCurveToPoint(CGPointMake(minX + 0.95158 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.03335 * h), controlPoint2:CGPointMake(minX + 0.97832 * w, minY))
		cardbodyPath.closePath()
		cardbodyPath.moveToPoint(CGPointMake(minX + 0.04842 * w, minY))
		
		return cardbodyPath;
	}
	
	func magneticstripePathWithBounds(bound: CGRect) -> UIBezierPath{
		var magneticstripePath = UIBezierPath(rect: bound)
		return magneticstripePath;
	}
	
	func hologramPathWithBounds(bound: CGRect) -> UIBezierPath{
		var hologramPath = UIBezierPath(roundedRect:bound, cornerRadius:3)
		return hologramPath;
	}
	
	func hologramlinePathWithBounds(bound: CGRect) -> UIBezierPath{
		var hologramlinePath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		hologramlinePath.moveToPoint(CGPointMake(minX + w, minY * h))
		hologramlinePath.addLineToPoint(CGPointMake(minX, minY * h))
		hologramlinePath.closePath()
		hologramlinePath.moveToPoint(CGPointMake(minX + w, minY * h))
		
		return hologramlinePath;
	}
	
	func hologramline2PathWithBounds(bound: CGRect) -> UIBezierPath{
		var hologramline2Path = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		hologramline2Path.moveToPoint(CGPointMake(minX + w, minY * h))
		hologramline2Path.addLineToPoint(CGPointMake(minX, minY * h))
		hologramline2Path.closePath()
		hologramline2Path.moveToPoint(CGPointMake(minX + w, minY * h))
		
		return hologramline2Path;
	}

}