//
//  MainViewController.swift
//  Metronome
//
//  Created by Георгий Ступаков on 3/26/21.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var beatMetranomePicker: UIPickerView!
    @IBOutlet weak var valueMetranomePicker: UIPickerView!
    
    let metranome: Metranome = {
        let mainClickFile = Bundle.main.url(forResource: "Low", withExtension: "wav")!
        let accentedClickFile = Bundle.main.url(forResource: "High", withExtension: "wav")!
        return Metranome(mainClick: mainClickFile, accentClick: accentedClickFile)
    }()
    
    let countBeatArray = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    let valueArray = ["1", "2", "3", "4"]
    var countBeat: UInt32 = 0
    var tempo: Double = 180.0 {
        didSet {
            tempoLabel.text = String(Int(tempo))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tempoLabel.text = "180"
        tempoSlider.value = 180
        tempoSlider.minimumValue = 30
        tempoSlider.maximumValue = 360
        
        beatMetranomePicker.dataSource = self
        beatMetranomePicker.delegate = self
        beatMetranomePicker.setValue(UIColor.white, forKey: "textColor")
        valueMetranomePicker.dataSource = self
        valueMetranomePicker.delegate = self
        valueMetranomePicker.setValue(UIColor.white, forKey: "textColor")
        
        
        stopButton.isHidden = true
    }
    
    
    @IBAction func pressedPlayButton(_ sender: UIButton) {
        metranome.playMetranome(bpm: tempo, countBeat: countBeat)
        playButton.isHidden = true
        stopButton.isHidden = false
    }
    
    @IBAction func pressedStopButton(_ sender: UIButton) {
        playButton.isHidden = false
        stopButton.isHidden = true
        metranome.stopMetranome()
    }
    
    @IBAction func pressedPlusButton(_ sender: UIButton) {
        if tempo < 360 {
            tempo += 1.0
        }
        tempoSlider.value += 1.0
        if metranome.isPlay {
            metranome.playMetranome(bpm: tempo, countBeat: countBeat)
        }
    }
    
    @IBAction func pressedMinusButton(_ sender: UIButton) {
        if tempo > 30 {
            tempo -= 1.0
        }
        tempoSlider.value -= 1.0
        if metranome.isPlay {
            metranome.playMetranome(bpm: tempo, countBeat: countBeat)
        }
    }
    
    @IBAction func changedTempoSlider(_ sender: UISlider) {
        tempo = Double(tempoSlider.value)
        if metranome.isPlay {
            metranome.playMetranome(bpm: tempo, countBeat: countBeat)
        }
    }

}

extension MainViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    //определяем сколько столбцов мы хотим в нашем сборщике
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //определяем сколько строк должно быть у этого средства выбора
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == beatMetranomePicker { return countBeatArray.count }
        if pickerView == valueMetranomePicker { return valueArray.count }
        return 0
    }
    //Этот метод ожидает на выходе строку. Строка - это заголовок данной строки. Когда PickerView загружается, он запрашивает у своего делегата заголовок строки и вызывает вышеуказанный метод один раз для каждой строки. Поэтому, когда он пытается получить заголовок для первой строки, он передает значение строки 0 и значение компонента (столбца) 0.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == beatMetranomePicker { return countBeatArray[row] }
        if pickerView == valueMetranomePicker { return valueArray[row] }
        return ""
    }
    
    //Это будет вызываться каждый раз, когда пользователь прокручивает средство выбора
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == beatMetranomePicker {
            if let selectBeat = UInt32(countBeatArray[row]) {
                countBeat = selectBeat
            }
            if metranome.isPlay {
                metranome.playMetranome(bpm: tempo, countBeat: countBeat)
            }
        }
        
        if pickerView == valueMetranomePicker {
            print(valueArray[row])
        }
    }
    
}
