//
//  Metranome.swift
//  Metronome
//
//  Created by Георгий Ступаков on 3/13/21.
//

import Foundation
import AVFoundation
import UIKit

class Metronome {
    
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var mainClickAudioFile: AVAudioFile!
    var accentClickAudioFile: AVAudioFile!
    
    private var isSuspended = false
    var changeButton: UIButton!
    
    init(mainClick: URL, accentClick: URL) {
        mainClickAudioFile = try! AVAudioFile(forReading: mainClick)
        accentClickAudioFile = try! AVAudioFile(forReading: accentClick)
        
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: mainClickAudioFile.processingFormat)
        
        do {
            try audioEngine.start()
        } catch {
            print("Error audioEngine start with \(error)")
        }
    }
    
    func generateBuffer(with bpm: Double, with countBeat: UInt32, with timeSignature: UInt32) -> AVAudioPCMBuffer {
        //буффер - область памяти, используемая для временного хранения данных ввода-вывода
        //цифровой сигнал, полученный методом импульсно-кодовой модуляции (PCM)
        //Два основных параметра качества PCM сигнала — это частота и разрядность. Частота — это количество измерений за одну секунду, чем их больше — тем с большей точностью передаётся сигнал. Частота измеряется в герцах: 44100 Hz
        mainClickAudioFile.framePosition = 0 //устанавливаем нулевую позицию в аудиофайле, в которой произойдет следующая операция чтения или записи
        accentClickAudioFile.framePosition = 0
        
        let lengthOfClick = AVAudioFrameCount(mainClickAudioFile.processingFormat.sampleRate * 60 / bpm)
        //длина клика
        //AVAudioFrameCount - количество аудио семплов во фрейме
        
        let bufferOfMainClick = AVAudioPCMBuffer(pcmFormat: mainClickAudioFile.processingFormat, frameCapacity: lengthOfClick)!
        //инициилизируем буфер PCM для MainClick
        //pcmFormat - Формат аудио PCM, который должен содержаться в буфере.
        //frameCapacity - Емкость буфера во фрейме PCM семплов.(AVAudioFrameCount)
        do {
            try mainClickAudioFile.read(into: bufferOfMainClick)
        } catch {
            print("Error read buffer\(error)")
        }
        //Пытаемся прочитать весь буфер, из которого следует читать файл. Его формат должен соответствовать формату обработки файла.
        //При последовательном чтении из свойства framePosition пытается заполнить буфер до его емкости. По возвращении свойство длины буфера указывает количество успешно прочитанных кадров выборки.
        
        bufferOfMainClick.frameLength = lengthOfClick / timeSignature //устанавливаем количество семплов в буфере MainClick
        //frameLength - The current number of valid sample frames in the buffer.
        //Текущее количество допустимых семплов фрейма в буфере.
        
        //По умолчанию свойство frameLength не инициализируется полезным значением; вы должны установить это свойство перед использованием буфера. Длина должна быть меньше или равна frameCapacity буфера. В случае форматов с обратным чередованием frameCapacity относится к размеру аудиосэмплов одного канала.
        
        //тоже самое для AccentClick
        let bufferOfAccentClick = AVAudioPCMBuffer(pcmFormat: accentClickAudioFile.processingFormat, frameCapacity: lengthOfClick)!
        do {
            try accentClickAudioFile.read(into: bufferOfAccentClick)
        } catch {
            print("Error read buffer\(error)")
        }
        bufferOfAccentClick.frameLength = lengthOfClick / timeSignature
        
        if countBeat != 0 {
            //Создаем и инициилизируем bufferBar для того чтобы добавить акценты
            let bufferBar = AVAudioPCMBuffer(pcmFormat: mainClickAudioFile.processingFormat, frameCapacity: countBeat * lengthOfClick)!
            
            bufferBar.frameLength = countBeat * lengthOfClick
            //устанавливаем количество семплов в bufferBar
            
            let channelCount = Int(mainClickAudioFile.processingFormat.channelCount)
            //Создаем перемнную для количества каналов аудиоданных.
            
            let accentedClickArray = Array(
                UnsafeBufferPointer(start: bufferOfAccentClick.floatChannelData![0],
                                    count: channelCount * Int(lengthOfClick / timeSignature)))
            
            //Коллекция элементов буфера, непрерывно хранящихся в памяти.
            //Создаем новый указатель буфера на указанное количество непрерывных экземпляров, начиная с первого аудиосемпла буфера, колличестом lengthOfClick
            
            let mainClickArray = Array(UnsafeBufferPointer(start: bufferOfMainClick.floatChannelData![0], count: channelCount * Int(lengthOfClick / timeSignature)))
            
            var barArray = [Float]() //создаем массив для bufferBar
            
            barArray.append(contentsOf: accentedClickArray)
            
            for _ in 1...36 {
                barArray.append(contentsOf: mainClickArray)
            }
            
            bufferBar.floatChannelData!.pointee.assign(from: barArray, count: channelCount * Int(bufferBar.frameLength))
            //заменяем инициализированную память bufferBar на укзанное количество экземпляров из barArray.
            //Свойство floatChannelData возвращает указатели на аудиосемплы буфера, если формат буфера - 32-битное с плавающей точкой.
            //Число экземпляров для копирования из памяти, на которую ссылается источник, в память этого указателя.
            
            return bufferBar
        } else {
            return bufferOfMainClick
        }
    }
    
    var isPlay: Bool {
        return audioPlayerNode.isPlaying
    }
    
    func playMetronome(bpm: Int32, countBeat: Int32, timeSignature: Int32) {
        
        let metranomeBuffer = generateBuffer(with: Double(bpm), with: UInt32(countBeat), with: UInt32(timeSignature)) //создаем буфер из наших аудиофайлов
        
        if audioPlayerNode.isPlaying {
            audioPlayerNode.scheduleBuffer(metranomeBuffer, at: nil, options: .interruptsAtLoop, completionHandler: nil)
        } else {
            audioPlayerNode.play()
        }
        
        audioPlayerNode.scheduleBuffer(metranomeBuffer, at: nil, options: .loops)
        // Планирует воспроизведение сэмплов из аудиобуфера в указанное время и с указанными параметрами воспроизведения.
    }
    
    func stopMetranome() {
        audioPlayerNode.stop()
    }
    
    func setupAudioInterruptionListener(button: UIButton) {
        
        changeButton = button
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEngineConfigurationChange(notification:)),
            name: NSNotification.Name.AVAudioEngineConfigurationChange,
            object: audioEngine
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInterruption(notification:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }
    
    @objc func handleEngineConfigurationChange(notification: Notification) {
        if !isSuspended {
            do {
                try self.audioEngine.start()
            } catch {
                print("Error restarting audio: \(error)")
            }
        }
    }
    
    @objc func handleAudioInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            isSuspended = true
            changeButton.setImage(UIImage(named: "play"), for: .normal)
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            
            isSuspended = false
            
            if options.contains(.shouldResume) {
                do {
                    try self.audioEngine.start()
                    changeButton.setImage(UIImage(named: "stop"), for: .normal)
                } catch {
                    print("Error restarting audio: \(error)")
                }
            } else {
                // An interruption ended. Don't resume playback.
                print("Resume but did not restart engine")
            }
            
        default:
            break
        }
    }
        
}





