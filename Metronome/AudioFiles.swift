//
//  AudioFiles.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/22/21.
//

import Foundation

class AudioFiles {
    
    var mainClickFile: URL = Bundle.main.url(forResource: "Low", withExtension: "wav")!
    var accentedClickFile: URL = Bundle.main.url(forResource: "High", withExtension: "wav")!
        
    func audio(nameAudio: String) {
        
        switch nameAudio {
        case "Audio 1":
            mainClickFile = Bundle.main.url(forResource: "Low", withExtension: "wav")!
            accentedClickFile = Bundle.main.url(forResource: "High", withExtension: "wav")!
        case "Audio 2":
            mainClickFile = Bundle.main.url(forResource: "Low2", withExtension: "wav")!
            accentedClickFile = Bundle.main.url(forResource: "High2", withExtension: "wav")!
        default: break
        }
    }
}
