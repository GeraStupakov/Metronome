//
//  AudioTableViewController.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/21/21.
//

import UIKit

protocol AudioListDelegate: AnyObject {
    func fetchAudioToMainVC(newAudioName: String)
}

class AudioTableViewController: UITableViewController {
    
    var audioArray = ["Default", "Ableton", "Cubase", "Logic", "Sonar"]
    
    weak var delegate: AudioListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "AudioCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! AudioCell
        cell.audioLabel.text = audioArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audio = audioArray[indexPath.row]
        
        delegate?.fetchAudioToMainVC(newAudioName: audio)
        
        self.dismiss(animated: true, completion: nil)
    }
        
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
