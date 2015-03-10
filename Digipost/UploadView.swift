//
//  UploadView.swift
//
//  Code generated using QuartzCode on 2015-03-10.
//  www.quartzcodeapp.com
//

import UIKit

class UploadView: UIView {
	
	var layerWithAnims : [CALayer]!
	var animationAdded : Bool = false
	var Camera : CALayer!
	var flash : CAShapeLayer!
	var body : CAShapeLayer!
	var handle : CAShapeLayer!
	var lens : CAShapeLayer!
	var Upload : CALayer!
	var Basket : CALayer!
	var line : CAShapeLayer!
	var line2 : CAShapeLayer!
	var line3 : CAShapeLayer!
	var Arrow : CALayer!
	var arrowbody : CAShapeLayer!
	var leftarrow : CAShapeLayer!
	var rightarrow : CAShapeLayer!
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
		Camera = CALayer()
		self.layer.addSublayer(Camera)
		Camera.setValue(-18 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
		
		
		flash = CAShapeLayer()
		Camera.addSublayer(flash)
		flash.fillColor   = UIColor.digipostAnimationGrey().CGColor
		flash.strokeColor = UIColor.digipostAnimationGrey().CGColor
		flash.lineWidth   = 3
		
		body = CAShapeLayer()
		Camera.addSublayer(body)
		body.fillRule    = kCAFillRuleEvenOdd
		body.fillColor   = nil
		body.strokeColor = UIColor.digipostAnimationGrey().CGColor
		body.lineWidth   = 3
		
		handle = CAShapeLayer()
		Camera.addSublayer(handle)
		handle.fillColor   = nil
		handle.strokeColor = UIColor.digipostAnimationGrey().CGColor
		handle.lineWidth   = 3
		
		lens = CAShapeLayer()
		Camera.addSublayer(lens)
		lens.fillColor   = nil
		lens.strokeColor = UIColor.digipostAnimationGrey().CGColor
		lens.lineWidth   = 3
		
		Upload = CALayer()
		self.layer.addSublayer(Upload)
		
		
		Basket = CALayer()
		Upload.addSublayer(Basket)
		
		
		line = CAShapeLayer()
		Basket.addSublayer(line)
		line.fillColor   = nil
		line.strokeColor = UIColor.digipostAnimationGrey().CGColor
		line.lineWidth   = 3
		
		line2 = CAShapeLayer()
		Basket.addSublayer(line2)
		line2.fillColor   = nil
		line2.strokeColor = UIColor.digipostAnimationGrey().CGColor
		line2.lineWidth   = 3
		
		line3 = CAShapeLayer()
		Basket.addSublayer(line3)
		line3.setValue(-180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
		line3.fillColor   = nil
		line3.strokeColor = UIColor.digipostAnimationGrey().CGColor
		line3.lineWidth   = 3
		
		Arrow = CALayer()
		Upload.addSublayer(Arrow)
		
		
		arrowbody = CAShapeLayer()
		Arrow.addSublayer(arrowbody)
		arrowbody.fillColor   = nil
		arrowbody.strokeColor = UIColor.digipostAnimationGrey().CGColor
		arrowbody.lineWidth   = 3
		
		leftarrow = CAShapeLayer()
		Arrow.addSublayer(leftarrow)
		leftarrow.fillColor   = nil
		leftarrow.strokeColor = UIColor.digipostAnimationGrey().CGColor
		leftarrow.lineWidth   = 3
		
		rightarrow = CAShapeLayer()
		Arrow.addSublayer(rightarrow)
		rightarrow.fillColor   = nil
		rightarrow.strokeColor = UIColor.digipostAnimationGrey().CGColor
		rightarrow.lineWidth   = 3
		
		animationText = CATextLayer()
		self.layer.addSublayer(animationText)
		animationText.contentsScale   = UIScreen.mainScreen().scale
		animationText.string          = "Hello World!"
		animationText.font            = "HelveticaNeue"
		animationText.fontSize        = 17
		animationText.alignmentMode   = kCAAlignmentCenter;
		animationText.foregroundColor = UIColor.digipostAnimationGrey().CGColor;
		
		setupLayerFrames()
		
		self.layerWithAnims = [Camera, flash, body, handle, lens, Upload, Basket, line, line2, line3, Arrow, arrowbody, leftarrow, rightarrow, animationText]
	}
	
	
	func setupLayerFrames(){
		if Camera != nil{
			Camera.setValue(0, forKeyPath:"transform.rotation")
			Camera.frame = CGRectMake(0.32726 * Camera.superlayer.bounds.width, 0.27902 * Camera.superlayer.bounds.height, 0.15972 * Camera.superlayer.bounds.width, 0.12968 * Camera.superlayer.bounds.height)
			Camera.setValue(-18 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
		}
		if flash != nil{
			flash.frame = CGRectMake(0.88486 * flash.superlayer.bounds.width, 0.28447 * flash.superlayer.bounds.height, 0.02624 * flash.superlayer.bounds.width, 0.04003 * flash.superlayer.bounds.height)
			flash.path  = flashPathWithBounds(flash.bounds).CGPath;
		}
		if body != nil{
			body.frame = CGRectMake(-0.08684 * body.superlayer.bounds.width, -0.02766 * body.superlayer.bounds.height, 1.08684 * body.superlayer.bounds.width, 1.02766 * body.superlayer.bounds.height)
			body.path  = bodyPathWithBounds(body.bounds).CGPath;
		}
		if handle != nil{
			handle.frame = CGRectMake(0.32829 * handle.superlayer.bounds.width, 0, 0.33902 * handle.superlayer.bounds.width, 0.18192 * handle.superlayer.bounds.height)
			handle.path  = handlePathWithBounds(handle.bounds).CGPath;
		}
		if lens != nil{
			lens.frame = CGRectMake(0.33782 * lens.superlayer.bounds.width, 0.32229 * lens.superlayer.bounds.height, 0.33536 * lens.superlayer.bounds.width, 0.46295 * lens.superlayer.bounds.height)
			lens.path  = lensPathWithBounds(lens.bounds).CGPath;
		}
		if Upload != nil{
			Upload.frame = CGRectMake(0.50487 * Upload.superlayer.bounds.width, 0.34088 * Upload.superlayer.bounds.height, 0.15998 * Upload.superlayer.bounds.width, 0.14337 * Upload.superlayer.bounds.height)
		}
		if Basket != nil{
			Basket.frame = CGRectMake(0, 0.57539 * Basket.superlayer.bounds.height,  Basket.superlayer.bounds.width, 0.42461 * Basket.superlayer.bounds.height)
		}
		if line != nil{
			line.frame = CGRectMake(0, 0.92717 * line.superlayer.bounds.height,  line.superlayer.bounds.width, 0.00354 * line.superlayer.bounds.height)
			line.path  = linePathWithBounds(line.bounds).CGPath;
		}
		if line2 != nil{
			line2.frame = CGRectMake(0.00399 * line2.superlayer.bounds.width, 0.01647 * line2.superlayer.bounds.height, 0.00754 * line2.superlayer.bounds.width, 0.98353 * line2.superlayer.bounds.height)
			line2.path  = line2PathWithBounds(line2.bounds).CGPath;
		}
		if line3 != nil{
			line3.setValue(0, forKeyPath:"transform.rotation")
			line3.frame = CGRectMake(0.9983 * line3.superlayer.bounds.width, 0, 0 * line3.superlayer.bounds.width, 1 * line3.superlayer.bounds.height)
			line3.setValue(-180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
			line3.path  = line3PathWithBounds(line3.bounds).CGPath;
		}
		if Arrow != nil{
			Arrow.frame = CGRectMake(0.24897 * Arrow.superlayer.bounds.width, 0, 0.50058 * Arrow.superlayer.bounds.width, 0.63772 * Arrow.superlayer.bounds.height)
		}
		if arrowbody != nil{
			arrowbody.frame = CGRectMake(0.50004 * arrowbody.superlayer.bounds.width, 0.00198 * arrowbody.superlayer.bounds.height, 0 * arrowbody.superlayer.bounds.width, 0.99802 * arrowbody.superlayer.bounds.height)
			arrowbody.path  = arrowbodyPathWithBounds(arrowbody.bounds).CGPath;
		}
		if leftarrow != nil{
			leftarrow.frame = CGRectMake(0, 0, 0.53327 * leftarrow.superlayer.bounds.width, 0.50099 * leftarrow.superlayer.bounds.height)
			leftarrow.path  = leftarrowPathWithBounds(leftarrow.bounds).CGPath;
		}
		if rightarrow != nil{
			rightarrow.frame = CGRectMake(0.47544 * rightarrow.superlayer.bounds.width, 0.01688 * rightarrow.superlayer.bounds.height, 0.52456 * rightarrow.superlayer.bounds.width, 0.48024 * rightarrow.superlayer.bounds.height)
			rightarrow.path  = rightarrowPathWithBounds(rightarrow.bounds).CGPath;
		}
		if animationText != nil{
			animationText.frame = CGRectMake(0.00463 * animationText.superlayer.bounds.width, 0.60055 * animationText.superlayer.bounds.height, 0.98983 * animationText.superlayer.bounds.width, 0.28004 * animationText.superlayer.bounds.height)
		}
	}
	
	
	@IBAction func startAllAnimations(sender: AnyObject!){
		self.animationAdded = false
		for layer in self.layerWithAnims{
			layer.speed = 1
		}
		
		body?.addAnimation(bodyAnimation(), forKey:"bodyAnimation")
		handle?.addAnimation(handleAnimation(), forKey:"handleAnimation")
		
		
		line?.addAnimation(lineAnimation(), forKey:"lineAnimation")
		line2?.addAnimation(line2Animation(), forKey:"line2Animation")
		line3?.addAnimation(line3Animation(), forKey:"line3Animation")
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
				var totalDuration : CGFloat = 3.65
				var offset = progress * totalDuration
				for layer in self.layerWithAnims{
					layer.timeOffset = CFTimeInterval(offset)
				}
			}
		}
	}
	
	func bodyAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.494, 1]
		strokeEndAnim.duration = 1.99
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func handleAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.405, 0.819, 1]
		strokeEndAnim.duration = 2.42
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func lineAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.853, 1]
		strokeEndAnim.duration = 3.21
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func line2Animation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.836, 1]
		strokeEndAnim.duration = 2.91
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func line3Animation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.884, 1]
		strokeEndAnim.duration = 3.65
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	//MARK: - Bezier Path
	
	func flashPathWithBounds(bound: CGRect) -> UIBezierPath{
		var flashPath = UIBezierPath(ovalInRect: bound)
		return flashPath;
	}
	
	func bodyPathWithBounds(bound: CGRect) -> UIBezierPath{
		var bodyPath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		bodyPath.moveToPoint(CGPointMake(minX + 0.66686 * w, minY + 0.18883 * h))
		bodyPath.addLineToPoint(CGPointMake(minX + 0.66686 * w, minY + 0.18883 * h))
		bodyPath.addLineToPoint(CGPointMake(minX + 0.952 * w, minY + 0.18843 * h))
		bodyPath.addCurveToPoint(CGPointMake(minX + w, minY + 0.27299 * h), controlPoint1:CGPointMake(minX + 0.97851 * w, minY + 0.18843 * h), controlPoint2:CGPointMake(minX + w, minY + 0.22629 * h))
		bodyPath.addLineToPoint(CGPointMake(minX + w, minY + 0.91544 * h))
		bodyPath.addCurveToPoint(CGPointMake(minX + 0.952 * w, minY + h), controlPoint1:CGPointMake(minX + w, minY + 0.96214 * h), controlPoint2:CGPointMake(minX + 0.97851 * w, minY + h))
		bodyPath.addLineToPoint(CGPointMake(minX + 0.1279 * w, minY + h))
		bodyPath.addCurveToPoint(CGPointMake(minX + 0.0799 * w, minY + 0.91544 * h), controlPoint1:CGPointMake(minX + 0.10139 * w, minY + h), controlPoint2:CGPointMake(minX + 0.0799 * w, minY + 0.96214 * h))
		bodyPath.addLineToPoint(CGPointMake(minX + 0.0799 * w, minY + 0.27299 * h))
		bodyPath.addCurveToPoint(CGPointMake(minX + 0.1279 * w, minY + 0.18843 * h), controlPoint1:CGPointMake(minX + 0.0799 * w, minY + 0.22629 * h), controlPoint2:CGPointMake(minX + 0.10139 * w, minY + 0.18843 * h))
		bodyPath.addLineToPoint(CGPointMake(minX + 0.40929 * w, minY + 0.18883 * h))
		bodyPath.moveToPoint(CGPointMake(minX, minY))
		
		return bodyPath;
	}
	
	func handlePathWithBounds(bound: CGRect) -> UIBezierPath{
		var handlePath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		handlePath.moveToPoint(CGPointMake(minX + 0.22186 * w, minY))
		handlePath.addCurveToPoint(CGPointMake(minX, minY + h), controlPoint1:CGPointMake(minX + 0.13063 * w, minY), controlPoint2:CGPointMake(minX, minY + 0.86674 * h))
		handlePath.moveToPoint(CGPointMake(minX + w, minY + h))
		handlePath.addCurveToPoint(CGPointMake(minX + 0.72629 * w, minY), controlPoint1:CGPointMake(minX + w, minY + 0.86674 * h), controlPoint2:CGPointMake(minX + 0.81752 * w, minY))
		handlePath.addLineToPoint(CGPointMake(minX + 0.22186 * w, minY))
		
		return handlePath;
	}
	
	func lensPathWithBounds(bound: CGRect) -> UIBezierPath{
		var lensPath = UIBezierPath(ovalInRect: bound)
		return lensPath;
	}
	
	func linePathWithBounds(bound: CGRect) -> UIBezierPath{
		var linePath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		linePath.moveToPoint(CGPointMake(minX, minY + h))
		linePath.addLineToPoint(CGPointMake(minX + w, minY))
		
		return linePath;
	}
	
	func line2PathWithBounds(bound: CGRect) -> UIBezierPath{
		var line2Path = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		line2Path.moveToPoint(CGPointMake(minX, minY))
		line2Path.addLineToPoint(CGPointMake(minX + w, minY + h))
		
		return line2Path;
	}
	
	func line3PathWithBounds(bound: CGRect) -> UIBezierPath{
		var line3Path = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		line3Path.moveToPoint(CGPointMake(minX * w, minY))
		line3Path.addLineToPoint(CGPointMake(minX * w, minY + h))
		
		return line3Path;
	}
	
	func arrowbodyPathWithBounds(bound: CGRect) -> UIBezierPath{
		var arrowbodyPath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		arrowbodyPath.moveToPoint(CGPointMake(minX * w, minY + h))
		arrowbodyPath.addLineToPoint(CGPointMake(minX * w, minY))
		
		return arrowbodyPath;
	}
	
	func leftarrowPathWithBounds(bound: CGRect) -> UIBezierPath{
		var leftarrowPath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		leftarrowPath.moveToPoint(CGPointMake(minX, minY + h))
		leftarrowPath.addLineToPoint(CGPointMake(minX + w, minY))
		
		return leftarrowPath;
	}
	
	func rightarrowPathWithBounds(bound: CGRect) -> UIBezierPath{
		var rightarrowPath = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		rightarrowPath.moveToPoint(CGPointMake(minX + w, minY + h))
		rightarrowPath.addLineToPoint(CGPointMake(minX, minY))
		
		return rightarrowPath;
	}

}