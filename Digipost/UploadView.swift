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
        Camera = CALayer()
        self.layer.addSublayer(Camera)
        Camera.setValue(-18 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        
        
        flash = CAShapeLayer()
        Camera.addSublayer(flash)
        flash.fillColor   = UIColor.digipostProfileTextColor().cgColor
        flash.strokeColor = UIColor.digipostProfileTextColor().cgColor
        flash.lineWidth   = 3
        
        body = CAShapeLayer()
        Camera.addSublayer(body)
        body.fillRule    = kCAFillRuleEvenOdd
        body.fillColor   = nil
        body.strokeColor = UIColor.digipostProfileTextColor().cgColor
        body.lineWidth   = 3
        
        handle = CAShapeLayer()
        Camera.addSublayer(handle)
        handle.fillColor   = nil
        handle.strokeColor = UIColor.digipostProfileTextColor().cgColor
        handle.lineWidth   = 3
        
        lens = CAShapeLayer()
        Camera.addSublayer(lens)
        lens.fillColor   = nil
        lens.strokeColor = UIColor.digipostProfileTextColor().cgColor
        lens.lineWidth   = 3
        
        Upload = CALayer()
        self.layer.addSublayer(Upload)
        
        
        Basket = CALayer()
        Upload.addSublayer(Basket)
        
        
        line = CAShapeLayer()
        Basket.addSublayer(line)
        line.fillColor   = nil
        line.strokeColor = UIColor.digipostProfileTextColor().cgColor
        line.lineWidth   = 3
        
        line2 = CAShapeLayer()
        Basket.addSublayer(line2)
        line2.fillColor   = nil
        line2.strokeColor = UIColor.digipostProfileTextColor().cgColor
        line2.lineWidth   = 3
        
        line3 = CAShapeLayer()
        Basket.addSublayer(line3)
        line3.setValue(-180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        line3.fillColor   = nil
        line3.strokeColor = UIColor.digipostProfileTextColor().cgColor
        line3.lineWidth   = 3
        
        Arrow = CALayer()
        Upload.addSublayer(Arrow)
        
        
        arrowbody = CAShapeLayer()
        Arrow.addSublayer(arrowbody)
        arrowbody.fillColor   = nil
        arrowbody.strokeColor = UIColor.digipostProfileTextColor().cgColor
        arrowbody.lineWidth   = 3
        
        leftarrow = CAShapeLayer()
        Arrow.addSublayer(leftarrow)
        leftarrow.fillColor   = nil
        leftarrow.strokeColor = UIColor.digipostProfileTextColor().cgColor
        leftarrow.lineWidth   = 3
        
        rightarrow = CAShapeLayer()
        Arrow.addSublayer(rightarrow)
        rightarrow.fillColor   = nil
        rightarrow.strokeColor = UIColor.digipostProfileTextColor().cgColor
        rightarrow.lineWidth   = 3
        
        animationText = CATextLayer()
        self.layer.addSublayer(animationText)
        animationText.contentsScale   = UIScreen.main.scale
        animationText.string          = "Hello World!"
        animationText.font            = "HelveticaNeue" as CFTypeRef?
        animationText.fontSize        = 17
        animationText.alignmentMode   = kCAAlignmentCenter;
        animationText.foregroundColor = UIColor.digipostProfileTextColor().cgColor;
        
        setupLayerFrames()
        
        self.layerWithAnims = [Camera, flash, body, handle, lens, Upload, Basket, line, line2, line3, Arrow, arrowbody, leftarrow, rightarrow, animationText]
    }
    
    
    func setupLayerFrames(){
        if Camera != nil{
            Camera.setValue(0, forKeyPath:"transform.rotation")
            Camera.frame = CGRect(x: 0.32726 * Camera.superlayer!.bounds.width, y: 0.27902 * Camera.superlayer!.bounds.height, width: 0.15972 * Camera.superlayer!.bounds.width, height: 0.12968 * Camera.superlayer!.bounds.height)
            Camera.setValue(-18 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
        }
        if flash != nil{
            flash.frame = CGRect(x: 0.88486 * flash.superlayer!.bounds.width, y: 0.28447 * flash.superlayer!.bounds.height, width: 0.02624 * flash.superlayer!.bounds.width, height: 0.04003 * flash.superlayer!.bounds.height)
            flash.path  = flashPathWithBounds(flash.bounds).cgPath;
        }
        if body != nil{
            body.frame = CGRect(x: -0.08684 * body.superlayer!.bounds.width, y: -0.02766 * body.superlayer!.bounds.height, width: 1.08684 * body.superlayer!.bounds.width, height: 1.02766 * body.superlayer!.bounds.height)
            body.path  = bodyPathWithBounds(body.bounds).cgPath;
        }
        if handle != nil{
            handle.frame = CGRect(x: 0.32829 * handle.superlayer!.bounds.width, y: 0, width: 0.33902 * handle.superlayer!.bounds.width, height: 0.18192 * handle.superlayer!.bounds.height)
            handle.path  = handlePathWithBounds(handle.bounds).cgPath;
        }
        if lens != nil{
            lens.frame = CGRect(x: 0.33782 * lens.superlayer!.bounds.width, y: 0.32229 * lens.superlayer!.bounds.height, width: 0.33536 * lens.superlayer!.bounds.width, height: 0.46295 * lens.superlayer!.bounds.height)
            lens.path  = lensPathWithBounds(lens.bounds).cgPath;
        }
        if Upload != nil{
            Upload.frame = CGRect(x: 0.50487 * Upload.superlayer!.bounds.width, y: 0.34088 * Upload.superlayer!.bounds.height, width: 0.15998 * Upload.superlayer!.bounds.width, height: 0.14337 * Upload.superlayer!.bounds.height)
        }
        if Basket != nil{
            Basket.frame = CGRect(x: 0, y: 0.57539 * Basket.superlayer!.bounds.height,  width: Basket.superlayer!.bounds.width, height: 0.42461 * Basket.superlayer!.bounds.height)
        }
        if line != nil{
            line.frame = CGRect(x: 0, y: 0.92717 * line.superlayer!.bounds.height,  width: line.superlayer!.bounds.width, height: 0.00354 * line.superlayer!.bounds.height)
            line.path  = linePathWithBounds(line.bounds).cgPath;
        }
        if line2 != nil{
            line2.frame = CGRect(x: 0.00399 * line2.superlayer!.bounds.width, y: 0.01647 * line2.superlayer!.bounds.height, width: 0.00754 * line2.superlayer!.bounds.width, height: 0.98353 * line2.superlayer!.bounds.height)
            line2.path  = line2PathWithBounds(line2.bounds).cgPath;
        }
        if line3 != nil{
            line3.setValue(0, forKeyPath:"transform.rotation")
            line3.frame = CGRect(x: 0.9983 * line3.superlayer!.bounds.width, y: 0, width: 0 * line3.superlayer!.bounds.width, height: 1 * line3.superlayer!.bounds.height)
            line3.setValue(-180 * CGFloat(M_PI)/180, forKeyPath:"transform.rotation")
            line3.path  = line3PathWithBounds(line3.bounds).cgPath;
        }
        if Arrow != nil{
            Arrow.frame = CGRect(x: 0.24897 * Arrow.superlayer!.bounds.width, y: 0, width: 0.50058 * Arrow.superlayer!.bounds.width, height: 0.63772 * Arrow.superlayer!.bounds.height)
        }
        if arrowbody != nil{
            arrowbody.frame = CGRect(x: 0.50004 * arrowbody.superlayer!.bounds.width, y: 0.00198 * arrowbody.superlayer!.bounds.height, width: 0 * arrowbody.superlayer!.bounds.width, height: 0.99802 * arrowbody.superlayer!.bounds.height)
            arrowbody.path  = arrowbodyPathWithBounds(arrowbody.bounds).cgPath;
        }
        if leftarrow != nil{
            leftarrow.frame = CGRect(x: 0, y: 0, width: 0.53327 * leftarrow.superlayer!.bounds.width, height: 0.50099 * leftarrow.superlayer!.bounds.height)
            leftarrow.path  = leftarrowPathWithBounds(leftarrow.bounds).cgPath;
        }
        if rightarrow != nil{
            rightarrow.frame = CGRect(x: 0.47544 * rightarrow.superlayer!.bounds.width, y: 0.01688 * rightarrow.superlayer!.bounds.height, width: 0.52456 * rightarrow.superlayer!.bounds.width, height: 0.48024 * rightarrow.superlayer!.bounds.height)
            rightarrow.path  = rightarrowPathWithBounds(rightarrow.bounds).cgPath;
        }
        if animationText != nil{
            animationText.frame = CGRect(x: 0.00463 * animationText.superlayer!.bounds.width, y: 0.60055 * animationText.superlayer!.bounds.height, width: 0.98983 * animationText.superlayer!.bounds.width, height: 0.28004 * animationText.superlayer!.bounds.height)
        }
    }
    
    
    @IBAction func startAllAnimations(_ sender: AnyObject!){
        self.animationAdded = false
        for layer in self.layerWithAnims{
            layer.speed = 1
        }
        
        flash?.add(flashAnimation(), forKey:"flashAnimation")
        body?.add(bodyAnimation(), forKey:"bodyAnimation")
        handle?.add(handleAnimation(), forKey:"handleAnimation")
        lens?.add(lensAnimation(), forKey:"lensAnimation")
        
        
        line?.add(lineAnimation(), forKey:"lineAnimation")
        line2?.add(line2Animation(), forKey:"line2Animation")
        line3?.add(line3Animation(), forKey:"line3Animation")
        Arrow?.add(ArrowAnimation(), forKey:"ArrowAnimation")
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
                let totalDuration : CGFloat = 3.83
                let offset = progress * totalDuration
                for layer in self.layerWithAnims{
                    layer.timeOffset = CFTimeInterval(offset)
                }
            }
        }
    }
    
    func flashAnimation() -> CAKeyframeAnimation{
        let transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)),
            NSValue(caTransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes = [0, 0.906, 0.95, 1]
        transformAnim.duration = 3.22
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.isRemovedOnCompletion = false
        
        return transformAnim;
    }
    
    func bodyAnimation() -> CAKeyframeAnimation{
        let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.605, 1]
        strokeEndAnim.duration = 1.99
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.isRemovedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func handleAnimation() -> CAKeyframeAnimation{
        let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.497, 0.819, 1]
        strokeEndAnim.duration = 2.42
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.isRemovedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func lensAnimation() -> CAKeyframeAnimation{
        let transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)),
            NSValue(caTransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes = [0, 0.908, 0.951, 1]
        transformAnim.duration = 3.23
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.isRemovedOnCompletion = false
        
        return transformAnim;
    }
    
    func lineAnimation() -> CAKeyframeAnimation{
        let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.853, 1]
        strokeEndAnim.duration = 3.36
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.isRemovedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func line2Animation() -> CAKeyframeAnimation{
        let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.836, 1]
        strokeEndAnim.duration = 2.91
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.isRemovedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func line3Animation() -> CAKeyframeAnimation{
        let strokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
        strokeEndAnim.values   = [0, 0, 1]
        strokeEndAnim.keyTimes = [0, 0.906, 1]
        strokeEndAnim.duration = 3.72
        strokeEndAnim.fillMode = kCAFillModeForwards
        strokeEndAnim.isRemovedOnCompletion = false
        
        return strokeEndAnim;
    }
    
    func ArrowAnimation() -> CAKeyframeAnimation{
        let transformAnim      = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values   = [NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)), 
            NSValue(caTransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5)), 
            NSValue(caTransform3D: CATransform3DIdentity)]
        transformAnim.keyTimes = [0, 0.949, 0.974, 1]
        transformAnim.duration = 3.83
        transformAnim.fillMode = kCAFillModeBoth
        transformAnim.isRemovedOnCompletion = false
        
        return transformAnim;
    }
    
    
    //MARK: - Bezier Path
    
    func flashPathWithBounds(_ bound: CGRect) -> UIBezierPath{
        let flashPath = UIBezierPath(ovalIn: bound)
        return flashPath;
    }
    
    func bodyPathWithBounds(_ bound: CGRect) -> UIBezierPath{
        let bodyPath = UIBezierPath()
        let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        bodyPath.move(to: CGPoint(x: minX + 0.66686 * w, y: minY + 0.18883 * h))
        bodyPath.addLine(to: CGPoint(x: minX + 0.66686 * w, y: minY + 0.18883 * h))
        bodyPath.addLine(to: CGPoint(x: minX + 0.952 * w, y: minY + 0.18843 * h))
        bodyPath.addCurve(to: CGPoint(x: minX + w, y: minY + 0.27299 * h), controlPoint1:CGPoint(x: minX + 0.97851 * w, y: minY + 0.18843 * h), controlPoint2:CGPoint(x: minX + w, y: minY + 0.22629 * h))
        bodyPath.addLine(to: CGPoint(x: minX + w, y: minY + 0.91544 * h))
        bodyPath.addCurve(to: CGPoint(x: minX + 0.952 * w, y: minY + h), controlPoint1:CGPoint(x: minX + w, y: minY + 0.96214 * h), controlPoint2:CGPoint(x: minX + 0.97851 * w, y: minY + h))
        bodyPath.addLine(to: CGPoint(x: minX + 0.1279 * w, y: minY + h))
        bodyPath.addCurve(to: CGPoint(x: minX + 0.0799 * w, y: minY + 0.91544 * h), controlPoint1:CGPoint(x: minX + 0.10139 * w, y: minY + h), controlPoint2:CGPoint(x: minX + 0.0799 * w, y: minY + 0.96214 * h))
        bodyPath.addLine(to: CGPoint(x: minX + 0.0799 * w, y: minY + 0.27299 * h))
        bodyPath.addCurve(to: CGPoint(x: minX + 0.1279 * w, y: minY + 0.18843 * h), controlPoint1:CGPoint(x: minX + 0.0799 * w, y: minY + 0.22629 * h), controlPoint2:CGPoint(x: minX + 0.10139 * w, y: minY + 0.18843 * h))
        bodyPath.addLine(to: CGPoint(x: minX + 0.40929 * w, y: minY + 0.18883 * h))
        bodyPath.move(to: CGPoint(x: minX, y: minY))
        
        return bodyPath;
    }
    
    func handlePathWithBounds(_ bound: CGRect) -> UIBezierPath{
        let handlePath = UIBezierPath()
        let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        handlePath.move(to: CGPoint(x: minX + 0.22186 * w, y: minY))
        handlePath.addCurve(to: CGPoint(x: minX, y: minY + h), controlPoint1:CGPoint(x: minX + 0.13063 * w, y: minY), controlPoint2:CGPoint(x: minX, y: minY + 0.86674 * h))
        handlePath.move(to: CGPoint(x: minX + w, y: minY + h))
        handlePath.addCurve(to: CGPoint(x: minX + 0.72629 * w, y: minY), controlPoint1:CGPoint(x: minX + w, y: minY + 0.86674 * h), controlPoint2:CGPoint(x: minX + 0.81752 * w, y: minY))
        handlePath.addLine(to: CGPoint(x: minX + 0.22186 * w, y: minY))
        
        return handlePath;
    }
    
    func lensPathWithBounds(_ bound: CGRect) -> UIBezierPath{
        let lensPath = UIBezierPath(ovalIn: bound)
        return lensPath;
    }
    
    func linePathWithBounds(_ bound: CGRect) -> UIBezierPath{
        let linePath = UIBezierPath()
        
        var minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        let device = UIDevice.current.userInterfaceIdiom
        if device == .pad { minY += 1 }
        
        linePath.move(to: CGPoint(x: minX, y: minY + h))
        linePath.addLine(to: CGPoint(x: minX + w, y: minY))
        
        return linePath;
    }
    
    func line2PathWithBounds(_ bound: CGRect) -> UIBezierPath{
        let line2Path = UIBezierPath()
        let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        line2Path.move(to: CGPoint(x: minX, y: minY))
        line2Path.addLine(to: CGPoint(x: minX + w, y: minY + h))
        
        return line2Path;
    }
    
    func line3PathWithBounds(_ bound: CGRect) -> UIBezierPath{
        let line3Path = UIBezierPath()
        let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        line3Path.move(to: CGPoint(x: minX * w, y: minY))
        line3Path.addLine(to: CGPoint(x: minX * w, y: minY + h))
        
        return line3Path;
    }
    
    func arrowbodyPathWithBounds(_ bound: CGRect) -> UIBezierPath{
        let arrowbodyPath = UIBezierPath()
        let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        arrowbodyPath.move(to: CGPoint(x: minX * w, y: minY + h))
        arrowbodyPath.addLine(to: CGPoint(x: minX * w, y: minY))
        
        return arrowbodyPath;
    }
    
    func leftarrowPathWithBounds(_ bound: CGRect) -> UIBezierPath{
        let leftarrowPath = UIBezierPath()
        let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        leftarrowPath.move(to: CGPoint(x: minX, y: minY + h))
        leftarrowPath.addLine(to: CGPoint(x: minX + w, y: minY))
        
        return leftarrowPath;
    }
    
    func rightarrowPathWithBounds(_ bound: CGRect) -> UIBezierPath{
        let rightarrowPath = UIBezierPath()
        let minX = CGFloat(bound.minX), minY = bound.minY, w = bound.width, h = bound.height;
        
        rightarrowPath.move(to: CGPoint(x: minX + w, y: minY + h))
        rightarrowPath.addLine(to: CGPoint(x: minX, y: minY))
        
        return rightarrowPath;
    }
    
}
