////
////  MetronomeMediaPlayer.swift
////  Metronome
////
////  Created by Георгий Ступаков on 5/26/21.
////
//
//import Foundation
//import MediaPlayer
//
//class MetronomeMediaPlayer: MainViewController {
//    
//    func setupNotificationView(tempo: Int32) {
//
//        var nowPlayingInfo = [String : Any]()
//        nowPlayingInfo[MPMediaItemPropertyTitle] = "BPM: \(tempo)"
//        nowPlayingInfo[MPMediaItemPropertyArtist] = "Metronome"
//       
//        if let image = UIImage(named: "sqrLogo") {
//            nowPlayingInfo[MPMediaItemPropertyArtwork] =
//                MPMediaItemArtwork(boundsSize: image.size) { size in
//                    return image
//            }
//        }
//        
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//    }
//    
//    func setupMediaPlayerNotifacationView() {
//        let commandCenter = MPRemoteCommandCenter.shared()
//        
//        commandCenter.playCommand.addTarget { [unowned self] event in
//            print("play")
////
////                    self.playButton.setImage(UIImage(named: "stop"), for: .normal)
////                    self.metronome.playMetronome(bpm: self.tempo, countBeat: self.countBeat, timeSignature: self.timeSignature)
//            
//            self.metronome.audioPlayerNode.play()
//            self.playButton.setImage(UIImage(named: "stop"), for: .normal)
//            return .success
//        }
//        
//        commandCenter.pauseCommand.addTarget { [unowned self] event in
//            print("pause")
//            self.metronome.audioPlayerNode.pause()
//            self.playButton.setImage(UIImage(named: "play"), for: .normal)
//            return .success
//        }
//        
//        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
//            print("-1")
//            if tempo > 30 {
//                tempo -= 1
//            }
//            tempoSlider.value -= 1
//            ifPlayMertonome()
//            return .success
//        }
//        
//        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
//            print("+1")
//            if tempo < 360 {
//                tempo += 1
//            }
//            tempoSlider.value += 1
//            ifPlayMertonome()
//            return .success
//        }
//        
//        
//    }
//    
//}
