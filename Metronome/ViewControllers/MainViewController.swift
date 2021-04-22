//
//  MainViewController.swift
//  Metronome
//
//  Created by Георгий Ступаков on 3/26/21.
//

import UIKit
import CoreData

class MainViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var beatMetronomePicker: UIPickerView!
    @IBOutlet weak var valueMetronomePicker: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedAudioButton: UIButton!
    
    var tempoLisrArray = [TempoItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let metronome: Metronome = {
        let mainClickFile = Bundle.main.url(forResource: "Low", withExtension: "wav")!
        let accentedClickFile = Bundle.main.url(forResource: "High", withExtension: "wav")!
        return Metronome(mainClick: mainClickFile, accentClick: accentedClickFile)
    }()
    
    let countBeatArray = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    let valueTimeSignatureArray: [Int32] = [1, 2, 3, 4]
    let imageTimeSignatureArray = ["4", "8", "3", "16"]
    
    var selectedRowSignature: Int16 = 0
    var selectedRowBeat: Int16 = 0
    
    var countBeat: Int32 = 0
    var timeSignature: Int32 = 1
    var tempo: Int32 = 180 {
        didSet {
            tempoLabel.text = String(tempo)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedAudioButton.setTitle("Audio 1", for: .normal)
        
        tempoLabel.text = "180"
        playButton.setImage(UIImage(named: "play"), for: .normal)
    
        beatMetronomePicker.dataSource = self
        beatMetronomePicker.delegate = self
        beatMetronomePicker.setValue(UIColor.white, forKey: "textColor")
        
        valueMetronomePicker.dataSource = self
        valueMetronomePicker.delegate = self
        valueMetronomePicker.setValue(UIColor.white, forKey: "textColor")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TempoCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        tableView.reloadData()
        loadTempoItems()

    }
    
    
// MARK: - @IBActions
    @IBAction func pressedPlayButton(_ sender: UIButton) {
        
        if playButton.currentImage == UIImage(named: "play") {
            playButton.setImage(UIImage(named: "stop"), for: .normal)
            metronome.playMetronome(bpm: tempo, countBeat: countBeat, timeSignature: timeSignature)
        } else {
            playButton.setImage(UIImage(named: "play"), for: .normal)
            metronome.stopMetranome()
        }
        
    }
    
    @IBAction func pressedPlusButton(_ sender: UIButton) {
        if tempo < 360 {
            tempo += 1
        }
        tempoSlider.value += 1
        ifPlayMertonome()
    }
    
    @IBAction func pressedMinusButton(_ sender: UIButton) {
        if tempo > 30 {
            tempo -= 1
        }
        tempoSlider.value -= 1
        ifPlayMertonome()
    }
    
    @IBAction func changedTempoSlider(_ sender: UISlider) {
        tempo = Int32(tempoSlider.value)
        ifPlayMertonome()
    }
    
    @IBAction func changedAudio(_ sender: UIButton) {
        guard let popAudioVC = storyboard?.instantiateViewController(identifier: "popAudioVC") as? AudioTableViewController else { return }
        popAudioVC.delegate = self
        popAudioVC.modalPresentationStyle = .popover
        let popOverVC = popAudioVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = self.selectedAudioButton
        popOverVC?.sourceRect = CGRect(x: self.selectedAudioButton.bounds.midX, y: self.selectedAudioButton.bounds.maxY, width: 0, height: 0)
        popAudioVC.preferredContentSize = CGSize(width: 130, height: 130)
        
        self.present(popAudioVC, animated: true, completion: nil)
    }
    

//MARK: - AlertController
    @IBAction func addTempoInTableView(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Add tempo to the list?", message: "", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor(named: "TextColor")
        
        var textField = UITextField()
        
        let alertActionAdd = UIAlertAction(title: "Add", style: .default) { alertAction in
            
            let newTempoItem = TempoItem(context: self.context)
            
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
            self.saveTempoItems()
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
            self.tableView.endUpdates()
            
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter name"
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
    
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func ifPlayMertonome() {
        if metronome.isPlay {
            metronome.playMetronome(bpm: tempo, countBeat: countBeat, timeSignature: timeSignature)
        }
    }
    
    func saveTempoItems() {
        do {
            try context.save()
        } catch {
            print("Error save context: \(error)")
        }
    }
    
    func loadTempoItems() {
        let request: NSFetchRequest<TempoItem> = TempoItem.fetchRequest()
        
        do {
            tempoLisrArray = try context.fetch(request)
        } catch {
            print("Error load context: \(error)")
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
        if pickerView == beatMetronomePicker { return countBeatArray.count }
        if pickerView == valueMetronomePicker { return valueTimeSignatureArray.count }
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
            pickerBeatLabel.text = countBeatArray[row]
            customBeatPickerView.addSubview(pickerBeatLabel)
    
            return customBeatPickerView
        }
        
        let customValuePickerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let pickerImageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
        pickerImageView.contentMode = .scaleAspectFill
        pickerImageView.image = UIImage(named: imageTimeSignatureArray[row])
        customValuePickerView.addSubview(pickerImageView)

        return customValuePickerView
    }
    
    //Это будет вызываться каждый раз, когда пользователь прокручивает средство выбора
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == beatMetronomePicker {
            if let selectBeat = Int32(countBeatArray[row]) {
                countBeat = selectBeat
            }
            selectedRowBeat = Int16(row)
            ifPlayMertonome()
        }
        
        if pickerView == valueMetronomePicker {
            timeSignature = valueTimeSignatureArray[row]
            ifPlayMertonome()
            selectedRowSignature = Int16(row)
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
        cell.valueImage.image = UIImage(named: imageTimeSignatureArray[Int(tempoLisrArray[indexPath.row].rowValue)])
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bpmList = tempoLisrArray[indexPath.row].tempo
        let beatList = tempoLisrArray[indexPath.row].beat
        let valueList = tempoLisrArray[indexPath.row].value
        let rowValue = Int(tempoLisrArray[indexPath.row].rowValue)
        let rowBeat = Int(tempoLisrArray[indexPath.row].rowBeat)
        metronome.playMetronome(bpm: bpmList, countBeat: beatList, timeSignature: valueList)
        
        playButton.setImage(UIImage(named: "stop"), for: .normal)
        tempoSlider.value = Float(bpmList)
        timeSignature = valueList
        countBeat = beatList
        tempo = bpmList
        beatMetronomePicker.selectRow(rowBeat, inComponent: 0, animated: true)
        valueMetronomePicker.selectRow(rowValue, inComponent: 0, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
  
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            self.context.delete(self.tempoLisrArray[indexPath.row])
            do {
                try self.context.save()
                self.tempoLisrArray.remove(at: indexPath.row)
                tableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
            
            completionHandler(true)
        }
        
        delete.backgroundColor = UIColor(named: "DeleteColor")
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            
            var textField = UITextField()
            
            let editAlert = UIAlertController(title: "", message: "Edit name?", preferredStyle: .alert)
            editAlert.view.tintColor = UIColor(named: "TextColor")
            
            editAlert.addTextField { editTextField in
                editTextField.placeholder = "Enter name"
                textField = editTextField
            }
            
            editAlert.addAction(UIAlertAction(title: "Update", style: .default, handler: { alertAction in
                if textField.text == "" {
                    self.tempoLisrArray[indexPath.row].name = self.tempoLisrArray[indexPath.row].name
                } else {
                    self.tempoLisrArray[indexPath.row].name = textField.text
                    self.tempoLisrArray[indexPath.row].setValue(textField.text, forKey: "name")
                    self.saveTempoItems()
                }
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }))
            
            editAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(editAlert, animated: true) {
                editAlert.view.superview?.isUserInteractionEnabled = true
                editAlert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            }
            
            completionHandler(true)
        }

        edit.backgroundColor = UIColor(named: "EditColor")
        
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit])
        return swipe
    }
    
}

extension MainViewController: UIPopoverPresentationControllerDelegate,  AudioListDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func fetchAudioToMainVC(audioName: String) {
        print("name - \(audioName)")
        selectedAudioButton.setTitle(audioName, for: .normal)
    }
    
}
