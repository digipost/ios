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
	var path : CAShapeLayer!
	var path2 : CAShapeLayer!
	var path3 : CAShapeLayer!
	var path4 : CAShapeLayer!
	var path5 : CAShapeLayer!
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
		
		
		path = CAShapeLayer()
		kvitto.addSublayer(path)
		path.fillRule    = kCAFillRuleEvenOdd
		path.fillColor   = nil
		path.strokeColor = UIColor(red:0.236, green: 0.242, blue:0.257, alpha:1).CGColor
		path.lineWidth   = 3
		
		path2 = CAShapeLayer()
		kvitto.addSublayer(path2)
		path2.fillColor   = nil
		path2.strokeColor = UIColor(red:0.236, green: 0.242, blue:0.257, alpha:1).CGColor
		path2.lineWidth   = 3
		
		path3 = CAShapeLayer()
		kvitto.addSublayer(path3)
		path3.fillColor   = nil
		path3.strokeColor = UIColor(red:0.236, green: 0.242, blue:0.257, alpha:1).CGColor
		path3.lineWidth   = 3
		
		path4 = CAShapeLayer()
		kvitto.addSublayer(path4)
		path4.fillColor   = nil
		path4.strokeColor = UIColor(red:0.236, green: 0.242, blue:0.257, alpha:1).CGColor
		path4.lineWidth   = 3
		
		path5 = CAShapeLayer()
		kvitto.addSublayer(path5)
		path5.fillColor   = nil
		path5.strokeColor = UIColor(red:0.236, green: 0.242, blue:0.257, alpha:1).CGColor
		path5.lineWidth   = 3
		
		kort = CALayer()
		self.layer.addSublayer(kort)
		kort.setValue(-4 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
		
		
		cardbody = CAShapeLayer()
		kort.addSublayer(cardbody)
		cardbody.fillColor   = nil
		cardbody.strokeColor = UIColor(red:0.236, green: 0.242, blue:0.257, alpha:1).CGColor
		cardbody.lineWidth   = 3
		
		magneticstripe = CAShapeLayer()
		kort.addSublayer(magneticstripe)
		magneticstripe.fillColor = UIColor(red:0.236, green: 0.242, blue:0.257, alpha:1).CGColor
		magneticstripe.lineWidth = 0
		
		litenkvadrat = CALayer()
		kort.addSublayer(litenkvadrat)
		
		
		hologram = CAShapeLayer()
		litenkvadrat.addSublayer(hologram)
		hologram.fillColor   = nil
		hologram.strokeColor = UIColor(red:0.236, green: 0.242, blue:0.257, alpha:1).CGColor
		hologram.lineWidth   = 3
		
		hologramline = CAShapeLayer()
		kort.addSublayer(hologramline)
		hologramline.setValue(-180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
		hologramline.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
		hologramline.strokeColor = UIColor(red:0.236, green: 0.242, blue:0.257, alpha:1).CGColor
		hologramline.lineWidth   = 3
		
		hologramline2 = CAShapeLayer()
		kort.addSublayer(hologramline2)
		hologramline2.setValue(-180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
		hologramline2.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
		hologramline2.strokeColor = UIColor(red:0.236, green: 0.242, blue:0.257, alpha:1).CGColor
		hologramline2.lineWidth   = 3
		
		animationText = CATextLayer()
		self.layer.addSublayer(animationText)
		animationText.contentsScale   = UIScreen.mainScreen().scale
		animationText.string          = "Hello World!"
		animationText.font            = "HelveticaNeue"
		animationText.fontSize        = 17
		animationText.alignmentMode   = kCAAlignmentCenter;
		animationText.foregroundColor = UIColor(red:0.236, green: 0.242, blue:0.257, alpha:1).CGColor;
		
		setupLayerFrames()
		
		self.layerWithAnims = [kvitto, path, path2, path3, path4, path5, kort, cardbody, magneticstripe, litenkvadrat, hologram, hologramline, hologramline2, animationText]
	}
	
	
	func setupLayerFrames(){
		if kvitto != nil{
			kvitto.frame = CGRectMake(0.52926 * kvitto.superlayer.bounds.width, 0.25353 * kvitto.superlayer.bounds.height, 0.11058 * kvitto.superlayer.bounds.width, 0.16411 * kvitto.superlayer.bounds.height)
		}
		if path != nil{
			path.frame = CGRectMake(0, 0,  path.superlayer.bounds.width,  path.superlayer.bounds.height)
			path.path  = pathPathWithBounds(path.bounds).CGPath;
		}
		if path2 != nil{
			path2.frame = CGRectMake(0.14209 * path2.superlayer.bounds.width, 0.23395 * path2.superlayer.bounds.height, 0.71582 * path2.superlayer.bounds.width, 0.00521 * path2.superlayer.bounds.height)
			path2.path  = path2PathWithBounds(path2.bounds).CGPath;
		}
		if path3 != nil{
			path3.frame = CGRectMake(0.14209 * path3.superlayer.bounds.width, 0.3373 * path3.superlayer.bounds.height, 0.71582 * path3.superlayer.bounds.width, 0.00521 * path3.superlayer.bounds.height)
			path3.path  = path3PathWithBounds(path3.bounds).CGPath;
		}
		if path4 != nil{
			path4.frame = CGRectMake(0.14209 * path4.superlayer.bounds.width, 0.439 * path4.superlayer.bounds.height, 0.45943 * path4.superlayer.bounds.width, 0.00649 * path4.superlayer.bounds.height)
			path4.path  = path4PathWithBounds(path4.bounds).CGPath;
		}
		if path5 != nil{
			path5.frame = CGRectMake(0.71905 * path5.superlayer.bounds.width, 0.74761 * path5.superlayer.bounds.height, 0.14604 * path5.superlayer.bounds.width, 0 * path5.superlayer.bounds.height)
			path5.path  = path5PathWithBounds(path5.bounds).CGPath;
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
			hologram.frame = CGRectMake(-0.04324 * hologram.superlayer.bounds.width,-0.24421 * hologram.superlayer.bounds.height, 1.05952 * hologram.superlayer.bounds.width, 1.0761 * hologram.superlayer.bounds.height)
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
		
		cardbody?.addAnimation(cardbodyAnimation(), forKey:"cardbodyAnimation")
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
				var totalDuration : CGFloat = 3.12
				var offset = progress * totalDuration
				for layer in self.layerWithAnims{
					layer.timeOffset = CFTimeInterval(offset)
				}
			}
		}
	}
	
	func cardbodyAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.348, 1]
		strokeEndAnim.duration = 3.12
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func hologramlineAnimation() -> CAKeyframeAnimation{
		var strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.868, 1]
		strokeEndAnim.duration = 2.82
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.removedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func hologramline2Animation() -> CAKeyframeAnimation{
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
		
		pathPath.moveToPoint(CGPointMake(minX + 0.72742 * w, minY))
		pathPath.addLineToPoint(CGPointMake(minX + w, minY))
		pathPath.addLineToPoint(CGPointMake(minX + w, minY + h))
		pathPath.addLineToPoint(CGPointMake(minX, minY + h))
		pathPath.addLineToPoint(CGPointMake(minX, minY))
		pathPath.addLineToPoint(CGPointMake(minX + 0.27258 * w, minY))
		pathPath.addLineToPoint(CGPointMake(minX + 0.27258 * w, minY + 0.05153 * h))
		pathPath.addCurveToPoint(CGPointMake(minX + 0.33099 * w, minY + 0.09271 * h), controlPoint1:CGPointMake(minX + 0.27258 * w, minY + 0.07427 * h), controlPoint2:CGPointMake(minX + 0.29873 * w, minY + 0.09271 * h))
		pathPath.addLineToPoint(CGPointMake(minX + 0.66901 * w, minY + 0.09271 * h))
		pathPath.addCurveToPoint(CGPointMake(minX + 0.72742 * w, minY + 0.05153 * h), controlPoint1:CGPointMake(minX + 0.70127 * w, minY + 0.09271 * h), controlPoint2:CGPointMake(minX + 0.72742 * w, minY + 0.07427 * h))
		pathPath.addLineToPoint(CGPointMake(minX + 0.72742 * w, minY))
		pathPath.closePath()
		pathPath.moveToPoint(CGPointMake(minX + 0.72742 * w, minY))
		
		return pathPath;
	}
	
	func path2PathWithBounds(bound: CGRect) -> UIBezierPath{
		var path2Path = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		path2Path.moveToPoint(CGPointMake(minX, minY))
		path2Path.addLineToPoint(CGPointMake(minX + w, minY + h))
		
		return path2Path;
	}
	
	func path3PathWithBounds(bound: CGRect) -> UIBezierPath{
		var path3Path = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		path3Path.moveToPoint(CGPointMake(minX, minY))
		path3Path.addLineToPoint(CGPointMake(minX + w, minY + h))
		
		return path3Path;
	}
	
	func path4PathWithBounds(bound: CGRect) -> UIBezierPath{
		var path4Path = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		path4Path.moveToPoint(CGPointMake(minX, minY))
		path4Path.addLineToPoint(CGPointMake(minX + w, minY + h))
		
		return path4Path;
	}
	
	func path5PathWithBounds(bound: CGRect) -> UIBezierPath{
		var path5Path = UIBezierPath()
		var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		path5Path.moveToPoint(CGPointMake(minX, minY * h))
		path5Path.addLineToPoint(CGPointMake(minX + w, minY * h))
		
		return path5Path;
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