//
//  AudioTableViewController.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/21/21.
//

import UIKit
import Foundation

protocol AudioListDelegate: class {
    func fetchAudioToMainVC(audioName: String)
}

class AudioTableViewController: UITableViewController {
    
    var audioArray = ["Audio 0", "Audio 1", "Audio 2", "Audio 3", "Audio 4"]
    
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
        delegate?.fetchAudioToMainVC(audioName: audio)
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
        
}
