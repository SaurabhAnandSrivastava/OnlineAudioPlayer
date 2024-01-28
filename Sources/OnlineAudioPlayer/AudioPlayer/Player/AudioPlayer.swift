//
//  AudioPlayer.swift
//  tesrt
//
//  Created by Saurabh Srivastav on 09/03/23.
//

import UIKit
import AVKit
import Photos
class AudioPlayer: UIView {

    // MARK: - Variables ⬇️
    
    public var didPressLike:((_ track:AudioTrackDataModel,_ isLiked:Bool)->())?
    public var didStartPlaying:((_ currentTrack:AudioTrackDataModel)->())?
    public var didStopPlaying:((_ currentTrack:AudioTrackDataModel)->())?
    public var didPressNext:((_ nextTrack:AudioTrackDataModel,_ index:Int)->())?
    public var didPressPrevious:((_ previousTrack:AudioTrackDataModel,_ index:Int)->())?
    public var didEnterInFullScreen:(()->())?
    public var didExitFullScreen:(()->())?
    public var currentPlayingDuration:((_ currentTime:Int,_ totalDuration:Int)->())?
    public var didPressShuffle:((_ shouldShuffle:Bool)->())?
    public var didPressRepeat:((_ shouldShuffle:Bool)->())?
    
    
    @IBOutlet weak var playerControllers: PlayerControl!
    @IBOutlet weak var playerBgImage: UIImageView!
   // @IBOutlet weak var albumView: LoopSlideView!
    //@IBOutlet weak var trackView: LoopSlideView!
   // @IBOutlet weak var nextBtn: UIButton!
   // @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    //@IBOutlet weak var playBtn: UIButton!
    //@IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var exitFullScreenBtn: UIButton!
    
    @IBOutlet var mainView: UIView!
    private var playerLayer1 : AVPlayerLayer!
    private var autoP = false
    private var audioWebUrl = String()
    private var buffringtimer = Timer()
    private var isObsr = false
    public var audioTracks = [AudioTrackDataModel]()
    private var playingIndex : Int!
    private var playerConfig = AudioPlayerConfiguration()
    private let bgPlayer = BackgroundPlayer()
    private let cellCache = NSCache<NSString, AVQueuePlayer>()
    private var isRepete = false
    private var isMiniPlayer = false
    var miniPlayer : AudioPlayerMini!
    
    public var didPressFullScreen:(()->())?
    public var player : AVQueuePlayer!
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private var currentTrackTotalDuration : CMTime!
    
    public var config: AudioPlayerConfiguration! {
        
        set {
            playerConfig = newValue
            playerUIConfig()
        }
        
        get {
            return playerConfig
            
        }
    }
    public var tracks: [AudioTrackDataModel]! {
        
        set {
            audioTracks = newValue
            if newValue.count>0 {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    didStartPlaying?(audioTracks[playingIndex])
                }
                playAudio(track: audioTracks[0], autoPlay: true)
            }
            
            
            
        }
        
        get {
            return audioTracks
            
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("stopAllPlayer"), object: nil)
       
        
        feedbackGenerator.prepare()
        shouldPlayWithDeviceBg()
        activityLoader.hidesWhenStopped = true
        
        self.roundCorner(cornerRadious: 10)
        thumbImage.roundCorner(cornerRadious: 10)
        //let text  = "T"
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        thumbImage.addGestureRecognizer(longPressGesture)
        
        playerUIConfig()
        setupRemoteTransportControls()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
        
        
        
        
        
    }
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
           if gesture.state == .began {
               // Handle the long press gesture
               print("Long press detected!")
               UIView.animate(withDuration: 0.2) { [self] in
                   thumbImage.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
               }
           }
        if gesture.state == .ended {
            UIView.animate(withDuration: 0.2) { [self] in
                thumbImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
        feedbackGenerator.impactOccurred()
       }
    // MARK: - Gesture ⬇️
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
     
        enterFullScreen()
        
        
    }
    
    // MARK: - Bg player config ⬇️
    private func shouldPlayWithDeviceBg(){
        
        
        do {
            try AVAudioSession.sharedInstance()
                .setCategory(AVAudioSession.Category.playback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
    func setupRemoteTransportControls() {
        
        
        bgPlayer.configBgPlayer()
        bgPlayer.didCallNext = { [self] in
           
            playNext()
        }
        bgPlayer.didCallPreview = { [self] in
            if playingIndex == nil {
                playingIndex = 0
            }
            playPrevious()
        }
        bgPlayer.didCallPause = { [self] in
            playerControllers.playbtn.isSelected = true
            if isMiniPlayer {
                miniPlayer.playBtn.isSelected = true
            }
        }
        bgPlayer.didCallPause = { [self] in
            playerControllers.playbtn.isSelected = false
            if isMiniPlayer {
                miniPlayer.playBtn.isSelected = true
            }
        }
    }
    func setupNowPlaying() {
        
        
        // Define Now Playing Info
        let radio = audioTracks[playingIndex].isRadio
        
      
        
        bgPlayer.currentPlayer = player
        bgPlayer.updateBgPlayer(trackName:tracks[playingIndex].trackName! , albumName: tracks[playingIndex].albumName!, albumPicUrl: tracks[playingIndex].albumPic, isRadio: radio)
        
        
    }
    
    // MARK: - configs  ⬇️
    
    private func cnofigController(){
        
        
        
    }
    
    private func playerUIConfig(){
        
        playerControllers.controllerTintColor = config.controlColor
       
            exitFullScreenBtn.changeButtonColor(color:config.controlColor , state: .normal)
        
       // let orignalImage = exitFullScreenBtn.image(for: .normal)
        activityLoader.color = config.controlColor
        playerControllers.playbtn.addTarget(self, action: #selector(playAction( _ :)), for: .touchUpInside)
        playerControllers.nextBtn.addTarget(self, action: #selector(nextAction( _ :)), for: .touchUpInside)
        playerControllers.previousBtn.addTarget(self, action: #selector(previousAction( _ :)), for: .touchUpInside)
        playerControllers.shuffleBtn.addTarget(self, action: #selector(shuffleAction( _ :)), for: .touchUpInside)
        playerControllers.repetBtn.addTarget(self, action: #selector(repeteAction( _ :)), for: .touchUpInside)
        playerControllers.likeBtn.addTarget(self, action: #selector(likeAction( _ :)), for: .touchUpInside)
        playerControllers.badgeColor = config.badgeColor
      
        
        playerControllers.didChageProgressOfTrack =  { [self] progress in
            didJumpToTime(percentage: progress)
        }
        
        if config.startWithMiniPlayer {
            exitFullScreen(withAnimation: false)
        }
        
        
    }
    private func configPlayer(url: String) {
        let videoU = url
        let videoURL = URL(string: videoU)
        if videoURL == nil{
            return
        }
        let playerItem = AVPlayerItem(url: videoURL!)
        if let cachedVersion = cellCache.object(forKey: "\(url)" as NSString) {
            player = cachedVersion
            
        }
        else {
            
            
            
            
            if player == nil {
                player = AVQueuePlayer(playerItem: playerItem)
                player.automaticallyWaitsToMinimizeStalling = false
               
                if playerLayer1 == nil {
                    playerLayer1 = AVPlayerLayer(player: player)
                }
                
                
                //player1.isMuted = true
                audioView.layer.addSublayer(playerLayer1)
            }
            
            
            
            
            
            
            // cellCache.setObject(player, forKey: "\(url)" as NSString)
        }
        
        // playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        
        playerLayer1.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            DispatchQueue.main.async { [self] in
                
                if playerLayer1 != nil {
                    playerLayer1.frame = self.bounds
                }
                
            }
        }
        
        
    }
    private func getTotalTime() async{
        
        var totaltime = Double()
        do {
            let duration = try await (player?.currentItem?.asset.load(.duration))
            
            if duration != nil{
                if (!duration!.seconds.isNaN){
                    let seconds = CMTimeGetSeconds(duration!)
                    let secondString = String(format: "%02d", Int(seconds) % 60)
                    let minutString = String(format: "%02d", Int(seconds) / 60)
                    //self.currentTimeLabel.text = "\(minutString):\(secondString)"
                    if audioTracks[playingIndex].isRadio{
                        playerControllers.totalDuration.text = "--:--"
                    }
                    else {
                        playerControllers.totalDuration.text = "\(minutString):\(secondString)"
                    }
                    totaltime = duration!.seconds
                    currentTrackTotalDuration = duration
                   
                }
                
            }
            //all fine with jsonData here
        } catch {
            //handle error
            print(error)
        }
        
        
        let interval = CMTime(value: 1, timescale: 1)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [self] (progressTime) in
            
            let seconds = CMTimeGetSeconds(progressTime)
            let secondString = String(format: "%02d", Int(seconds) % 60)
            let minutString = String(format: "%02d", Int(seconds) / 60)
            
            
           
            
            
            DispatchQueue.main.async { [self] in
                
                if currentTrackTotalDuration != nil {
                   
                    let seconds = CMTimeGetSeconds(currentTrackTotalDuration - progressTime)
                    let secondString = String(format: "%02d", Int(seconds) % 60)
                    let minutString = String(format: "%02d", Int(seconds) / 60)
                    if audioTracks[playingIndex].isRadio{
                        playerControllers.totalDuration.text = "--:--"
                    }
                    else {
                        playerControllers.totalDuration.text = "-\(minutString):\(secondString)"
                    }
                   
                   
                }
                DispatchQueue.main.async { [self] in
                    let current = Int(seconds)
                    if currentTrackTotalDuration != nil {
                        currentPlayingDuration?(Int(CMTimeGetSeconds(currentTrackTotalDuration)),current)
                    }
                    
                }
                
                
                playerControllers.currentTime.text = "\(minutString):\(secondString)"
                
                playerControllers.progressBar.progress = Float(seconds/totaltime)
                playerControllers.slider.value = playerControllers.progressBar.progress
                if isMiniPlayer {
                    miniPlayer.progressBar.progress = Float(seconds/totaltime)
                }
            }
            
        })
    }
    
    private func didJumpToTime(percentage:Float){
        if currentTrackTotalDuration != nil {
            let seconds = CMTimeGetSeconds(currentTrackTotalDuration!)
            
            
            let newTime = seconds * Float64(percentage)
            
            let time = CMTime(seconds: newTime, preferredTimescale: 1000)
                    
                    // Seek to the specified time
                    player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { (finished) in
                        if finished {
                            // Start playing after seeking
                            self.player?.play()
                        }
                    }
            
        }
    }
    
    
    // MARK: - Player settings⬇️
    private func reloadLayer(){
        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
        DispatchQueue.main.async { [self] in
            
            if playerLayer1 != nil {
                playerLayer1.frame = self.bounds
            }
            
        }
        // }
    }
    private func removePlayer(){
        if player != nil{
            removeObsever(plyr: player)
            player.pause()
            player.removeAllItems()
            player = nil
            // playerLooper = nil
            // thumbImage.image = nil
            if playerLayer1 != nil{
                playerLayer1.removeFromSuperlayer()
            }
            buffringtimer.invalidate()
            playerLayer1 = nil
        }
    }
    
    public func addTrackToCurrentList (tracks:[AudioTrackDataModel]){
        var shouldPlay = false
        if audioTracks.count == 0 {
            shouldPlay = true
        }
        audioTracks.append(contentsOf: tracks)
        if shouldPlay {
            if audioTracks.count > 0 {
                playAudio(track: audioTracks[0], autoPlay: true)
            }
            
        }
    }
    // MARK: - Player Options⬇️
    public func playAudioFromLocal(audioName:String,type:String){
        //        guard let path = Bundle.main.path(forResource: videoName, ofType:type) else {
        //                    debugPrint("video.m4v not found")
        //                    return
        //                }
        //        print(path)
        let videoURL: NSURL = Bundle.main.url(forResource: "welcom", withExtension: "mp4")! as NSURL
        
        loadAudioUrl(audioU: videoURL.absoluteString!, autoPlay: false)
        player.play()
        // playerLooper = nil
        playerControllers.playbtn.isHidden = true
        
        
    }
    public func playRecodedAudio(url: String,autoPlay:Bool){
        var videoU = String()
        
        videoU = url
        
        loadAudioUrl(audioU: videoU, autoPlay: autoPlay)
        
        
    }
    public func playAudio(track: AudioTrackDataModel,autoPlay:Bool) {
        if playingIndex == nil {
            playingIndex = 0
        }
        var videoU = String()
        if !track.audioUrl!.contains("http") {
            videoU = "http://" + track.audioUrl!
        }
        else{
            videoU = track.audioUrl!
        }
        
        if videoU.components(separatedBy: .whitespaces).joined().count == 0 {
            return
        }
        
        if audioTracks[playingIndex].isRadio {
            playerBgImage.image = UIImage(named: "defaultRadio.png")
            thumbImage.image = UIImage(named: "defaultRadio.png")
        }
        else {
            playerBgImage.image = UIImage(named: "defaultTrack.png")
            thumbImage.image = UIImage(named: "defaultTrack.png")
        }
        
        
       
        if isMiniPlayer {
            miniPlayer.playerBgImage.image = playerBgImage.image
            miniPlayer.thumbImage.image = thumbImage.image
        }
        
        
        if track.albumPic != nil  {
            thumbImage.getImageFromUrl(imgUrl: track.albumPic!, shouldBeforeNil: false, completionHandler: { [self]
                img,picUrl in
                thumbImage.image = img
                playerBgImage.image = img
                
                if isMiniPlayer {
                    miniPlayer.thumbImage.image = img
                    miniPlayer.playerBgImage.image = img
                }
                
                //playerBgImage.backgroundColor = thumbImage.pa
            })
        }
        
        playerControllers.trackView.lblColor = config.trackNameColor
        playerControllers.albumView.lblColor = config.albumNameColor
        playerControllers.trackView.startAnimationWith(text: track.trackName!, font: .systemFont(ofSize: 15))
        playerControllers.albumView.startAnimationWith(text: track.albumName!, font: .systemFont(ofSize: 13))
        activityLoader.startAnimating()
        if isMiniPlayer {
            miniPlayer.trackView.startAnimationWith(text: track.trackName!, font: .systemFont(ofSize: 15))
            miniPlayer.albumView.startAnimationWith(text: track.albumName!, font: .systemFont(ofSize: 13))
            miniPlayer.activityLoader.startAnimating()
        }
        
        
        
       
        audioWebUrl = videoU
        // videoU = videoU.removingWhitespaces()
        if playingIndex == nil {
            playingIndex = 0
        }
        
        loadAudioUrl(audioU: videoU, autoPlay: autoPlay)
        
        
//        Cache.checkIfFileExists(url: videoU, completionHandler: { [self] fileUrl , isExists in
//
//            if isExists{
//                loadAudioUrl(audioU: fileUrl, autoPlay: autoPlay)
//            }
//            else{
//                loadAudioUrl(audioU: videoU, autoPlay: autoPlay)
//
//                Cache.getFileWith(stringUrl: videoU) { [self] result,isExisted  in
//                    // removePlayer()
//
//
//                    switch result {
//                    case .success(let url):
//                        print(url.absoluteString)
//                        let fileURL = URL(string: audioWebUrl)!.lastPathComponent
//
//                        let urlURL = url.lastPathComponent
//
//                        if fileURL == urlURL {
//
//                            loadAudioUrl(audioU: url.absoluteString, autoPlay: autoPlay)
//                        }
//
//                        // do some magic with path to saved video
//                    case .failure(let error):
//                        // handle errror
//                        // loadVideoUrl(videoU: videoU, autoPlay: autoPlay)
//                        print(error.localizedDescription)
//                    }
//                }
//
//
//
//
//            }
//
//
//        })
        setupNowPlaying()
        // loadVideoUrl(videoU: videoU, autoPlay: autoPlay)
        //let cache = Cache()
        
        
        
        //  thumbImage.showVideoThumb(videoUrl: url, size:CGSize(width: thumbImage.frame.width*2, height: thumbImage.frame.height*2) )
        
        // return
        
        //addObservr(plyr: player)
        
    }
    private func loadAudioUrl(audioU:String,autoPlay:Bool){
        configPlayer(url: audioU)
        playerControllers.playbtn.isHidden = false
        //  muteBtn.isHidden = false
        
        
        //  let vUrl = (player.currentItem?.asset as? AVURLAsset)?.url.absoluteString
        
        
        
        let playerItem = AVPlayerItem(url: URL(string: audioU)!)
        player.replaceCurrentItem(with: playerItem)
        
        
        if autoPlay {
            
            if audioTracks[playingIndex].isRadio {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                    player.play()
                    
                   
                    
                }
            }
            else {
                player.play()
            }
            
            

            
            
            playerControllers.playbtn.isSelected = true
            // activityLoader.stopAnimating()
            // playFoodBtn.isSelected = true
        }
        else{
            player.pause()
            //activityLoader.startAnimating()
        }
        
        autoP = autoPlay
        player.automaticallyWaitsToMinimizeStalling = false
        player.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        player.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        if #available(iOS 10.0, *) {
            player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        } else {
            player.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        }
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(playerDidFinishPlaying),
                         name: .AVPlayerItemDidPlayToEndTime,
                         object: player.currentItem
            )
    }
    public func playaLibAudio( asset: PHAsset) {
        guard asset.mediaType == .video
        else {
            print("Not a valid video media type")
            return
        }
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        PHCachingImageManager().requestPlayerItem(forVideo: asset, options: options) { (playerItem, info) in
            DispatchQueue.main.async { [self] in
                if playerLayer1 != nil{
                    playerLayer1.removeFromSuperlayer()
                    playerLayer1 = nil
                }
                if player != nil {
                    
                    player.replaceCurrentItem(with: playerItem)
                    // playerLooper = AVPlayerLooper(player: player, templateItem: playerItem!)
                    // player.play()
                    
                }
                else{
                    
                    player = AVQueuePlayer(playerItem: playerItem)
                    
                    player.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
                    if #available(iOS 10.0, *) {
                        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
                    } else {
                        player.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
                    }
                    
                    
                    // playFoodBtn.isSelected = true
                    
                }
                
                playerLayer1 = AVPlayerLayer(player: player)
                
                // playerLooper = AVPlayerLooper(player: player, templateItem: playerItem!)
                
                playerLayer1.frame = self.bounds
                playerLayer1.videoGravity = AVLayerVideoGravity.resizeAspect
                //player1.isMuted = true
                audioView.layer.addSublayer(playerLayer1)
                //self.addSubview(playBtn)
                
                player.play()
                
            }
            
            
        }
    }
    
    // MARK: - Player Actions ⬇️
    private func endPlaying(){
        playerControllers.playbtn.isSelected = false
        autoP = false
        pausePlayer()
        buffringtimer.invalidate()
        if player != nil {
            removeObsever(plyr: player)
        }
        
        activityLoader.stopAnimating()
        
        
        
        
    }
    private func stopPlayer(){
        endPlaying()
    }
    private func playNext(){
        removePlayer()
       
        if !isRepete {
            playingIndex = playingIndex+1
        }
        
        if playingIndex >= audioTracks.count{
            playingIndex = 0
        }
        
        playAudio(track: audioTracks[playingIndex], autoPlay: true)
        didPressNext?(audioTracks[playingIndex],playingIndex)
    }
    private func playPrevious(){
        removePlayer()
        if !isRepete {
            playingIndex = playingIndex-1
        }
       
        if playingIndex < 0{
            playingIndex = 0
        }
        
        playAudio(track: audioTracks[playingIndex], autoPlay: true)
        didPressPrevious?(audioTracks[playingIndex],playingIndex)
    }
  
  
    private func pausePlayer(){
        // player1 = nil
        //player2 = nil
        if player != nil {
            player.pause()
            activityLoader.stopAnimating()
        }
        
        
        
    }
    
    public func playPausePlayer(){
        
       
        
        
        playerControllers.playbtn.isSelected = !playerControllers.playbtn.isSelected
        if isMiniPlayer {
            miniPlayer.playBtn.isSelected = playerControllers.playbtn.isSelected
        }
        
        
        if player != nil {
            if  playerControllers.playbtn.isSelected {
                player.play()
                didStartPlaying?(audioTracks[playingIndex])
            }
            else{
                player.pause()
                didStopPlaying?(audioTracks[playingIndex])
                activityLoader.stopAnimating()
                if isMiniPlayer {
                    miniPlayer.activityLoader.stopAnimating()
                }
            }
        }
    }
   
    public func startBuffring(){
        activityLoader.startAnimating()
        player.pause()
        playerControllers.playbtn.isSelected = false
        if isMiniPlayer{
            miniPlayer.playBtn.isSelected = false
            miniPlayer.activityLoader.startAnimating()
        }
        
    }
    public func resume(){
        activityLoader.stopAnimating()
        player.play()
        playerControllers.playbtn.isSelected = true
        if isMiniPlayer{
            miniPlayer.playBtn.isSelected = true
            miniPlayer.activityLoader.stopAnimating()
        }
        
    }
    
    @objc func checkBuffer() {
        if player != nil {
            
            if let currentItem = player.currentItem {
                if currentItem.status == AVPlayerItem.Status.readyToPlay {
                    if currentItem.isPlaybackLikelyToKeepUp {
                        //                        activityLoader.stopAnimating()
                        //                        //buffringtimer.invalidate()
                        //                        print("Buffering end")
                        print("Buffering end")
                        buffringtimer.invalidate()
                       // if  playerControllers.playbtn.isSelected{
                            player.play()
                        //}
                        activityLoader.stopAnimating()
                        playerControllers.playbtn.isSelected = true
                        if isMiniPlayer{
                            miniPlayer.playBtn.isSelected = true
                            miniPlayer.activityLoader.stopAnimating()
                        }
                        
                    }
                    else if currentItem.isPlaybackBufferFull{
                        activityLoader.stopAnimating()
                        //buffringtimer.invalidate()
                        print("Buffering end")
                        buffringtimer.invalidate()
                        //if  playerControllers.playbtn.isSelected{
                            player.play()
                        //}
                        
                        playerControllers.playbtn.isSelected = true
                        if isMiniPlayer{
                            miniPlayer.playBtn.isSelected = true
                            miniPlayer.activityLoader.stopAnimating()
                        }
                    }
                    else {
                        print("Buffering..")
                        if isMiniPlayer {
                            miniPlayer.activityLoader.startAnimating()
                            miniPlayer.playBtn.isSelected = false
                        }
                        playerControllers.playbtn.isSelected = false
                        activityLoader.startAnimating()
                        
                        
                    }
                } else if currentItem.status == AVPlayerItem.Status.failed {
                    print("Failed ")
                    buffringtimer.invalidate()
                } else if currentItem.status == AVPlayerItem.Status.unknown {
                    print("Unknown ")
                    buffringtimer.invalidate()
                }
            } else {
                buffringtimer.invalidate()
                print("avPlayer.currentItem is nil")
            }
        }
    }
    
    @IBAction func muteAction(_ sender: Any) {
        
        //        muteBtn.isSelected = !muteBtn.isSelected
        //
        //        if muteBtn.isSelected {
        //            player.isMuted = true
        //        }
        //        else{
        //            player.isMuted = false
        //        }
        // mutePressed?(FeedManager.shared.ismute)
        
    }
    @IBAction func playAction(_ sender: Any) {
        
        
        //  return
        playPausePlayer()
       
        
        
        
    }
    @IBAction func nextAction(_ sender: Any) {
        playNext()
    }
    @IBAction func previousAction(_ sender: Any) {
        playPrevious()
    }
    
    @objc func shuffleAction(_ sender: Any){
        playerControllers.shuffleBtn.isSelected = !playerControllers.shuffleBtn.isSelected
        if playerControllers.shuffleBtn.isSelected {
            audioTracks.shuffle()
            playerControllers.addBadge(btn: playerControllers.shuffleBtn)
        }
        else{
            audioTracks = tracks
            playerControllers.removeBadge(btn: playerControllers.shuffleBtn)
        }
        didPressShuffle?(playerControllers.shuffleBtn.isSelected)
       // playerControllers.addlabelBadge(btn: playerControllers.shuffleBtn)
        
    }
    @objc func repeteAction(_ sender: Any){
        playerControllers.repetBtn.isSelected = !playerControllers.repetBtn.isSelected
        if playerControllers.repetBtn.isSelected {
            
            playerControllers.addBadge(btn: playerControllers.repetBtn)
        }
        else{
            
            playerControllers.removeBadge(btn: playerControllers.repetBtn)
        }
        isRepete = playerControllers.repetBtn.isSelected
        didPressRepeat?(playerControllers.repetBtn.isSelected)
    }
    @objc func likeAction(_ sender: Any){
        
        if isMiniPlayer {
            miniPlayer.likeBtn.isSelected = !playerControllers.likeBtn.isSelected
        }
        
        playerControllers.likeBtn.isSelected = !playerControllers.likeBtn.isSelected
        didPressLike?(audioTracks[playingIndex],playerControllers.likeBtn.isSelected)
       
       
    }
    // MARK: - Observers ⬇️
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        
        if object as AnyObject? === player {
            if keyPath == "status" {
                
                if player.status == .readyToPlay {
                    Task {
                        await getTotalTime()
                    }
                    activityLoader.stopAnimating()
                    if isMiniPlayer {
                        miniPlayer.activityLoader.stopAnimating()
                    }
                    
                    
                    if autoP {
                        
                        player.play()
                        
                        
                        playerControllers.playbtn.isSelected = true
                    }
                    else{
                        playerControllers.playbtn.isSelected = false
                    }
                    if isMiniPlayer {
                        miniPlayer.playBtn.isSelected = playerControllers.playbtn.isSelected
                    }
                    
                    
                }
            } else if keyPath == "timeControlStatus" {
                
                if #available(iOS 10.0, *) {
                    
                    // muteBtn.isHidden = playThumb
                    
                    activityLoader.stopAnimating()
                    if player.timeControlStatus == .playing {
                        print("playing..")
                        
                        activityLoader.stopAnimating()
                        
                        
                        playerControllers.playbtn.isSelected = true
                        
                        activityLoader.stopAnimating()
                        buffringtimer.invalidate()
                        if isMiniPlayer {
                            miniPlayer.playBtn.isSelected = true
                            miniPlayer.activityLoader.stopAnimating()
                        }
                        
                        
                        
                    } 
                    
                    else {
                        print("buffring start..")
                        activityLoader.startAnimating()
                        buffringtimer.invalidate()
                        playerControllers.playbtn.isSelected = false
                        //activityLoader.stopAnimating()
                        buffringtimer.invalidate()
                        //buffringtimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkBuffer), userInfo: nil, repeats: true)
                        if isMiniPlayer {
                            miniPlayer.activityLoader.startAnimating()
                            miniPlayer.playBtn.isSelected = false

                        }
                        
                        
                    }
                }
            } else if keyPath == "rate" {
                print("buffringeeert..")
                if player.rate > 0 {
                    //videoCell?.muteButton.isHidden = false
                } else {
                    //videoCell?.muteButton.isHidden = true
                }
            }
        }
        
    }
    private func removeObsever(plyr:AVQueuePlayer){
        if  isObsr {
            plyr.removeObserver(self, forKeyPath: "status", context: nil)
            if #available(iOS 10.0, *) {
                plyr.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
            } else {
                plyr.removeObserver(self, forKeyPath: "rate", context: nil)
            }
            isObsr = false
        }
        
    }
    private func addObservr(plyr:AVQueuePlayer){
        
        plyr.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        if #available(iOS 10.0, *) {
            plyr.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        } else {
            plyr.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        }
        isObsr = true
        
        //        plyr.currentItem!.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        //        plyr.currentItem!.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        //        plyr.currentItem!.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        
    }
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        if config.autoPlayList {
            playNext()
        }
        else {
            removePlayer()
            playAudio(track: tracks[playingIndex], autoPlay: false)
        }
        
        
    }
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        endPlaying()
    }
    
    
    private func enterFullScreen(){
        isMiniPlayer = false
        miniPlayer.removeFromSuperview()
        if let con = getTopConstraint(view: self){
            con.constant = 0
            playerControllers.isHidden = true
            thumbImage.isHidden = true
//            UIView.animate(withDuration: 0.5) { [self] in
//                mainView.layoutIfNeeded()
//            }
        }
        else {
            
            UIView.animate(withDuration: 0.5, animations: { [self] in
                self.frame = self.superview!.bounds
                self.autoresizingMask = [.flexibleWidth,.flexibleHeight]
                
            }, completion: { _ in
               
            })
            
            
            
        }
        
        
        
        UIView.animate(withDuration: 0.5, animations: { [self] in
            miniPlayer.frame = CGRect(x: 20, y: 120, width: Double( (self.superview?.frame.width)!)-config.miniPlayerBottomPadding, height: 80.0)
            
        }, completion: { [self]_ in
            miniPlayer.removeFromSuperview()
            playerControllers.isHidden = false
            thumbImage.isHidden = false
        })
        didEnterInFullScreen?()
    }
    private func exitFullScreen(withAnimation:Bool){
        
        var duration = 0.0
        
        if withAnimation{
            duration = 0.5
        }
        
        if miniPlayer == nil {
            miniPlayer = AudioPlayerMini()
            
        }
        isMiniPlayer = true
        
        if let con = getTopConstraint(view: self){
            con.constant = self.frame.height
            UIView.animate(withDuration: 0.5) { [self] in
                self.layoutSubviews()
            }
        }
        else {
            UIView.animate(withDuration: duration, animations: { [self] in
                self.frame = CGRect(x:self.frame.origin.x , y: (self.superview?.frame.height)!-config.miniPlayerBottomPadding, width: self.frame.width, height: self.frame.height)
                
            }, completion: { [self] _ in
                miniPlayer.frame = CGRect(x: 20, y: (self.superview?.frame.height)!-config.miniPlayerBottomPadding ,width: Double( (self.superview?.frame.width)!)-40, height: 80.0)
                self.frame = CGRect(x:self.frame.origin.x , y: (self.superview?.frame.height)!, width: self.frame.width, height: self.frame.height)
                self.superview?.addSubview(miniPlayer)
               
            })
            
            
            
            
        }

       
        
       
       
        
       
        
        
        didExitFullScreen?()
       
        
        
        configMiniPlayer()
    }
    
    
    @IBAction func exitFullScreenAction(_ sender: Any) {
       
        exitFullScreen(withAnimation: true)
        
        
    }
    
    
    private func configMiniPlayer(){
        miniPlayer.config = self.config
        
        miniPlayer.thumbImage.image = thumbImage.image
        miniPlayer.playerBgImage.image = playerBgImage.image
        miniPlayer.progressBar.progress = playerControllers.progressBar.progress
        
        
        miniPlayer.playBtn.addTarget(self, action: #selector(playAction( _ :)), for: .touchUpInside)
        miniPlayer.nextBtn.addTarget(self, action: #selector(nextAction( _ :)), for: .touchUpInside)
        miniPlayer.likeBtn.addTarget(self, action: #selector(likeAction( _ :)), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        miniPlayer.addGestureRecognizer(tap)
        
        miniPlayer.playBtn.isSelected = playerControllers.playbtn.isSelected
        
       
        
        miniPlayer.albumView.startAnimationWith(text: playerControllers.albumView.patternText, font: .systemFont(ofSize: 13))
        miniPlayer.trackView.startAnimationWith(text: playerControllers.trackView.patternText, font: .systemFont(ofSize: 13))
    }
    
    
    
    func getTopConstraint(view: UIView) -> NSLayoutConstraint? {
         for constraint in view.superview?.constraints ?? [] {
             if (constraint.firstItem as? UIView == view && constraint.firstAttribute == .top) ||
                (constraint.secondItem as? UIView == view && constraint.secondAttribute == .top) {
                 return constraint
             }
         }
         return nil
     }
}
