//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
		super.init(coder: aDecoder)!
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
		receiptbody.strokeColor = UIColor.digipostProfileTextColor().cgColor
		receiptbody.lineWidth   = 3
		
		receiptline1 = CAShapeLayer()
		kvitto.addSublayer(receiptline1)
		receiptline1.fillColor   = nil
		receiptline1.strokeColor = UIColor.digipostProfileTextColor().cgColor
		receiptline1.lineWidth   = 3
		
		receiptline2 = CAShapeLayer()
		kvitto.addSublayer(receiptline2)
		receiptline2.fillColor   = nil
		receiptline2.strokeColor = UIColor.digipostProfileTextColor().cgColor
		receiptline2.lineWidth   = 3
		
		receiptline3 = CAShapeLayer()
		kvitto.addSublayer(receiptline3)
		receiptline3.fillColor   = nil
		receiptline3.strokeColor = UIColor.digipostProfileTextColor().cgColor
		receiptline3.lineWidth   = 3
		
		receiptline4 = CAShapeLayer()
		kvitto.addSublayer(receiptline4)
		receiptline4.fillColor   = nil
		receiptline4.strokeColor = UIColor.digipostProfileTextColor().cgColor
		receiptline4.lineWidth   = 3
		
		kort = CALayer()
		self.layer.addSublayer(kort)
		kort.setValue(-4 * CGFloat(Double.pi)/180, forKeyPath:"transform.rotation")
		
		
		cardbody = CAShapeLayer()
		kort.addSublayer(cardbody)
		cardbody.fillColor   = nil
		cardbody.strokeColor = UIColor.digipostProfileTextColor().cgColor
		cardbody.lineWidth   = 3
		
		magneticstripe = CAShapeLayer()
		kort.addSublayer(magneticstripe)
		magneticstripe.fillColor = UIColor.digipostProfileTextColor().cgColor
		magneticstripe.lineWidth = 0
		
		litenkvadrat = CALayer()
		kort.addSublayer(litenkvadrat)
		
		
		hologram = CAShapeLayer()
		litenkvadrat.addSublayer(hologram)
		hologram.fillColor   = nil
		hologram.strokeColor = UIColor.digipostProfileTextColor().cgColor
		hologram.lineWidth   = 3
		
		hologramline = CAShapeLayer()
		kort.addSublayer(hologramline)
		hologramline.setValue(-180 * CGFloat(Double.pi)/180, forKeyPath:"transform.rotation")
		hologramline.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).cgColor
		hologramline.strokeColor = UIColor.digipostProfileTextColor().cgColor
		hologramline.lineWidth   = 3
		
		hologramline2 = CAShapeLayer()
		kort.addSublayer(hologramline2)
		hologramline2.setValue(-180 * CGFloat(Double.pi)/180, forKeyPath:"transform.rotation")
		hologramline2.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).cgColor
		hologramline2.strokeColor = UIColor.digipostProfileTextColor().cgColor
		hologramline2.lineWidth   = 3
		
		animationText = CATextLayer()
		self.layer.addSublayer(animationText)
		animationText.contentsScale   = UIScreen.main.scale
		animationText.string          = "Hello World!"
		animationText.font            = "HelveticaNeue" as CFTypeRef?
		animationText.fontSize        = 17
		animationText.alignmentMode   = kCAAlignmentCenter;
		animationText.foregroundColor = UIColor.digipostProfileTextColor().cgColor;
		
		setupLayerFrames()
		
		self.layerWithAnims = [kvitto, receiptbody, receiptline1, receiptline2, receiptline3, receiptline4, kort, cardbody, magneticstripe, litenkvadrat, hologram, hologramline, hologramline2, animationText]
	}
	
	
	func setupLayerFrames(){
		if kvitto != nil{
			kvitto.frame = CGRect(x: 0.52926 * kvitto.superlayer!.bounds.width, y: 0.25353 * kvitto.superlayer!.bounds.height, width: 0.11058 * kvitto.superlayer!.bounds.width, height: 0.16411 * kvitto.superlayer!.bounds.height)
		}
		if receiptbody != nil{
			receiptbody.frame = CGRect(x: 0, y: 0,  width: receiptbody.superlayer!.bounds.width,  height: receiptbody.superlayer!.bounds.height)
			receiptbody.path  = receiptbodyPathWithBounds(receiptbody.bounds).cgPath;
		}
		if receiptline1 != nil{
			receiptline1.frame = CGRect(x: 0.14209 * receiptline1.superlayer!.bounds.width, y: 0.23395 * receiptline1.superlayer!.bounds.height, width: 0.71582 * receiptline1.superlayer!.bounds.width, height: 0.00521 * receiptline1.superlayer!.bounds.height)
			receiptline1.path  = receiptline1PathWithBounds(receiptline1.bounds).cgPath;
		}
		if receiptline2 != nil{
			receiptline2.frame = CGRect(x: 0.14209 * receiptline2.superlayer!.bounds.width, y: 0.3373 * receiptline2.superlayer!.bounds.height, width: 0.71582 * receiptline2.superlayer!.bounds.width, height: 0.00521 * receiptline2.superlayer!.bounds.height)
			receiptline2.path  = receiptline2PathWithBounds(receiptline2.bounds).cgPath;
		}
		if receiptline3 != nil{
			receiptline3.frame = CGRect(x: 0.14209 * receiptline3.superlayer!.bounds.width, y: 0.439 * receiptline3.superlayer!.bounds.height, width: 0.45943 * receiptline3.superlayer!.bounds.width, height: 0.00649 * receiptline3.superlayer!.bounds.height)
			receiptline3.path  = receiptline3PathWithBounds(receiptline3.bounds).cgPath;
		}
		if receiptline4 != nil{
			receiptline4.frame = CGRect(x: 0.71905 * receiptline4.superlayer!.bounds.width, y: 0.74761 * receiptline4.superlayer!.bounds.height, width: 0.14604 * receiptline4.superlayer!.bounds.width, height: 0 * receiptline4.superlayer!.bounds.height)
			receiptline4.path  = receiptline4PathWithBounds(receiptline4.bounds).cgPath;
		}
		if kort != nil{
			kort.setValue(0, forKeyPath:"transform.rotation")
			kort.frame = CGRect(x: 0.29749 * kort.superlayer!.bounds.width, y: 0.35561 * kort.superlayer!.bounds.height, width: 0.19086 * kort.superlayer!.bounds.width, height: 0.12454 * kort.superlayer!.bounds.height)
			kort.setValue(-4 * CGFloat(Double.pi)/180, forKeyPath:"transform.rotation")
		}
		if cardbody != nil{
			cardbody.frame = CGRect(x: 0.02118 * cardbody.superlayer!.bounds.width, y: 0, width: 0.97882 * cardbody.superlayer!.bounds.width,  height: cardbody.superlayer!.bounds.height)
			cardbody.path  = cardbodyPathWithBounds(cardbody.bounds).cgPath;
		}
		if magneticstripe != nil{
            let device = UIDevice.current.userInterfaceIdiom
            var xPosition = CGFloat(0.0)
            if device == .pad { xPosition += 0.9 }
			magneticstripe.frame = CGRect(x: xPosition, y: 0.17773 * magneticstripe.superlayer!.bounds.height, width: 0.97806 * magneticstripe.superlayer!.bounds.width, height: 0.1412 * magneticstripe.superlayer!.bounds.height)
			magneticstripe.path  = magneticstripePathWithBounds(magneticstripe.bounds).cgPath;
		}
		if litenkvadrat != nil{
			litenkvadrat.frame = CGRect(x: 0.09455 * litenkvadrat.superlayer!.bounds.width, y: 0.46439 * litenkvadrat.superlayer!.bounds.height, width: 0.13016 * litenkvadrat.superlayer!.bounds.width, height: 0.19831 * litenkvadrat.superlayer!.bounds.height)
		}
		if hologram != nil{
			hologram.frame = CGRect(x: -0.04324 * hologram.superlayer!.bounds.width, y: -0.24421 * hologram.superlayer!.bounds.height, width: 1.05952 * hologram.superlayer!.bounds.width, height: 1.0761 * hologram.superlayer!.bounds.height)
			hologram.path  = hologramPathWithBounds(hologram.bounds).cgPath;
		}
		if hologramline != nil{
			hologramline.setValue(0, forKeyPath:"transform.rotation")
			hologramline.frame = CGRect(x: 0.27767 * hologramline.superlayer!.bounds.width, y: 0.46101 * hologramline.superlayer!.bounds.height, width: 0.50564 * hologramline.superlayer!.bounds.width, height: 0 * hologramline.superlayer!.bounds.height)
			hologramline.setValue(-180 * CGFloat(Double.pi)/180, forKeyPath:"transform.rotation")
			hologramline.path  = hologramlinePathWithBounds(hologramline.bounds).cgPath;
		}
		if hologramline2 != nil{
			hologramline2.setValue(0, forKeyPath:"transform.rotation")
			hologramline2.frame = CGRect(x: 0.28461 * hologramline2.superlayer!.bounds.width, y: 0.61608 * hologramline2.superlayer!.bounds.height, width: 0.19681 * hologramline2.superlayer!.bounds.width, height: 0 * hologramline2.superlayer!.bounds.height)
			hologramline2.setValue(-180 * CGFloat(Double.pi)/180, forKeyPath:"transform.rotation")
			hologramline2.path  = hologramline2PathWithBounds(hologramline2.bounds).cgPath;
		}
		if animationText != nil{
			animationText.frame = CGRect(x: 0.00464 * animationText.superlayer!.bounds.width, y: 0.60015 * animationText.superlayer!.bounds.height, width: 0.99071 * animationText.superlayer!.bounds.width, height: 0.28032 * animationText.superlayer!.bounds.height)
		}
	}
	
	
	@IBAction func startAllAnimations(_ sender: AnyObject!){
		self.animationAdded = false
		for layer in self.layerWithAnims{
			layer.speed = 1
		}
		
		receiptbody?.add(receiptbodyAnimation(), forKey:"receiptbodyAnimation")
		receiptline1?.add(receiptline1Animation(), forKey:"receiptline1Animation")
		receiptline2?.add(receiptline2Animation(), forKey:"receiptline2Animation")
		receiptline3?.add(receiptline3Animation(), forKey:"receiptline3Animation")
		receiptline4?.add(receiptline4Animation(), forKey:"receiptline4Animation")
		
		cardbody?.add(cardbodyAnimation(), forKey:"cardbodyAnimation")
		magneticstripe?.add(magneticstripeAnimation(), forKey:"magneticstripeAnimation")
		
		hologram?.add(hologramAnimation(), forKey:"hologramAnimation")
		hologramline?.add(hologramlineAnimation(), forKey:"hologramlineAnimation")
		hologramline2?.add(hologramline2Animation(), forKey:"hologramline2Animation")
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
				let totalDuration : CGFloat = 2.3
				let offset = progress * totalDuration
				for layer in self.layerWithAnims{
					layer.timeOffset = CFTimeInterval(offset)
				}
			}
		}
	}
	
	func receiptbodyAnimation() -> CAKeyframeAnimation{
		let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1.1]
		strokeEndAnim.keyTimes = [0, 0.625, 1]
		strokeEndAnim.duration = 2.11
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.isRemovedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func receiptline1Animation() -> CAKeyframeAnimation{
		let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.909, 1]
		strokeEndAnim.duration = 2.11
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.isRemovedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func receiptline2Animation() -> CAKeyframeAnimation{
		let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [1, 0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.0162, 0.907, 1]
		strokeEndAnim.duration = 2.11
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.isRemovedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func receiptline3Animation() -> CAKeyframeAnimation{
		let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.902, 1]
		strokeEndAnim.duration = 2.1
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.isRemovedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func receiptline4Animation() -> CAKeyframeAnimation{
		let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.903, 1]
		strokeEndAnim.duration = 2.1
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.isRemovedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func cardbodyAnimation() -> CAKeyframeAnimation{
		let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.623, 1]
		strokeEndAnim.duration = 1.73
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.isRemovedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func magneticstripeAnimation() -> CAKeyframeAnimation{
		let transformAnim      = CAKeyframeAnimation(keyPath:"transform")
		transformAnim.values   = [NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)), 
			 NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)), 
			 NSValue(caTransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)), 
			 NSValue(caTransform3D: CATransform3DIdentity)]
		transformAnim.keyTimes = [0, 0.874, 0.94, 1]
		transformAnim.duration = 1.95
		transformAnim.fillMode = kCAFillModeBoth
		transformAnim.isRemovedOnCompletion = false
		
		return transformAnim;
	}
	
	func hologramAnimation() -> CAKeyframeAnimation{
		let transformAnim      = CAKeyframeAnimation(keyPath:"transform")
		transformAnim.values   = [NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)), 
			 NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)), 
			 NSValue(caTransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)), 
			 NSValue(caTransform3D: CATransform3DIdentity)]
		transformAnim.keyTimes = [0, 0.856, 0.909, 1]
		transformAnim.duration = 2.3
		transformAnim.fillMode = kCAFillModeBoth
		transformAnim.isRemovedOnCompletion = false
		
		return transformAnim;
	}
	
	func hologramlineAnimation() -> CAKeyframeAnimation{
		let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.868, 1]
		strokeEndAnim.duration = 2.28
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.isRemovedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	func hologramline2Animation() -> CAKeyframeAnimation{
		let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		strokeEndAnim.values   = [0, 0, 1]
		strokeEndAnim.keyTimes = [0, 0.877, 1]
		strokeEndAnim.duration = 2.27
		strokeEndAnim.fillMode = kCAFillModeForwards
		strokeEndAnim.isRemovedOnCompletion = false
		
		return strokeEndAnim;
	}
	
	//MARK: - Bezier Path
	
	func receiptbodyPathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let receiptbodyPath = UIBezierPath()
		let minX = CGFloat(bound.minX)
        let minY = bound.minY
        let w = bound.width
        let h = bound.height;
		
		receiptbodyPath.move(to: CGPoint(x: minX + 0.72742 * w, y: minY))
		receiptbodyPath.addLine(to: CGPoint(x: minX + w, y: minY))
		receiptbodyPath.addLine(to: CGPoint(x: minX + w, y: minY + h))
		receiptbodyPath.addLine(to: CGPoint(x: minX, y: minY + h))
		receiptbodyPath.addLine(to: CGPoint(x: minX, y: minY))
		receiptbodyPath.addLine(to: CGPoint(x: minX + 0.27258 * w, y: minY))
		receiptbodyPath.addLine(to: CGPoint(x: minX + 0.27258 * w, y: minY + 0.05153 * h))
		receiptbodyPath.addCurve(to: CGPoint(x: minX + 0.33099 * w, y: minY + 0.09271 * h), controlPoint1:CGPoint(x: minX + 0.27258 * w, y: minY + 0.07427 * h), controlPoint2:CGPoint(x: minX + 0.29873 * w, y: minY + 0.09271 * h))
		receiptbodyPath.addLine(to: CGPoint(x: minX + 0.66901 * w, y: minY + 0.09271 * h))
		receiptbodyPath.addCurve(to: CGPoint(x: minX + 0.72742 * w, y: minY + 0.05153 * h), controlPoint1:CGPoint(x: minX + 0.70127 * w, y: minY + 0.09271 * h), controlPoint2:CGPoint(x: minX + 0.72742 * w, y: minY + 0.07427 * h))
		receiptbodyPath.addLine(to: CGPoint(x: minX + 0.72742 * w, y: minY))
		receiptbodyPath.close()
		receiptbodyPath.move(to: CGPoint(x: minX + 0.72742 * w, y: minY))
		
		return receiptbodyPath;
	}
	
	func receiptline1PathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let receiptline1Path = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		receiptline1Path.move(to: CGPoint(x: minX, y: minY))
		receiptline1Path.addLine(to: CGPoint(x: minX + w, y: minY + h))
		
		return receiptline1Path;
	}
	
	func receiptline2PathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let receiptline2Path = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		receiptline2Path.move(to: CGPoint(x: minX, y: minY))
		receiptline2Path.addLine(to: CGPoint(x: minX + w, y: minY + h))
		
		return receiptline2Path;
	}
	
	func receiptline3PathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let receiptline3Path = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		receiptline3Path.move(to: CGPoint(x: minX, y: minY))
		receiptline3Path.addLine(to: CGPoint(x: minX + w, y: minY + h))
		
		return receiptline3Path;
	}
	
	func receiptline4PathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let receiptline4Path = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		receiptline4Path.move(to: CGPoint(x: minX, y: minY * h))
		receiptline4Path.addLine(to: CGPoint(x: minX + w, y: minY * h))
		
		return receiptline4Path;
	}
	
	func cardbodyPathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let cardbodyPath = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		cardbodyPath.move(to: CGPoint(x: minX + 0.04842 * w, y: minY))
		cardbodyPath.addCurve(to: CGPoint(x: minX, y: minY + 0.07448 * h), controlPoint1:CGPoint(x: minX + 0.02168 * w, y: minY), controlPoint2:CGPoint(x: minX, y: minY + 0.03335 * h))
		cardbodyPath.addLine(to: CGPoint(x: minX, y: minY + 0.92552 * h))
		cardbodyPath.addCurve(to: CGPoint(x: minX + 0.04842 * w, y: minY + h), controlPoint1:CGPoint(x: minX, y: minY + 0.96665 * h), controlPoint2:CGPoint(x: minX + 0.02168 * w, y: minY + h))
		cardbodyPath.addLine(to: CGPoint(x: minX + 0.95158 * w, y: minY + h))
		cardbodyPath.addCurve(to: CGPoint(x: minX + w, y: minY + 0.92552 * h), controlPoint1:CGPoint(x: minX + 0.97832 * w, y: minY + h), controlPoint2:CGPoint(x: minX + w, y: minY + 0.96665 * h))
		cardbodyPath.addLine(to: CGPoint(x: minX + w, y: minY + 0.07448 * h))
		cardbodyPath.addCurve(to: CGPoint(x: minX + 0.95158 * w, y: minY), controlPoint1:CGPoint(x: minX + w, y: minY + 0.03335 * h), controlPoint2:CGPoint(x: minX + 0.97832 * w, y: minY))
		cardbodyPath.close()
		cardbodyPath.move(to: CGPoint(x: minX + 0.04842 * w, y: minY))
		
		return cardbodyPath;
	}
	
	func magneticstripePathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let magneticstripePath = UIBezierPath(rect: bound)
		return magneticstripePath;
	}
	
	func hologramPathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let hologramPath = UIBezierPath(roundedRect:bound, cornerRadius:3)
		return hologramPath;
	}
	
	func hologramlinePathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let hologramlinePath = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		hologramlinePath.move(to: CGPoint(x: minX + w, y: minY * h))
		hologramlinePath.addLine(to: CGPoint(x: minX, y: minY * h))
		hologramlinePath.close()
		hologramlinePath.move(to: CGPoint(x: minX + w, y: minY * h))
		
		return hologramlinePath;
	}
	
	func hologramline2PathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let hologramline2Path = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		hologramline2Path.move(to: CGPoint(x: minX + w, y: minY * h))
		hologramline2Path.addLine(to: CGPoint(x: minX, y: minY * h))
		hologramline2Path.close()
		hologramline2Path.move(to: CGPoint(x: minX + w, y: minY * h))
		
		return hologramline2Path;
	}

}
