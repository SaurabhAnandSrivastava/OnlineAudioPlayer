//
//  AudioPlayerMini.swift
//  tesrt
//
//  Created by Saurabh Srivastav on 09/03/23.
//

import UIKit
import AVKit
import Photos
import MediaPlayer
class AudioPlayerMini: UIView {
    
    
    // MARK: - Variables ⬇️
    @IBOutlet weak var playerBgImage: UIImageView!
    @IBOutlet weak var albumView: LoopSlideView!
    @IBOutlet weak var trackView: LoopSlideView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    private var playerConfig = AudioPlayerConfiguration()
    
   
   
    public var didPressFullScreen:(()->())?
    
    public var config: AudioPlayerConfiguration! {
        
        set {
            playerConfig = newValue
            playerUIConfig()
        }
        
        get {
            return playerConfig
            
        }
    }
  
    
    
    // MARK: - class methods⬇️
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
        
        activityLoader.hidesWhenStopped = true
        
        self.roundCorner(cornerRadious: 10)
        thumbImage.roundCorner(cornerRadious: 10)
        //let text  = "T"
        
        playerUIConfig()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
        
    }
    
  
    
    
    // MARK: - Gesture ⬇️
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
       didPressFullScreen?()
    }
    
    

    


    
    // MARK: - configs  ⬇️
    private func playerUIConfig(){
        likeBtn.tintColor = config.controlColor
        playBtn.tintColor = config.controlColor
        nextBtn.tintColor = config.controlColor
        albumView.lblColor = config.albumNameColor
        trackView.lblColor = config.trackNameColor
        progressBar.progressTintColor = config.controlColor
        progressBar.trackTintColor = config.controlColor.withAlphaComponent(0.2)
        activityLoader.color = config.controlColor
    }
   

    }

   


