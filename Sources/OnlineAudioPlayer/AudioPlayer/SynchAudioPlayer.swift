//
//  SynchAudioPlayer.swift
//  tesrt
//
//  Created by Saurabh Srivastav on 14/01/24.
//

import UIKit

class SynchAudioPlayer: NSObject {
    static let shared = SynchAudioPlayer()
    var audioPlayer: AudioPlayer!
    private override init(){}
   
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
    
    func configAudioPlayer(playerConfig:AudioPlayerConfiguration,tracks:[AudioTrackDataModel]?){
        if audioPlayer != nil {
            audioPlayer.player.pause()
            audioPlayer.player = nil
            audioPlayer.removeFromSuperview()
        }
        let rootView =  Scene.getSceneDelegate().window?.rootViewController?.view
        audioPlayer = AudioPlayer()
        audioPlayer.frame = rootView!.bounds
        audioPlayer.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        rootView?.addSubview(audioPlayer)
       
       

        audioPlayer.config = playerConfig

        if tracks != nil {
            audioPlayer.isHidden = false
            audioPlayer.tracks = tracks
        }
        else{
            audioPlayer.isHidden = true
        }
       
        audioPlayer.didPressLike = { [self] track,isliked in
            didPressLike?(track,isliked)
            
        }
      
        audioPlayer.didStartPlaying = { [self] track in
            
            didStartPlaying?(track)
        }

        audioPlayer.didStopPlaying = { [self] track in
           
            didStopPlaying?(track)
        }
        audioPlayer.didPressNext = { [self] track,index in
            
            didPressNext?(track,index)
        }
        audioPlayer.didPressPrevious = { [self] track,index in
           
            didPressPrevious?(track,index)
        }
        audioPlayer.didEnterInFullScreen = { [self] in
           
            didEnterInFullScreen?()
        }
        audioPlayer.didExitFullScreen = { [self] in
           
            didExitFullScreen?()
        }
        audioPlayer.currentPlayingDuration = { [self] total,current in
            currentPlayingDuration?(total,current)
           
            
        }
        audioPlayer.didPressShuffle = { [self] isShuffleOn in
            didPressShuffle?(isShuffleOn)
        }
        audioPlayer.didPressRepeat = { [self] isRepeat in
            didPressRepeat?(isRepeat)
        }
       
    }
    
    func replaceCurrentTracks(newTracks:[AudioTrackDataModel]){
        if audioPlayer != nil {
            audioPlayer.tracks = newTracks
        }
    }
    
    func queueTrack(tracks:[AudioTrackDataModel]){
        if audioPlayer != nil {
            
            audioPlayer.addTrackToCurrentList(tracks: tracks)
        }
        
    }
    func play(){
        if audioPlayer != nil {
            audioPlayer.playPausePlayer()
        
        }
    }
    func pause(){
        if audioPlayer != nil {
            //audioPlayer.pauseVideo()
            audioPlayer.playPausePlayer()
        }
    }
   
    func removePlayer(){
        if audioPlayer != nil {
            audioPlayer.player.pause()
            audioPlayer.player = nil
            audioPlayer.removeFromSuperview()
        }
    }
    
    func startBuffringPlayer(){
        if audioPlayer != nil {
            audioPlayer.startBuffring()
        }
    }
    func resumePlayer(){
        if audioPlayer != nil {
            audioPlayer.resume()
        }
    }
    
}

