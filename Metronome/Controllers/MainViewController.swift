//
//  MainViewController.swift
//  Metronome
//
//  Created by Георгий Ступаков on 3/26/21.

// AdMob
// APP ID: ca-app-pub-5666834342456165~7584229016
// 
// BANNER ID: ca-app-pub-5666834342456165/3414077384

import UIKit
import CoreData
import AVFoundation
import GoogleMobileAds
import AppTrackingTransparency

class MainViewController: UIViewController, SettingsViewControllerDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var beatMetronomePicker: UIPickerView!
    @IBOutlet weak var valueMetronomePicker: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedAudioButton: UIButton!
    @IBOutlet weak var tempoField: UITextField!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var tempoLisrArray = [TempoItem]()
    
    var audio: AudioFiles!
    var metronome: Metronome!
    let metronomeManager = MetronomeManager()
    let tempoTap = TapTempo()
    
    var selectedRowSignature: Int16 = 0
    var selectedRowBeat: Int16 = 0
    
    var countBeat: Int32 = 0
    var timeSignature: Int32 = 1
    var tempo: Int32 = 180 {
        didSet {
            tempoField.text = String(tempo)
            tempoSlider.value = Float(tempo)
            ifPlayMertonome()
        }
    }
    
    @Persist(key: "audioName", defaultValue: "Default")
    private var audioName: String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.windows.forEach { $0.initTheme() }
        
        bannerView.adUnitID = "ca-app-pub-5666834342456165/3414077384" //старый
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //тестовый
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["D7599159-EEAA-42EC-B531-486E597A9145"]
        
        tempoField.text = "180"
        tempoField.delegate = self
        tempoField.clearsOnBeginEditing = true
        playButton.setImage(UIImage(named: "play"), for: .normal)
        selectedAudioButton.setTitle(audioName, for: .normal)
        
        beatMetronomePicker.dataSource = self
        beatMetronomePicker.delegate = self
        beatMetronomePicker.setValue(UIColor.white, forKey: "textColor")
        
        valueMetronomePicker.dataSource = self
        valueMetronomePicker.delegate = self
        valueMetronomePicker.setValue(UIColor.white, forKey: "textColor")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        CoreDataManager.shared.loadTempoItems(array: &tempoLisrArray)
        
        audio = AudioFiles(name: audioName)
        let mainClickFile = audio.audioMainClick
        let accentedClickFile = audio.audioAccentClick
        metronome = Metronome(mainClick: mainClickFile, accentClick: accentedClickFile)
        
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.isHidden = true
        
        setupToHideKeyboardOnTapOnView()
        
        metronome.setupAudioInterruptionListener(button: playButton)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    DispatchQueue.main.async {
                        self.loadAdMob()
                    }
                })
            } else {
                self.loadAdMob()
            }
        }
    }
    
    //MARK: - @IBActions
    @IBAction func pressedPlayButton(_ sender: UIButton) {
        
        if self.playButton.currentImage == UIImage(named: "play") {
            self.playButton.setImage(UIImage(named: "stop"), for: .normal)
            self.metronome.playMetronome(bpm: self.tempo, countBeat: self.countBeat, timeSignature: self.timeSignature)
        } else {
            self.playButton.setImage(UIImage(named: "play"), for: .normal)
            self.metronome.stopMetranome()
        }
        
    }
    
    @IBAction func tapButton(_ sender: UIButton) {
        tempo = Int32(tempoTap.tap())
        
        if tempo < 30 {
            tempo = 30
        }
        if tempo > 360 {
            tempo = 360
        }
        
        tempoSlider.value = Float(tempo)
        ifPlayMertonome()
    }
    
    @IBAction func pressedPlusButton(_ sender: UIButton) {
        if tempo < 360 {
            tempo += 1
        }
        tempoSlider.value += 1
    }
    
    @IBAction func pressedMinusButton(_ sender: UIButton) {
        if tempo > 30 {
            tempo -= 1
        }
        tempoSlider.value -= 1
    }
    
    @IBAction func changedTempoSlider(_ sender: UISlider) {
        tempo = Int32(tempoSlider.value)
    }
    
    @IBAction func changedAudio(_ sender: UIButton) {
        guard let popAudioVC = storyboard?.instantiateViewController(identifier: "popAudioVC") as? AudioTableViewController else { return }
        popAudioVC.delegate = self
        popAudioVC.modalPresentationStyle = .popover
        let popOverVC = popAudioVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = self.selectedAudioButton
        popOverVC?.sourceRect = CGRect(x: self.selectedAudioButton.bounds.midX, y: self.selectedAudioButton.bounds.maxY, width: 0, height: 0)
        popAudioVC.preferredContentSize = CGSize(width: 130, height: 220)
        
        self.present(popAudioVC, animated: true, completion: nil)
    }
    
    //MARK: - AlertController
    @IBAction func addTempoInTableView(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Add tempo to the list?", message: nil, preferredStyle: .alert)
        alert.view.tintColor = UIColor(named: "TextColor")
        
        var textField = UITextField()
        
        let alertActionAdd = UIAlertAction(title: "Add", style: .default) { [self] alertAction in
            
            let newTempoItem = TempoItem(context: CoreDataManager.shared.context)
            
            if textField.text != "" {
                newTempoItem.name = textField.text
            } else {
                newTempoItem.name = "Unnamed"
            }
            newTempoItem.tempo = self.tempo
            newTempoItem.beat = self.countBeat
            newTempoItem.value = self.timeSignature
            newTempoItem.rowValue = self.selectedRowSignature
            newTempoItem.rowBeat = self.selectedRowBeat
            
            self.tempoLisrArray.insert(newTempoItem, at: 0)
            CoreDataManager.shared.saveTempoItems()
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
            self.reindex()
            self.tableView.endUpdates()
            let topIndex = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: topIndex, at: .top, animated: true)
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter name"
            alertTextField.autocapitalizationType = .sentences
            textField = alertTextField
        }
        
        alert.addAction(alertActionCancel)
        alert.addAction(alertActionAdd)
        
        present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
        
    }
    
    //MARK: - Functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! SettingsViewController
        destinationVC.delegate = self
    }
    
    func fetchSettingsToMainVC() {
        bannerView.removeFromSuperview()
    }
    
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func ifPlayMertonome() {
        if metronome.isPlay {
            metronome.playMetronome(bpm: tempo, countBeat: countBeat, timeSignature: timeSignature)
        }
    }
    
    func reindex()
    {
        for (index, item) in tempoLisrArray.enumerated() {
            item.index = Int32(index)
        }
        CoreDataManager.shared.saveTempoItems()
    }
    
    func loadAdMob() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        if !UserDefaults.standard.bool(forKey: "ads_removed") {
            self.bannerView.load(GADRequest())
        } else {
            self.bannerView.removeFromSuperview()
        }
    }
}

// MARK: - CUSTOM UIPickerViews, UIPickerViewDataSource and UIPickerViewDelegate
extension MainViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    //определяем сколько столбцов мы хотим в нашем сборщике
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //определяем сколько строк должно быть у этого средства выбора
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == beatMetronomePicker { return metronomeManager.countBeatArray.count }
        if pickerView == valueMetronomePicker { return metronomeManager.valueTimeSignatureArray.count }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if pickerView == beatMetronomePicker {
            let customBeatPickerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            let pickerBeatLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
            pickerBeatLabel.textColor = UIColor(named: "TextColor")
            pickerBeatLabel.font = UIFont.systemFont(ofSize: 35, weight: .light)
            pickerBeatLabel.textAlignment = .center
            pickerBeatLabel.text = metronomeManager.countBeatArray[row]
            customBeatPickerView.addSubview(pickerBeatLabel)
            
            return customBeatPickerView
        }
        
        let customValuePickerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let pickerImageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
        pickerImageView.contentMode = .scaleAspectFill
        pickerImageView.image = UIImage(named: metronomeManager.imageTimeSignatureArray[row])
        customValuePickerView.addSubview(pickerImageView)
        
        return customValuePickerView
    }
    
    //Это будет вызываться каждый раз, когда пользователь прокручивает средство выбора
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == beatMetronomePicker {
            if let selectBeat = Int32(metronomeManager.countBeatArray[row]) {
                countBeat = selectBeat
            }
            
            selectedRowBeat = Int16(row)
            ifPlayMertonome()
        }
    
        if pickerView == valueMetronomePicker {
            timeSignature = metronomeManager.valueTimeSignatureArray[row]
            
            selectedRowSignature = Int16(row)
            ifPlayMertonome()
        }
    }
    
}

//MARK: - UITableViewDelegate and UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempoLisrArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! TempoCell
        
        cell.nameLabel.text = "\(tempoLisrArray[indexPath.row].name!)"
        cell.tempoLabel.text = "\(tempoLisrArray[indexPath.row].tempo)"
        cell.beatLabel.text = "\(tempoLisrArray[indexPath.row].beat)"
        cell.valueImage.image = UIImage(named: metronomeManager.imageTimeSignatureArray[Int(tempoLisrArray[indexPath.row].rowValue)])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bpmList = tempoLisrArray[indexPath.row].tempo
        let beatList = tempoLisrArray[indexPath.row].beat
        let valueList = tempoLisrArray[indexPath.row].value
        let rowValue = Int(tempoLisrArray[indexPath.row].rowValue)
        let rowBeat = Int(tempoLisrArray[indexPath.row].rowBeat)
        
        playButton.setImage(UIImage(named: "stop"), for: .normal)
        tempoSlider.value = Float(bpmList)
        
        tempo = bpmList
        timeSignature = valueList
        selectedRowSignature = Int16(rowValue)
        countBeat = beatList
        selectedRowBeat = Int16(beatList)
        
        metronome.playMetronome(bpm: bpmList, countBeat: beatList, timeSignature: valueList)
        
        beatMetronomePicker.selectRow(rowBeat, inComponent: 0, animated: true)
        valueMetronomePicker.selectRow(rowValue, inComponent: 0, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            let editAlertDelete = UIAlertController(title: "Delete?", message: nil, preferredStyle: .alert)
            editAlertDelete.view.tintColor = UIColor(named: "TextColor")
            
            editAlertDelete.addAction(UIAlertAction(title: "Yes!", style: .default, handler: { alertAction in
                
                CoreDataManager.shared.context.delete(self.tempoLisrArray[indexPath.row])
                do {
                    try CoreDataManager.shared.context.save()
                    self.tempoLisrArray.remove(at: indexPath.row)
                    self.reindex()
                    tableView.reloadData()
                } catch {
                    print(error.localizedDescription)
                }
                
            }))
            
            editAlertDelete.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(editAlertDelete, animated: true) {
                editAlertDelete.view.superview?.isUserInteractionEnabled = true
                editAlertDelete.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            }
        
            completionHandler(true)
        }
        
        delete.backgroundColor = UIColor(named: "DeleteColor")
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            
            var textFieldName = UITextField()
            var textFieldTempo = UITextField()
            
            let editAlert = UIAlertController(title: "Edit name and tempo?", message: nil, preferredStyle: .alert)
            editAlert.view.tintColor = UIColor(named: "TextColor")
            
            editAlert.addTextField { textField in
                textField.placeholder = "Enter name"
                textField.text = self.tempoLisrArray[indexPath.row].name
                textField.autocapitalizationType = .sentences
                textField.borderStyle = UITextField.BorderStyle.roundedRect
                textFieldName = textField
            }
            
            editAlert.addTextField { textField in
                textField.placeholder = "Enter tempo"
                textField.text = String(self.tempoLisrArray[indexPath.row].tempo)
                textField.autocapitalizationType = .sentences
                textField.borderStyle = UITextField.BorderStyle.roundedRect
                textField.keyboardType = .numberPad
                textField.delegate = self
                textFieldTempo = textField
            }
            
            editAlert.addAction(UIAlertAction(title: "Update", style: .default, handler: { alertAction in
                
                if textFieldName.text == "" {
                    self.tempoLisrArray[indexPath.row].name = ""
                } else {
                    self.tempoLisrArray[indexPath.row].name = textFieldName.text
                    self.tempoLisrArray[indexPath.row].setValue(textFieldName.text, forKey: "name")
                }
                
                if textFieldTempo.text == "" {
                    self.tempoLisrArray[indexPath.row].tempo = 30
                } else {
                    let value = Int32(textFieldTempo.text ?? "30")
                    self.tempoLisrArray[indexPath.row].tempo = value ?? 30
                    self.tempoLisrArray[indexPath.row].setValue(value, forKey: "tempo")
                }

                CoreDataManager.shared.saveTempoItems()
                
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }))
            
            editAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(editAlert, animated: true) {
                editAlert.view.superview?.isUserInteractionEnabled = true
                editAlert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            }
            
            for textField in editAlert.textFields! {
                let container = textField.superview
                let effectView = container?.superview?.subviews[0]
                if (effectView != nil) {
                    container?.backgroundColor = UIColor.clear
                    effectView?.removeFromSuperview()
                }
            }
            
            completionHandler(true)
        }
        
        edit.backgroundColor = UIColor(named: "EditColor")
        
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit])
        return swipe
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let mover = tempoLisrArray.remove(at: sourceIndexPath.row)
        tempoLisrArray.insert(mover, at: destinationIndexPath.row)
        self.reindex()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

// MARK: - AudioListDelegate
extension MainViewController: UIPopoverPresentationControllerDelegate, AudioListDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func fetchAudioToMainVC(newAudioName: String) {
        selectedAudioButton.setTitle(newAudioName, for: .normal)
        
        metronome.stopMetranome()
        
        audio = AudioFiles(name: newAudioName)
        audioName = newAudioName
        
        metronome = Metronome(mainClick: audio.audioMainClick, accentClick: audio.audioAccentClick)

            if playButton.currentImage == UIImage(named: "stop") {
                metronome.playMetronome(bpm: tempo, countBeat: countBeat, timeSignature: timeSignature)
            }
    }
    
}

// MARK: - UITextFieldDelegate
extension MainViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField == tempoField {
            if tempoField.text == "" {
                tempoField.text = String(tempo)
            } else {
                let textfieldValue = Int(textField.text ?? "180")
                tempo = Int32(textfieldValue!)
            }
            
            if tempo > 360 {
                tempoField.text = String("360")
                tempo = 360
            }

            if tempo < 30 {
                textField.text = String("30")
                tempo = 30
            }
        } else {
            let textfieldValue = Int(textField.text ?? "180")
            if textfieldValue! > 360 {
                textField.text = "360"
            }
            if textfieldValue! < 30 {
                textField.text = "30"
            }
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let numberLimit = 3
        
        let startingLength = textField.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace = range.length
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        return (newLength <= numberLimit) && (string == numberFiltered)
    }
    
    func setupToHideKeyboardOnTapOnView()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(MainViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

//MARK: - GADBannerViewDelegate
extension MainViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
        
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
        
        print("Received ads")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        bannerView.isHidden = true
        print("Error ads: \(error)")
    }
}
