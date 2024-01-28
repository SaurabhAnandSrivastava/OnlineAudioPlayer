//
//  PlayerControl.swift
//  tesrt
//
//  Created by Saurabh Srivastav on 13/03/23.
//

import UIKit
import AVFAudio
import AVFoundation

class PlayerControl: UIView {
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var playBtnView: UIView!
    @IBOutlet weak var repetBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var playbtn: UIButton!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var shuffleBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var totalDuration: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var albumView: LoopSlideView!
    @IBOutlet weak var trackView: LoopSlideView!
   
    public var badgeColor = UIColor.red
    
    private var shuffleLayer = TaggedShapeLayer()
    private var repeteLayer = TaggedShapeLayer()
    
    var controllerTintColor = UIColor.red{
        didSet {
            
            slider.minimumTrackTintColor = .clear
           slider.maximumTrackTintColor = .clear
            
            changeButtonColor(button: likeBtn, color: controllerTintColor, state: .normal)
            changeButtonColor(button: nextBtn, color: controllerTintColor, state: .normal)
            changeButtonColor(button: playbtn, color: controllerTintColor, state: .normal)
            changeButtonColor(button: playbtn, color: controllerTintColor, state: .selected)
            changeButtonColor(button: previousBtn, color: controllerTintColor, state: .normal)
            changeButtonColor(button: shuffleBtn, color: controllerTintColor, state: .normal)
            //changeButtonColor(button: shuffleBtn, color: controllerTintColor, state: .selected)
            changeButtonColor(button: repetBtn, color: controllerTintColor, state: .normal)
            
            trackView.patternFont = UIFont.boldSystemFont(ofSize: 35)
          
            progressBar.progressTintColor = controllerTintColor
            progressBar.trackTintColor = controllerTintColor.withAlphaComponent(0.2)
            
        }
    }
    
    
    public var didChageProgressOfTrack:((Float)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        var kCONTENT_XIB_NAME = NSStringFromClass(type(of: self))
        
        let target = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        
        kCONTENT_XIB_NAME = kCONTENT_XIB_NAME.replacingOccurrences(of: "\(target).", with: "")
        
        let viewFromXib = Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        shuffleBtn.tag = 0
        repetBtn.tag = 1
        playBtnView.roundCorner(cornerRadious:playBtnView.frame.height/2 )
        
    }
  
    public func changeButtonColor(button:UIButton,color:UIColor,state:UIControl.State){
        button.changeButtonColor(color:color , state: state)
//        let orignalImage = button.image(for: state)
//        let tintedImage = orignalImage?.withRenderingMode(.alwaysTemplate)
//               button.setImage(tintedImage, for: state)
//
//               // Set the tint color
//               button.tintColor = color
    }

    
    
    @IBAction func sliderChanage(_ sender: Any) {
        progressBar.progress = slider.value
        self.didChageProgressOfTrack?(progressBar.progress)
        
    }
    
    public func badgeAction(btn:UIButton){
        
    }
    
   public func addBadge(btn:UIButton) {
       let size: CGSize = btn.frame.size
            let point = CGPoint(x: size.width-8, y: 0)

            let circle = TaggedShapeLayer()
            let path = UIBezierPath(arcCenter: CGPoint(x: point.x+2, y: 8), radius: 4, startAngle: 0, endAngle: .pi*2, clockwise: true)
            circle.path = path.cgPath
            circle.fillColor = badgeColor.cgColor
       circle.tag = btn.tag
            btn.layer.addSublayer(circle)
       if btn.tag == 0 {
           shuffleLayer = circle
       }
       else {
           repeteLayer = circle
       }
       
        }
    public func removeBadge(btn:UIButton) {
        
        if btn.tag == 0 {
            shuffleLayer.removeFromSuperlayer()
        }
        else {
            repeteLayer.removeFromSuperlayer()
        }
    }
       
}
