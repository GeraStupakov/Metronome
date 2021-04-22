//
//  AudioFiles.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/22/21.
//

import Foundation

struct AudioFiles {
    
    let name: String
    
    var audioMainClick: URL {
        switch name {
        case "Classic":
            return Bundle.main.url(forResource: "Classic_main", withExtension: "wav")!
        case "Ableton":
            return Bundle.main.url(forResource: "Ableton_main", withExtension: "wav")!
        case "Cubase":
            return Bundle.main.url(forResource: "Cubase_main", withExtension: "wav")!
        case "Logic":
            return Bundle.main.url(forResource: "Logic_main", withExtension: "wav")!
        case "Sonar":
            return Bundle.main.url(forResource: "Sonar_main", withExtension: "wav")!
        default:
            return Bundle.main.url(forResource: "Classic_main", withExtension: "wav")!
        }
    }
    
    var audioAccentClick: URL {
        switch name {
        case "Classic":
            return Bundle.main.url(forResource: "Classic_accent", withExtension: "wav")!
        case "Ableton":
            return Bundle.main.url(forResource: "Ableton_accent", withExtension: "wav")!
        case "Cubase":
            return Bundle.main.url(forResource: "Cubase_accent", withExtension: "wav")!
        case "Logic":
            return Bundle.main.url(forResource: "Logic_accent", withExtension: "wav")!
        case "Sonar":
            return Bundle.main.url(forResource: "Sonar_accent", withExtension: "wav")!
        default:
            return Bundle.main.url(forResource: "Classic_accent", withExtension: "wav")!
        }
    }
    
}
