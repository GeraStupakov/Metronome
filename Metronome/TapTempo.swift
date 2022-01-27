//
//  TapTempo.swift
//  Metronome
//
//  Created by Георгий Ступаков on 1/4/22.
//

import UIKit
import AudioToolbox

class TapTempo {
        
    private let maximumSamples: Int
    private let resetIntervalSeconds: Int
    private let roundTo: Int?
    
    private var samples = [TimeInterval]()
    private var lastTap: Date?
    private var resetTimer: Timer?
    
    public init(maximumSamples: Int = 7, resetIntervalSeconds: Int = 2, roundTo: Int? = nil){
        self.maximumSamples = maximumSamples
        self.resetIntervalSeconds = resetIntervalSeconds
        self.roundTo = roundTo
    }
    
    public var tempo: Int {
        
        guard !samples.isEmpty else {
            return 0
        }
        
        let averageTimeInterval = samples.reduce(0, +) / Double(samples.count)
        var bpm = Int(60.0 / averageTimeInterval)
        
        if let roundTo = roundTo {
            let rounded = round(Double(bpm) / Double(roundTo))
            bpm = Int(rounded) * roundTo
        }
        
        return Int(bpm)
    }
    
    public func tap() -> Int {
        
        AudioServicesPlaySystemSound(1519)
        
        let currentDate = Date()
        
        if let last = lastTap {
            
            samples.append(currentDate.timeIntervalSince(last))
            
            if(samples.count > maximumSamples){
                samples.removeFirst()
            }
        }
        
        lastTap = currentDate
        
        resetTimer?.invalidate()
        resetTimer = Timer.scheduledTimer(withTimeInterval: Double(resetIntervalSeconds), repeats: false, block: { [weak self] _ in
            self?.samples = []
            self?.lastTap = nil
        })
        
        return tempo
    }
    
}
