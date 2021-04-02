//
//  Metranome.swift
//  Metronome
//
//  Created by Георгий Ступаков on 3/13/21.
//

import Foundation
import AVFoundation

class Metranome {
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var mainClickAudioFile: AVAudioFile!
    var accentClickAudioFile: AVAudioFile!
    
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
    
    func generateBuffer(with bpm: Double, with countBeat: UInt32) -> AVAudioPCMBuffer {
        //буффер - область памяти, используемая для временного хранения данных ввода-вывода
        //цифровой сигнал, полученный методом импульсно-кодовой модуляции (PCM)
        //Два основных параметра качества PCM сигнала — это частота и разрядность. Частота — это количество измерений за одну секунду, чем их больше — тем с большей точностью передаётся сигнал. Частота измеряется в герцах: 44100 Hz
        mainClickAudioFile.framePosition = 0 // устанавливаем нулевую позицию в аудиофайле, в которой произойдет следующая операция чтения или записи
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
        
        bufferOfMainClick.frameLength = lengthOfClick //устанавливаем количество семплов в буфере MainClick
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
        bufferOfAccentClick.frameLength = lengthOfClick
        
        if countBeat != 0 {
            //Создаем bufferBar для того чтобы добавить акценты
            let bufferBar = AVAudioPCMBuffer(pcmFormat: mainClickAudioFile.processingFormat, frameCapacity: countBeat * lengthOfClick)!
            //Инициилизируем bufferBar
            
            bufferBar.frameLength = countBeat * lengthOfClick
            //устанавливаем количество семплов в bufferBar
            
            let channelCount = Int(mainClickAudioFile.processingFormat.channelCount)
            //Создаем перемнную для количества каналов аудиоданных.
            
            let accentedClickArray = Array(
                UnsafeBufferPointer(start: bufferOfAccentClick.floatChannelData![0],
                                    count: channelCount * Int(lengthOfClick)))
            //Коллекция элементов буфера, непрерывно хранящихся в памяти.
            //Создаем новый указатель буфера на указанное количество непрерывных экземпляров, начиная с первого аудиосемпла буфера, колличестом lengthOfClick
            
            let mainClickArray = Array(UnsafeBufferPointer(start: bufferOfMainClick.floatChannelData![0], count: channelCount * Int(lengthOfClick)))
            
            var barArray = [Float]() //создаем массив для bufferBar
            
            barArray.append(contentsOf: accentedClickArray)
            
            for _ in 1...8 {
                barArray.append(contentsOf: mainClickArray)
            }
            
            bufferBar.floatChannelData!.pointee.assign(from: barArray, count: channelCount * Int(bufferBar.frameLength))
            //заменяем инициализированную память bufferBar на укзанноеколичество экземпляров из barArray.
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
    
    func playMetranome(bpm: Double, countBeat: UInt32){
        
        let metranomeBuffer = generateBuffer(with: bpm, with: countBeat) //создаем буфер из наших аудиофайлов
        
        if audioPlayerNode.isPlaying {
            audioPlayerNode.scheduleBuffer(metranomeBuffer, at: nil, options: .interruptsAtLoop, completionHandler: nil)
        } else {
            audioPlayerNode.play()
        }
        
        audioPlayerNode.scheduleBuffer(metranomeBuffer, at: nil, options: .loops, completionHandler: nil)
        //Планирует воспроизведение сэмплов из аудиобуфера в указанное время и с указанными параметрами воспроизведения.
    }
    
    func stopMetranome() {
        audioPlayerNode.stop()
    }
    
}





