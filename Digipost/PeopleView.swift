//
//  PeopleView.swift
//
//  Code generated using QuartzCode on 2015-03-10.
//  www.quartzcodeapp.com
//

import UIKit

class PeopleView: UIView {
	
	var layerWithAnims : [CALayer]!
	var animationAdded : Bool = false
	var Bigperson : CALayer!
	var bigpersonhead : CAShapeLayer!
	var bigpersonbody : CAShapeLayer!
	var Smallperson : CALayer!
	var smallpersonhead : CAShapeLayer!
	var smallpersonbody : CAShapeLayer!
	var Bag : CALayer!
	var bagbody : CAShapeLayer!
	var baghandle : CAShapeLayer!
	var Group : CALayer!
	var baglid : CAShapeLayer!
	var baglock : CAShapeLayer!
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
		Bigperson = CALayer()
		self.layer.addSublayer(Bigperson)
		
		
		bigpersonhead = CAShapeLayer()
		Bigperson.addSublayer(bigpersonhead)
		bigpersonhead.fillColor   = nil
		bigpersonhead.strokeColor = UIColor.digipostAnimationGrey().CGColor
		bigpersonhead.lineWidth   = 3
		
		bigpersonbody = CAShapeLayer()
		Bigperson.addSublayer(bigpersonbody)
		bigpersonbody.fillRule    = kCAFillRuleEvenOdd
		bigpersonbody.fillColor   = nil
		bigpersonbody.strokeColor = UIColor.digipostAnimationGrey().CGColor
		bigpersonbody.lineWidth   = 3
		
		Smallperson = CALayer()
		self.layer.addSublayer(Smallperson)
		
		
		smallpersonhead = CAShapeLayer()
		Smallperson.addSublayer(smallpersonhead)
		smallpersonhead.fillColor   = nil
		smallpersonhead.strokeColor = UIColor.digipostAnimationGrey().CGColor
		smallpersonhead.lineWidth   = 3
		
		smallpersonbody = CAShapeLayer()
		Smallperson.addSublayer(smallpersonbody)
		smallpersonbody.fillRule    = kCAFillRuleEvenOdd
		smallpersonbody.fillColor   = nil
		smallpersonbody.strokeColor = UIColor.digipostAnimationGrey().CGColor
		smallpersonbody.lineWidth   = 3
		
		Bag = CALayer()
		self.layer.addSublayer(Bag)
		
		
		bagbody = CAShapeLayer()
		Bag.addSublayer(bagbody)
		bagbody.fillColor   = nil
		bagbody.strokeColor = UIColor.digipostAnimationGrey().CGColor
		bagbody.lineWidth   = 3
		
		baghandle = CAShapeLayer()
		Bag.addSublayer(baghandle)
		baghandle.fillColor   = nil
		baghandle.strokeColor = UIColor.digipostAnimationGrey().CGColor
		baghandle.lineWidth   = 3
		
		Group = CALayer()
		Bag.addSublayer(Group)
		
		
		baglid = CAShapeLayer()
		Group.addSublayer(baglid)
		baglid.fillColor   = nil
		baglid.strokeColor = UIColor.digipostAnimationGrey().CGColor
		baglid.lineWidth   = 3
		
		baglock = CAShapeLayer()
		Group.addSublayer(baglock)
		baglock.fillColor   = nil
		baglock.strokeColor = UIColor.digipostAnimationGrey().CGColor
		baglock.lineWidth   = 3
		
		animationText = CATextLayer()
		self.layer.addSublayer(animationText)
		animationText.contentsScale   = UIScreen.mainScreen().scale
		animationText.string          = "Test\n"
		animationText.font            = "HelveticaNeue"
		animationText.fontSize        = 17
		animationText.alignmentMode   = kCAAlignmentCenter;
		animationText.foregroundColor = UIColor.digipostAnimationGrey().CGColor;
		
		setupLayerFrames()
		
		self.layerWithAnims = [Bigperson, bigpersonhead, bigpersonbody, Smallperson, smallpersonhead, smallpersonbody, Bag, bagbody, baghandle, Group, baglid, baglock, animationText]
	}
	
	
	func setupLayerFrames(){
		if Bigperson != nil{
			Bigperson.frame = CGRectMake(0.30648 * Bigperson.superlayer.bounds.width, 0.3321 * Bigperson.superlayer.bounds.height, 0.06737 * Bigperson.superlayer.bounds.width, 0.15568 * Bigperson.superlayer.bounds.height)
		}
		if bigpersonhead != nil{
			bigpersonhead.frame = CGRectMake(0.10297 * bigpersonhead.superlayer.bounds.width, 0, 0.77916 * bigpersonhead.superlayer.bounds.width, 0.3725 * bigpersonhead.superlayer.bounds.height)
			bigpersonhead.path  = bigpersonheadPathWithBounds(bigpersonhead.bounds).CGPath;
		}
		if bigpersonbody != nil{
			bigpersonbody.frame = CGRectMake(0, 0.47183 * bigpersonbody.superlayer.bounds.height,  bigpersonbody.superlayer.bounds.width, 0.52817 * bigpersonbody.superlayer.bounds.height)
			bigpersonbody.path  = bigpersonbodyPathWithBounds(bigpersonbody.bounds).CGPath;
		}
		if Smallperson != nil{
			Smallperson.frame = CGRectMake(0.38403 * Smallperson.superlayer.bounds.width, 0.35511 * Smallperson.superlayer.bounds.height, 0.0442 * Smallperson.superlayer.bounds.width, 0.10966 * Smallperson.superlayer.bounds.height)
		}
		if smallpersonhead != nil{
			smallpersonhead.frame = CGRectMake(0.10297 * smallpersonhead.superlayer.bounds.width, 0, 0.77916 * smallpersonhead.superlayer.bounds.width, 0.35689 * smallpersonhead.superlayer.bounds.height)
			smallpersonhead.path  = smallpersonheadPathWithBounds(smallpersonhead.bounds).CGPath;
		}
		if smallpersonbody != nil{
			smallpersonbody.frame = CGRectMake(0, 0.49397 * smallpersonbody.superlayer.bounds.height,  smallpersonbody.superlayer.bounds.width, 0.50603 * smallpersonbody.superlayer.bounds.height)
			smallpersonbody.path  = smallpersonbodyPathWithBounds(smallpersonbody.bounds).CGPath;
		}
		if Bag != nil{
			Bag.frame = CGRectMake(0.53462 * Bag.superlayer.bounds.width, 0.35026 * Bag.superlayer.bounds.height, 0.16382 * Bag.superlayer.bounds.width, 0.13752 * Bag.superlayer.bounds.height)
		}
		if bagbody != nil{
			bagbody.frame = CGRectMake(0.01376 * bagbody.superlayer.bounds.width, 0.12663 * bagbody.superlayer.bounds.height, 0.97983 * bagbody.superlayer.bounds.width, 0.87337 * bagbody.superlayer.bounds.height)
			bagbody.path  = bagbodyPathWithBounds(bagbody.bounds).CGPath;
		}
		if baghandle != nil{
			baghandle.frame = CGRectMake(0.39153 * baghandle.superlayer.bounds.width, 0, 0.2243 * baghandle.superlayer.bounds.width, 0.11039 * baghandle.superlayer.bounds.height)
			baghandle.path  = baghandlePathWithBounds(baghandle.bounds).CGPath;
		}
		if Group != nil{
			Group.frame = CGRectMake(0, 0.3403 * Group.superlayer.bounds.height,  Group.superlayer.bounds.width, 0.09677 * Group.superlayer.bounds.height)
		}
		if baglid != nil{
			baglid.frame = CGRectMake(0, 0.00022 * baglid.superlayer.bounds.height,  baglid.superlayer.bounds.width, 0 * baglid.superlayer.bounds.height)
			baglid.path  = baglidPathWithBounds(baglid.bounds).CGPath;
		}
		if baglock != nil{
			baglock.frame = CGRectMake(0.44363 * baglock.superlayer.bounds.width, 0, 0.11274 * baglock.superlayer.bounds.width,  baglock.superlayer.bounds.height)
			baglock.path  = baglockPathWithBounds(baglock.bounds).CGPath;
		}
		if animationText != nil{
			animationText.frame = CGRectMake(0.00464 * animationText.superlayer.bounds.width, 0.60132 * animationText.superlayer.bounds.height, 0.99071 * animationText.superlayer.bounds.width, 0.27914 * animationText.superlayer.bounds.height)
		}
	}
	
	
	@IBAction func startAllAnimations(sender: AnyObject!){
		self.animationAdded = false
		for layer in self.layerWithAnims{
			layer.speed = 1
		}
		
		bigpersonhead?.addAnimation(bigpersonheadAnimation(), forKey:"bigpersonheadAnimation")
		bigpersonbody?.addAnimation(bigpersonbodyAnimation(), forKey:"bigpersonbodyAnimation")
		
		smallpersonhead?.addAnimation(smallpersonheadAnimation(), forKey:"smallpersonheadAnimation")
		smallpersonbody?.addAnimation(smallpersonbodyAnimation(), forKey:"smallpersonbodyAnimation")
		
		bagbody?.addAnimation(bagbodyAnimation(), forKey:"bagbodyAnimation")
		baghandle?.addAnimation(baghandleAnimation(), forKey:"baghandleAnimation")
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
				var totalDuration : CGFloat = 2.74
				var offset = progress * totalDuration
				for layer in self.layerWithAnims{
					layer.timeOffset = CFTimeInterval(offset)
				}
			}
		}
	}
	
	func bigpersonheadAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1.1]
		strokeEndAnim.keyTimes = [0, 0.42, 1]
		strokeEndAnim.duration = 1.2
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func bigpersonbodyAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1.1]
		strokeEndAnim.keyTimes = [0, 0.417, 1]
		strokeEndAnim.duration = 1.2
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func smallpersonheadAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.595, 1]
		strokeEndAnim.duration = 1.75
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func smallpersonbodyAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1.1]
		strokeEndAnim.keyTimes = [0, 0.598, 1]
		strokeEndAnim.duration = 1.74
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func bagbodyAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.723, 1]
		strokeEndAnim.duration = 2.41
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func baghandleAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.877, 1]
		strokeEndAnim.duration = 2.74
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	//MARK: - Bezier Path
	
	func bigpersonheadPathWithBounds(bound: CGRect) -> UIBezierPath{
		var bigpersonheadPath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		bigpersonheadPath.moveToPoint(CGPointMake(minX + 0.5 * w, minY))
		bigpersonheadPath.addCurveToPoint(CGPointMake(minX, minY + 0.5 * h), controlPoint1:CGPointMake(minX + 0.22386 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.22386 * h))
		bigpersonheadPath.addCurveToPoint(CGPointMake(minX + 0.5 * w, minY + h), controlPoint1:CGPointMake(minX, minY + 0.77614 * h), controlPoint2:CGPointMake(minX + 0.22386 * w, minY + h))
		bigpersonheadPath.addCurveToPoint(CGPointMake(minX + w, minY + 0.5 * h), controlPoint1:CGPointMake(minX + 0.77614 * w, minY + h), controlPoint2:CGPointMake(minX + w, minY + 0.77614 * h))
		bigpersonheadPath.addCurveToPoint(CGPointMake(minX + 0.5 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.22386 * h), controlPoint2:CGPointMake(minX + 0.77614 * w, minY))
		
		return bigpersonheadPath;
	}
	
	func bigpersonbodyPathWithBounds(bound: CGRect) -> UIBezierPath{
		var bigpersonbodyPath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		bigpersonbodyPath.moveToPoint(CGPointMake(minX + 0.36031 * w, minY))
		bigpersonbodyPath.addLineToPoint(CGPointMake(minX + 0.01807 * w, minY + 0.75578 * h))
		bigpersonbodyPath.addCurveToPoint(CGPointMake(minX + 0.32579 * w, minY + h), controlPoint1:CGPointMake(minX + -0.06507 * w, minY + 0.94548 * h), controlPoint2:CGPointMake(minX + 0.15616 * w, minY + h))
		bigpersonbodyPath.addLineToPoint(CGPointMake(minX + 0.67013 * w, minY + h))
		bigpersonbodyPath.addCurveToPoint(CGPointMake(minX + 0.97728 * w, minY + 0.75578 * h), controlPoint1:CGPointMake(minX + 0.83977 * w, minY + h), controlPoint2:CGPointMake(minX + 1.07426 * w, minY + 0.94548 * h))
		bigpersonbodyPath.addLineToPoint(CGPointMake(minX + 0.6381 * w, minY + 0.00503 * h))
		bigpersonbodyPath.addCurveToPoint(CGPointMake(minX + 0.50778 * w, minY + 0.02237 * h), controlPoint1:CGPointMake(minX + 0.59672 * w, minY + 0.01632 * h), controlPoint2:CGPointMake(minX + 0.553 * w, minY + 0.02237 * h))
		bigpersonbodyPath.addCurveToPoint(CGPointMake(minX + 0.36031 * w, minY), controlPoint1:CGPointMake(minX + 0.45626 * w, minY + 0.02237 * h), controlPoint2:CGPointMake(minX + 0.40669 * w, minY + 0.01451 * h))
		bigpersonbodyPath.closePath()
		bigpersonbodyPath.moveToPoint(CGPointMake(minX + 0.36031 * w, minY))
		
		return bigpersonbodyPath;
	}
	
	func smallpersonheadPathWithBounds(bound: CGRect) -> UIBezierPath{
		var smallpersonheadPath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		smallpersonheadPath.moveToPoint(CGPointMake(minX + 0.5 * w, minY))
		smallpersonheadPath.addCurveToPoint(CGPointMake(minX, minY + 0.5 * h), controlPoint1:CGPointMake(minX + 0.22386 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.22386 * h))
		smallpersonheadPath.addCurveToPoint(CGPointMake(minX + 0.5 * w, minY + h), controlPoint1:CGPointMake(minX, minY + 0.77614 * h), controlPoint2:CGPointMake(minX + 0.22386 * w, minY + h))
		smallpersonheadPath.addCurveToPoint(CGPointMake(minX + w, minY + 0.5 * h), controlPoint1:CGPointMake(minX + 0.77614 * w, minY + h), controlPoint2:CGPointMake(minX + w, minY + 0.77614 * h))
		smallpersonheadPath.addCurveToPoint(CGPointMake(minX + 0.5 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.22386 * h), controlPoint2:CGPointMake(minX + 0.77614 * w, minY))
		
		return smallpersonheadPath;
	}
	
	func smallpersonbodyPathWithBounds(bound: CGRect) -> UIBezierPath{
		var smallpersonbodyPath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		smallpersonbodyPath.moveToPoint(CGPointMake(minX + 0.36031 * w, minY))
		smallpersonbodyPath.addLineToPoint(CGPointMake(minX + 0.01807 * w, minY + 0.75578 * h))
		smallpersonbodyPath.addCurveToPoint(CGPointMake(minX + 0.32579 * w, minY + h), controlPoint1:CGPointMake(minX + -0.06507 * w, minY + 0.94548 * h), controlPoint2:CGPointMake(minX + 0.15616 * w, minY + h))
		smallpersonbodyPath.addLineToPoint(CGPointMake(minX + 0.67013 * w, minY + h))
		smallpersonbodyPath.addCurveToPoint(CGPointMake(minX + 0.97728 * w, minY + 0.75578 * h), controlPoint1:CGPointMake(minX + 0.83977 * w, minY + h), controlPoint2:CGPointMake(minX + 1.07426 * w, minY + 0.94548 * h))
		smallpersonbodyPath.addLineToPoint(CGPointMake(minX + 0.6381 * w, minY + 0.00503 * h))
		smallpersonbodyPath.addCurveToPoint(CGPointMake(minX + 0.50778 * w, minY + 0.02237 * h), controlPoint1:CGPointMake(minX + 0.59672 * w, minY + 0.01632 * h), controlPoint2:CGPointMake(minX + 0.553 * w, minY + 0.02237 * h))
		smallpersonbodyPath.addCurveToPoint(CGPointMake(minX + 0.36031 * w, minY), controlPoint1:CGPointMake(minX + 0.45626 * w, minY + 0.02237 * h), controlPoint2:CGPointMake(minX + 0.40669 * w, minY + 0.01451 * h))
		smallpersonbodyPath.closePath()
		smallpersonbodyPath.moveToPoint(CGPointMake(minX + 0.36031 * w, minY))
		
		return smallpersonbodyPath;
	}
	
	func bagbodyPathWithBounds(bound: CGRect) -> UIBezierPath{
		var bagbodyPath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		bagbodyPath.moveToPoint(CGPointMake(minX + 0.06125 * w, minY))
		bagbodyPath.addCurveToPoint(CGPointMake(minX, minY + 0.08211 * h), controlPoint1:CGPointMake(minX + 0.02742 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.03676 * h))
		bagbodyPath.addLineToPoint(CGPointMake(minX, minY + 0.91789 * h))
		bagbodyPath.addCurveToPoint(CGPointMake(minX + 0.06125 * w, minY + h), controlPoint1:CGPointMake(minX, minY + 0.96324 * h), controlPoint2:CGPointMake(minX + 0.02742 * w, minY + h))
		bagbodyPath.addLineToPoint(CGPointMake(minX + 0.93875 * w, minY + h))
		bagbodyPath.addCurveToPoint(CGPointMake(minX + w, minY + 0.91789 * h), controlPoint1:CGPointMake(minX + 0.97258 * w, minY + h), controlPoint2:CGPointMake(minX + w, minY + 0.96324 * h))
		bagbodyPath.addLineToPoint(CGPointMake(minX + w, minY + 0.08211 * h))
		bagbodyPath.addCurveToPoint(CGPointMake(minX + 0.93875 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.03676 * h), controlPoint2:CGPointMake(minX + 0.97258 * w, minY))
		bagbodyPath.closePath()
		bagbodyPath.moveToPoint(CGPointMake(minX + 0.06125 * w, minY))
		
		return bagbodyPath;
	}
	
	func baghandlePathWithBounds(bound: CGRect) -> UIBezierPath{
		var baghandlePath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		baghandlePath.moveToPoint(CGPointMake(minX + w, minY + h))
		baghandlePath.addCurveToPoint(CGPointMake(minX + 0.86085 * w, minY + 0.00671 * h), controlPoint1:CGPointMake(minX + w, minY + 0.79547 * h), controlPoint2:CGPointMake(minX + 0.95433 * w, minY + 0.17765 * h))
		baghandlePath.addLineToPoint(CGPointMake(minX + 0.65063 * w, minY + 0.00671 * h))
		baghandlePath.addLineToPoint(CGPointMake(minX + 0.34197 * w, minY))
		baghandlePath.addLineToPoint(CGPointMake(minX + 0.11314 * w, minY + 0.00671 * h))
		baghandlePath.addCurveToPoint(CGPointMake(minX + 0.00066 * w, minY + 0.99958 * h), controlPoint1:CGPointMake(minX + -0.0156 * w, minY + 0.26761 * h), controlPoint2:CGPointMake(minX + 0.00066 * w, minY + 0.99958 * h))
		
		return baghandlePath;
	}
	
	func baglidPathWithBounds(bound: CGRect) -> UIBezierPath{
		var baglidPath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		baglidPath.moveToPoint(CGPointMake(minX, minY * h))
		baglidPath.addLineToPoint(CGPointMake(minX + w, minY * h))
		baglidPath.addLineToPoint(CGPointMake(minX, minY * h))
		
		return baglidPath;
	}
	
	func baglockPathWithBounds(bound: CGRect) -> UIBezierPath{
		var baglockPath = UIBezierPath(rect: bound)
		return baglockPath;
	}

}