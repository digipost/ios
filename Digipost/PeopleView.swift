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
	
	required init?(coder aDecoder: NSCoder)
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
		bigpersonhead.strokeColor = UIColor.digipostProfileTextColor().cgColor
		bigpersonhead.lineWidth   = 3
		
		bigpersonbody = CAShapeLayer()
		Bigperson.addSublayer(bigpersonbody)
		bigpersonbody.fillRule    = kCAFillRuleEvenOdd
		bigpersonbody.fillColor   = nil
		bigpersonbody.strokeColor = UIColor.digipostProfileTextColor().cgColor
		bigpersonbody.lineWidth   = 3
		
		Smallperson = CALayer()
		self.layer.addSublayer(Smallperson)
		
		
		smallpersonhead = CAShapeLayer()
		Smallperson.addSublayer(smallpersonhead)
		smallpersonhead.fillColor   = nil
		smallpersonhead.strokeColor = UIColor.digipostProfileTextColor().cgColor
		smallpersonhead.lineWidth   = 3
		
		smallpersonbody = CAShapeLayer()
		Smallperson.addSublayer(smallpersonbody)
		smallpersonbody.fillRule    = kCAFillRuleEvenOdd
		smallpersonbody.fillColor   = nil
		smallpersonbody.strokeColor = UIColor.digipostProfileTextColor().cgColor
		smallpersonbody.lineWidth   = 3
		
		Bag = CALayer()
		self.layer.addSublayer(Bag)
		
		
		bagbody = CAShapeLayer()
		Bag.addSublayer(bagbody)
		bagbody.fillColor   = nil
		bagbody.strokeColor = UIColor.digipostProfileTextColor().cgColor
		bagbody.lineWidth   = 3
		
		baghandle = CAShapeLayer()
		Bag.addSublayer(baghandle)
		baghandle.fillColor   = nil
		baghandle.strokeColor = UIColor.digipostProfileTextColor().cgColor
		baghandle.lineWidth   = 3
		
		Group = CALayer()
		Bag.addSublayer(Group)
		
		
		baglid = CAShapeLayer()
		Group.addSublayer(baglid)
		baglid.fillColor   = nil
		baglid.strokeColor = UIColor.digipostProfileTextColor().cgColor
		baglid.lineWidth   = 3
		
		baglock = CAShapeLayer()
		Group.addSublayer(baglock)
		baglock.fillColor   = nil
		baglock.strokeColor = UIColor.digipostProfileTextColor().cgColor
		baglock.lineWidth   = 3
		
		animationText = CATextLayer()
		self.layer.addSublayer(animationText)
		animationText.contentsScale   = UIScreen.main.scale
		animationText.string          = "Test\n"
		animationText.font            = "HelveticaNeue" as CFTypeRef?
		animationText.fontSize        = 17
		animationText.alignmentMode   = kCAAlignmentCenter;
		animationText.foregroundColor = UIColor.digipostProfileTextColor().cgColor;
		
		setupLayerFrames()
		
		self.layerWithAnims = [Bigperson, bigpersonhead, bigpersonbody, Smallperson, smallpersonhead, smallpersonbody, Bag, bagbody, baghandle, Group, baglid, baglock, animationText]
	}
	
	
	func setupLayerFrames(){
		if Bigperson != nil{
			Bigperson.frame = CGRect(x: 0.30635 * Bigperson.superlayer!.bounds.width, y: 0.33243 * Bigperson.superlayer!.bounds.height, width: 0.06734 * Bigperson.superlayer!.bounds.width, height: 0.1556 * Bigperson.superlayer!.bounds.height)
		}
		if bigpersonhead != nil{
			bigpersonhead.frame = CGRect(x: 0.10297 * bigpersonhead.superlayer!.bounds.width, y: 0, width: 0.77916 * bigpersonhead.superlayer!.bounds.width, height: 0.3725 * bigpersonhead.superlayer!.bounds.height)
			bigpersonhead.path  = bigpersonheadPathWithBounds(bigpersonhead.bounds).cgPath;
		}
		if bigpersonbody != nil{
			bigpersonbody.frame = CGRect(x: 0, y: 0.47183 * bigpersonbody.superlayer!.bounds.height,  width: bigpersonbody.superlayer!.bounds.width, height: 0.52817 * bigpersonbody.superlayer!.bounds.height)
			bigpersonbody.path  = bigpersonbodyPathWithBounds(bigpersonbody.bounds).cgPath;
		}
		if Smallperson != nil{
			Smallperson.frame = CGRect(x: 0.38386 * Smallperson.superlayer!.bounds.width, y: 0.35543 * Smallperson.superlayer!.bounds.height, width: 0.04418 * Smallperson.superlayer!.bounds.width, height: 0.10961 * Smallperson.superlayer!.bounds.height)
		}
		if smallpersonhead != nil{
			smallpersonhead.frame = CGRect(x: 0.10297 * smallpersonhead.superlayer!.bounds.width, y: 0, width: 0.77916 * smallpersonhead.superlayer!.bounds.width, height: 0.35689 * smallpersonhead.superlayer!.bounds.height)
			smallpersonhead.path  = smallpersonheadPathWithBounds(smallpersonhead.bounds).cgPath;
		}
		if smallpersonbody != nil{
			smallpersonbody.frame = CGRect(x: 0, y: 0.49397 * smallpersonbody.superlayer!.bounds.height,  width: smallpersonbody.superlayer!.bounds.width, height: 0.50603 * smallpersonbody.superlayer!.bounds.height)
			smallpersonbody.path  = smallpersonbodyPathWithBounds(smallpersonbody.bounds).cgPath;
		}
		if Bag != nil{
			Bag.frame = CGRect(x: 0.53438 * Bag.superlayer!.bounds.width, y: 0.35058 * Bag.superlayer!.bounds.height, width: 0.16375 * Bag.superlayer!.bounds.width, height: 0.13745 * Bag.superlayer!.bounds.height)
		}
		if bagbody != nil{
			bagbody.frame = CGRect(x: 0.01376 * bagbody.superlayer!.bounds.width, y: 0.12663 * bagbody.superlayer!.bounds.height, width: 0.97983 * bagbody.superlayer!.bounds.width, height: 0.87337 * bagbody.superlayer!.bounds.height)
			bagbody.path  = bagbodyPathWithBounds(bagbody.bounds).cgPath;
		}
		if baghandle != nil{
			baghandle.frame = CGRect(x: 0.39153 * baghandle.superlayer!.bounds.width, y: 0, width: 0.2243 * baghandle.superlayer!.bounds.width, height: 0.11039 * baghandle.superlayer!.bounds.height)
			baghandle.path  = baghandlePathWithBounds(baghandle.bounds).cgPath;
		}
		if Group != nil{
			Group.frame = CGRect(x: 0, y: 0.3403 * Group.superlayer!.bounds.height,  width: Group.superlayer!.bounds.width, height: 0.09677 * Group.superlayer!.bounds.height)
		}
		if baglid != nil{
			baglid.frame = CGRect(x: 0, y: 0.00022 * baglid.superlayer!.bounds.height,  width: baglid.superlayer!.bounds.width, height: 0 * baglid.superlayer!.bounds.height)
			baglid.path  = baglidPathWithBounds(baglid.bounds).cgPath;
		}
		if baglock != nil{
			baglock.frame = CGRect(x: 0.44363 * baglock.superlayer!.bounds.width, y: 0, width: 0.11274 * baglock.superlayer!.bounds.width,  height: baglock.superlayer!.bounds.height)
			baglock.path  = baglockPathWithBounds(baglock.bounds).cgPath;
		}
		if animationText != nil{
			animationText.frame = CGRect(x: 0.00464 * animationText.superlayer!.bounds.width, y: 0.60152 * animationText.superlayer!.bounds.height, width: 0.99027 * animationText.superlayer!.bounds.width, height: 0.27901 * animationText.superlayer!.bounds.height)
		}
	}
	
	
	@IBAction func startAllAnimations(_ sender: AnyObject!){
		self.animationAdded = false
		for layer in self.layerWithAnims{
			layer.speed = 1
		}
		
		bigpersonhead?.add(bigpersonheadAnimation(), forKey:"bigpersonheadAnimation")
		bigpersonbody?.add(bigpersonbodyAnimation(), forKey:"bigpersonbodyAnimation")
		
		smallpersonhead?.add(smallpersonheadAnimation(), forKey:"smallpersonheadAnimation")
		smallpersonbody?.add(smallpersonbodyAnimation(), forKey:"smallpersonbodyAnimation")
		
		bagbody?.add(bagbodyAnimation(), forKey:"bagbodyAnimation")
		baghandle?.add(baghandleAnimation(), forKey:"baghandleAnimation")
		Group?.add(GroupAnimation(), forKey:"GroupAnimation")
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
				let totalDuration : CGFloat = 2.88
				let offset = progress * totalDuration
				for layer in self.layerWithAnims{
					layer.timeOffset = CFTimeInterval(offset)
				}
			}
		}
	}
	
    func bigpersonheadAnimation() -> CAKeyframeAnimation{
        let transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.4, 1.4, 1.4)),
            NSValue(caTransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes = [0, 0.872, 0.935, 1]
        transformAnim.duration = 2.37
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.isRemovedOnCompletion = false
        
        return transformAnim;
    }
    
    func bigpersonbodyAnimation() -> CAKeyframeAnimation{
        let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1.1]
        strokeEndAnim.keyTimes = [0, 0.623, 1]
        strokeEndAnim.duration = 1.58
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.isRemovedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func smallpersonheadAnimation() -> CAKeyframeAnimation{
        let transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.4, 1.4, 1.4)),
            NSValue(caTransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes = [0, 0.898, 0.948, 1]
        transformAnim.duration = 2.48
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.isRemovedOnCompletion = false
        
        return transformAnim;
    }
    
    func smallpersonbodyAnimation() -> CAKeyframeAnimation{
        let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1.1]
        strokeEndAnim.keyTimes = [0, 0.682, 1]
        strokeEndAnim.duration = 1.97
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.isRemovedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func bagbodyAnimation() -> CAKeyframeAnimation{
        let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.829, 1]
        strokeEndAnim.duration = 2.05
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.isRemovedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func baghandleAnimation() -> CAKeyframeAnimation{
        let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.877, 1]
        strokeEndAnim.duration = 2.33
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.isRemovedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func GroupAnimation() -> CAKeyframeAnimation{
        let transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)), 
            NSValue(caTransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)), 
            NSValue(caTransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes = [0, 0.903, 0.954, 1]
        transformAnim.duration = 2.58
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.isRemovedOnCompletion = false
        
        return transformAnim;
    }
    
	//MARK: - Bezier Path
	
	func bigpersonheadPathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let bigpersonheadPath = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		bigpersonheadPath.move(to: CGPoint(x: minX + 0.5 * w, y: minY))
		bigpersonheadPath.addCurve(to: CGPoint(x: minX, y: minY + 0.5 * h), controlPoint1:CGPoint(x: minX + 0.22386 * w, y: minY), controlPoint2:CGPoint(x: minX, y: minY + 0.22386 * h))
		bigpersonheadPath.addCurve(to: CGPoint(x: minX + 0.5 * w, y: minY + h), controlPoint1:CGPoint(x: minX, y: minY + 0.77614 * h), controlPoint2:CGPoint(x: minX + 0.22386 * w, y: minY + h))
		bigpersonheadPath.addCurve(to: CGPoint(x: minX + w, y: minY + 0.5 * h), controlPoint1:CGPoint(x: minX + 0.77614 * w, y: minY + h), controlPoint2:CGPoint(x: minX + w, y: minY + 0.77614 * h))
		bigpersonheadPath.addCurve(to: CGPoint(x: minX + 0.5 * w, y: minY), controlPoint1:CGPoint(x: minX + w, y: minY + 0.22386 * h), controlPoint2:CGPoint(x: minX + 0.77614 * w, y: minY))
		
		return bigpersonheadPath;
	}
	
	func bigpersonbodyPathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let bigpersonbodyPath = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		bigpersonbodyPath.move(to: CGPoint(x: minX + 0.36031 * w, y: minY))
		bigpersonbodyPath.addLine(to: CGPoint(x: minX + 0.01807 * w, y: minY + 0.75578 * h))
		bigpersonbodyPath.addCurve(to: CGPoint(x: minX + 0.32579 * w, y: minY + h), controlPoint1:CGPoint(x: minX + -0.06507 * w, y: minY + 0.94548 * h), controlPoint2:CGPoint(x: minX + 0.15616 * w, y: minY + h))
		bigpersonbodyPath.addLine(to: CGPoint(x: minX + 0.67013 * w, y: minY + h))
		bigpersonbodyPath.addCurve(to: CGPoint(x: minX + 0.97728 * w, y: minY + 0.75578 * h), controlPoint1:CGPoint(x: minX + 0.83977 * w, y: minY + h), controlPoint2:CGPoint(x: minX + 1.07426 * w, y: minY + 0.94548 * h))
		bigpersonbodyPath.addLine(to: CGPoint(x: minX + 0.6381 * w, y: minY + 0.00503 * h))
		bigpersonbodyPath.addCurve(to: CGPoint(x: minX + 0.50778 * w, y: minY + 0.02237 * h), controlPoint1:CGPoint(x: minX + 0.59672 * w, y: minY + 0.01632 * h), controlPoint2:CGPoint(x: minX + 0.553 * w, y: minY + 0.02237 * h))
		bigpersonbodyPath.addCurve(to: CGPoint(x: minX + 0.36031 * w, y: minY), controlPoint1:CGPoint(x: minX + 0.45626 * w, y: minY + 0.02237 * h), controlPoint2:CGPoint(x: minX + 0.40669 * w, y: minY + 0.01451 * h))
		bigpersonbodyPath.close()
		bigpersonbodyPath.move(to: CGPoint(x: minX + 0.36031 * w, y: minY))
		
		return bigpersonbodyPath;
	}
	
	func smallpersonheadPathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let smallpersonheadPath = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		smallpersonheadPath.move(to: CGPoint(x: minX + 0.5 * w, y: minY))
		smallpersonheadPath.addCurve(to: CGPoint(x: minX, y: minY + 0.5 * h), controlPoint1:CGPoint(x: minX + 0.22386 * w, y: minY), controlPoint2:CGPoint(x: minX, y: minY + 0.22386 * h))
		smallpersonheadPath.addCurve(to: CGPoint(x: minX + 0.5 * w, y: minY + h), controlPoint1:CGPoint(x: minX, y: minY + 0.77614 * h), controlPoint2:CGPoint(x: minX + 0.22386 * w, y: minY + h))
		smallpersonheadPath.addCurve(to: CGPoint(x: minX + w, y: minY + 0.5 * h), controlPoint1:CGPoint(x: minX + 0.77614 * w, y: minY + h), controlPoint2:CGPoint(x: minX + w, y: minY + 0.77614 * h))
		smallpersonheadPath.addCurve(to: CGPoint(x: minX + 0.5 * w, y: minY), controlPoint1:CGPoint(x: minX + w, y: minY + 0.22386 * h), controlPoint2:CGPoint(x: minX + 0.77614 * w, y: minY))
		
		return smallpersonheadPath;
	}
	
	func smallpersonbodyPathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let smallpersonbodyPath = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		smallpersonbodyPath.move(to: CGPoint(x: minX + 0.36031 * w, y: minY))
		smallpersonbodyPath.addLine(to: CGPoint(x: minX + 0.01807 * w, y: minY + 0.75578 * h))
		smallpersonbodyPath.addCurve(to: CGPoint(x: minX + 0.32579 * w, y: minY + h), controlPoint1:CGPoint(x: minX + -0.06507 * w, y: minY + 0.94548 * h), controlPoint2:CGPoint(x: minX + 0.15616 * w, y: minY + h))
		smallpersonbodyPath.addLine(to: CGPoint(x: minX + 0.67013 * w, y: minY + h))
		smallpersonbodyPath.addCurve(to: CGPoint(x: minX + 0.97728 * w, y: minY + 0.75578 * h), controlPoint1:CGPoint(x: minX + 0.83977 * w, y: minY + h), controlPoint2:CGPoint(x: minX + 1.07426 * w, y: minY + 0.94548 * h))
		smallpersonbodyPath.addLine(to: CGPoint(x: minX + 0.6381 * w, y: minY + 0.00503 * h))
		smallpersonbodyPath.addCurve(to: CGPoint(x: minX + 0.50778 * w, y: minY + 0.02237 * h), controlPoint1:CGPoint(x: minX + 0.59672 * w, y: minY + 0.01632 * h), controlPoint2:CGPoint(x: minX + 0.553 * w, y: minY + 0.02237 * h))
		smallpersonbodyPath.addCurve(to: CGPoint(x: minX + 0.36031 * w, y: minY), controlPoint1:CGPoint(x: minX + 0.45626 * w, y: minY + 0.02237 * h), controlPoint2:CGPoint(x: minX + 0.40669 * w, y: minY + 0.01451 * h))
		smallpersonbodyPath.close()
		smallpersonbodyPath.move(to: CGPoint(x: minX + 0.36031 * w, y: minY))
		
		return smallpersonbodyPath;
	}
	
	func bagbodyPathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let bagbodyPath = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		bagbodyPath.move(to: CGPoint(x: minX + 0.06125 * w, y: minY))
		bagbodyPath.addCurve(to: CGPoint(x: minX, y: minY + 0.08211 * h), controlPoint1:CGPoint(x: minX + 0.02742 * w, y: minY), controlPoint2:CGPoint(x: minX, y: minY + 0.03676 * h))
		bagbodyPath.addLine(to: CGPoint(x: minX, y: minY + 0.91789 * h))
		bagbodyPath.addCurve(to: CGPoint(x: minX + 0.06125 * w, y: minY + h), controlPoint1:CGPoint(x: minX, y: minY + 0.96324 * h), controlPoint2:CGPoint(x: minX + 0.02742 * w, y: minY + h))
		bagbodyPath.addLine(to: CGPoint(x: minX + 0.93875 * w, y: minY + h))
		bagbodyPath.addCurve(to: CGPoint(x: minX + w, y: minY + 0.91789 * h), controlPoint1:CGPoint(x: minX + 0.97258 * w, y: minY + h), controlPoint2:CGPoint(x: minX + w, y: minY + 0.96324 * h))
		bagbodyPath.addLine(to: CGPoint(x: minX + w, y: minY + 0.08211 * h))
		bagbodyPath.addCurve(to: CGPoint(x: minX + 0.93875 * w, y: minY), controlPoint1:CGPoint(x: minX + w, y: minY + 0.03676 * h), controlPoint2:CGPoint(x: minX + 0.97258 * w, y: minY))
		bagbodyPath.close()
		bagbodyPath.move(to: CGPoint(x: minX + 0.06125 * w, y: minY))
		
		return bagbodyPath;
	}
	
	func baghandlePathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let baghandlePath = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		baghandlePath.move(to: CGPoint(x: minX + w, y: minY + h))
		baghandlePath.addCurve(to: CGPoint(x: minX + 0.86085 * w, y: minY + 0.00671 * h), controlPoint1:CGPoint(x: minX + w, y: minY + 0.79547 * h), controlPoint2:CGPoint(x: minX + 0.95433 * w, y: minY + 0.17765 * h))
		baghandlePath.addLine(to: CGPoint(x: minX + 0.65063 * w, y: minY + 0.00671 * h))
		baghandlePath.addLine(to: CGPoint(x: minX + 0.34197 * w, y: minY))
		baghandlePath.addLine(to: CGPoint(x: minX + 0.11314 * w, y: minY + 0.00671 * h))
		baghandlePath.addCurve(to: CGPoint(x: minX + 0.00066 * w, y: minY + 0.99958 * h), controlPoint1:CGPoint(x: minX + -0.0156 * w, y: minY + 0.26761 * h), controlPoint2:CGPoint(x: minX + 0.00066 * w, y: minY + 0.99958 * h))
		
		return baghandlePath;
	}
	
	func baglidPathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let baglidPath = UIBezierPath()
		let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
		
		baglidPath.move(to: CGPoint(x: minX, y: minY * h))
		baglidPath.addLine(to: CGPoint(x: minX + w, y: minY * h))
		baglidPath.addLine(to: CGPoint(x: minX, y: minY * h))
		
		return baglidPath;
	}
	
	func baglockPathWithBounds(_ bound: CGRect) -> UIBezierPath{
		let baglockPath = UIBezierPath(rect: bound)
		return baglockPath;
	}

}
