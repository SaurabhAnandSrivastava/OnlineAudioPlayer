//
//  BackgroundPlayer.swift
//  tesrt
//
//  Created by Saurabh Srivastav on 12/03/23.
//

import UIKit
import AVKit
import Photos
import MediaPlayer


class BackgroundPlayer: NSObject {
    
    public var didCallNext:(()->())?
    public var didCallPreview:(()->())?
    public var didCallPlay:(()->())?
    public var didCallPause:(()->())?
    public var currentPlayer : AVQueuePlayer!
    
    public func configBgPlayer(){
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.seekForwardCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self](remoteEvent) -> MPRemoteCommandHandlerStatus in
            guard let self = self else {return .commandFailed}
            if let player = self.currentPlayer {
                let playerRate = player.rate
                if let event = remoteEvent as? MPChangePlaybackPositionCommandEvent {
                    player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(1000)), completionHandler: { [weak self](success) in
                        guard self != nil else {return}
                        if success {
                            self!.currentPlayer!.rate = playerRate
                        }
                    })
                    return .success
                }
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            didCallNext?()
            
            return .success
            
        }
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            didCallPreview?()
            
            return .success
            
        }
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if currentPlayer != nil {
                if !((currentPlayer!.rate != 0) && (currentPlayer?.error == nil)) {
                    currentPlayer!.play()
                    
                    didCallPlay?()
                    return .success
                }
                return .commandFailed
                
                
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if currentPlayer != nil {
                if (( currentPlayer!.rate != 0) && ( currentPlayer!.error == nil)) {
                    currentPlayer!.pause()
                    
                    didCallPause?()
                    return .success
                }
                
                return .commandFailed
            }
            return .commandFailed
        }
    }
    public func updateBgPlayer(trackName:String,albumName:String,albumPicUrl:String?,isRadio:Bool){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            //call any function
            var nowPlayingInfo = [String : Any]()
            
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentPlayer!.currentTime
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
            Task {
                
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = await getDuration()
                
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = currentPlayer!.currentItem?.duration.seconds
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentPlayer!.currentTime() //
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = currentPlayer!.rate
                nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = currentPlayer!.rate
                nowPlayingInfo[MPMediaItemPropertyTitle] = trackName
                nowPlayingInfo[MPMediaItemPropertyArtist] = albumName
                
                
                let imgView = UIImageView()
                imgView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
                
                if isRadio {
                    imgView.image = UIImage(named: "defaultRadio.png")
                }
                else{
                    imgView.image = UIImage(named: "defaultTrack.png")
                }
                
                
                
                
                
                if albumPicUrl != nil {
                    
                    imgView.getImageFromUrl(imgUrl: albumPicUrl!, shouldBeforeNil: false, completionHandler: { img,url in
                        
                        let artwork = MPMediaItemArtwork.init(boundsSize: img!.size, requestHandler: { _ -> UIImage in
                            return img!
                        })
                        
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    })
                }
                else {
                   
                    
                  var img =  UIImage()
                    
                    if isRadio {
                        img = UIImage(named: "defaultRadio.png")!
                    }
                    else{
                        img = UIImage(named: "defaultTrack.png")!
                    }
                    
                    let artwork = MPMediaItemArtwork.init(boundsSize: img.size, requestHandler: { _ -> UIImage in
                        return img
                    })
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
                
                
                
                // Set the metadata
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
            
        }
        
        
        
    }
    private func getDuration()async ->Double {
        
        
        
        
        var totaltime = Double()
        do {
            let duration = try await (currentPlayer?.currentItem?.asset.load(.duration))
            print(duration?.seconds as Any)
            if duration != nil{
                if (!duration!.seconds.isNaN){
                    totaltime = duration!.seconds
                    return totaltime
                }
                
            }
            
        } catch {
            //handle error
            print(error)
            return 0
        }
        return 0
    }
    
}
