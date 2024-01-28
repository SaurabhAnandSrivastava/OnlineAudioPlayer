//
//  LoopSlideView.swift
//  Hngr
//
//  Created by Saurabh Srivastav on 11/08/22.
//

import UIKit

class LoopSlideView: UIView {
    private let imageViews: [UIImageView] = [.init(), .init()]
    private let labels: [UILabel] = [.init(), .init(), .init(), .init()]
    public var patternImage = #imageLiteral(resourceName: "NoRes")
    public var patternText = "text"
    public var patternFont : UIFont!
    public var lblColor = UIColor.black
    //let patternImage = #imageLiteral(resourceName: "WelcomBg")
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        self.backgroundColor = .clear
        
    }
    
    
    public func startAnimationWith(image:UIImage){
        patternImage = image
        for imageView in imageViews {
            imageView.image = patternImage
            imageView.contentMode = .scaleToFill
            imageView.clipsToBounds = true
            self.clipsToBounds = true
            self.addSubview(imageView)
        }
        //        for imageView in imageViews {
        //            imageView.image = patternImage
        //        }
        
        
    }
    
    
    public func startAnimationWith(text:String,font:UIFont){
        
        for subview in self.subviews {
            if subview.tag == 367234589 {
                subview.layer.removeAllAnimations()
                subview.removeFromSuperview()
            }
        }
        
        
        patternText = text
        patternFont = font
        for imageView in labels {
            imageView.text = patternText
            imageView.font = patternFont
            imageView.textColor = lblColor
            //imageView.contentMode = .scaleToFill
            imageView.clipsToBounds = true
            self.clipsToBounds = true
            imageView.tag = 367234589
            self.addSubview(imageView)
        }
        //        for imageView in imageViews {
        //            imageView.image = patternImage
        //        }
        
        
    }
    
    
    private func animateLbl(){
        //  let bounds = self.bounds
        let lbl = UILabel()
        lbl.text = patternText
        lbl.font = patternFont
        lbl.frame = CGRect(x: 0, y: 0, width: 50, height: 5)
        
        lbl.sizeToFit()
        let patternSize = lbl.frame.size
        // let scale = max(1 as CGFloat, bounds.size.width / patternSize.width, bounds.size.height / patternSize.height)
        let imageFrame = CGRect(x: 0, y: 0, width: 1 * patternSize.width+5, height: 1 * patternSize.height)
        var shouldAnimate = true
        
        if self.frame.width > imageFrame.width {
            //            lbl.frame = self.bounds
            //            lbl.tag = 367234589
            //            lbl.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            //            self.addSubview(lbl)
            shouldAnimate = false
            
        }
        
        
        for (i, imageView) in labels.enumerated() {
            //
            //imageView.frame = CGRect(x: 0, y: 0, width: patternSize.width, height: patternSize.height)
            imageView.frame = imageFrame.offsetBy(dx: CGFloat(i) * imageFrame.size.width, dy: 0)
            //imageView.clipsToBounds = true
           // print(imageView.frame)
            let animation = CABasicAnimation(keyPath: "transform.translation.x")
            animation.fromValue = 0
            animation.toValue = -imageFrame.size.width
            animation.duration = 20
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            
            // The following line prevents iOS from removing the animation when the app goes to the background.
            animation.isRemovedOnCompletion = false
            
            imageView.layer.add(animation, forKey: animation.keyPath)
            
            if !shouldAnimate {
                imageView.layer.removeAllAnimations()
                break
            }
            
            
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        animateLbl()
        
        //        let bounds = self.bounds
        //
        //
        //        let patternSize = patternImage.size
        //        let scale = max(1 as CGFloat, bounds.size.width / patternSize.width, bounds.size.height / patternSize.height)
        //        let imageFrame = CGRect(x: 0, y: 0, width: scale * patternSize.width, height: scale * patternSize.height)
        //
        //        for (i, imageView) in imageViews.enumerated() {
        //            imageView.frame = imageFrame.offsetBy(dx: CGFloat(i) * imageFrame.size.width, dy: 0)
        //            imageView.clipsToBounds = true
        //            let animation = CABasicAnimation(keyPath: "transform.translation.x")
        //            animation.fromValue = 0
        //            animation.toValue = -imageFrame.size.width
        //            animation.duration = 2
        //            animation.repeatCount = .infinity
        //            animation.timingFunction = CAMediaTimingFunction(name: .linear)
        //
        //            // The following line prevents iOS from removing the animation when the app goes to the background.
        //            animation.isRemovedOnCompletion = false
        //
        //            imageView.layer.add(animation, forKey: animation.keyPath)
        //        }
    }
    
    
}
