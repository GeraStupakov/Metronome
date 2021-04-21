//
//  AudioDropDownButton.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/16/21.
//

import UIKit

class AudioDropDownButton: UIButton {

    var dropView = DropDownView()
    var height = NSLayoutConstraint()
    var isOpen = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        dropView = DropDownView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        dropView.translatesAutoresizingMaskIntoConstraints = false
                
        self.dropView.audioArray = ["Audio 1", "Audio 2", "Audio 3", "Audio 1", "Audio 2", "Audio 3", "Audio 2", "Audio 3", "Audio 1"]
    }
    
    override func didMoveToSuperview() {
        
        self.superview?.addSubview(dropView)
        self.superview?.bringSubviewToFront(dropView)
        //self.superview?.insertSubview(dropView, at: 0)
        
        dropView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        dropView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dropView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        height = dropView.heightAnchor.constraint(equalToConstant: 0)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOpen == false {

            isOpen = true

            NSLayoutConstraint.deactivate([self.height])

            if self.dropView.audioTableView.contentSize.height > 150 {
                self.height.constant = 150
            } else {
                self.height.constant = self.dropView.audioTableView.contentSize.height
            }

            NSLayoutConstraint.activate([self.height])
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
                self.dropView.layoutIfNeeded()
                self.dropView.center.y += self.dropView.frame.height / 2
            }, completion: nil)
        } else {
            isOpen = false
            NSLayoutConstraint.deactivate([self.height])
            self.height.constant = 0
            NSLayoutConstraint.activate([self.height])
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
                self.dropView.center.y -= self.dropView.frame.height / 2
                self.dropView.layoutIfNeeded()
            }, completion: nil)
        }
    }

}

class DropDownView: UIView, UITableViewDelegate, UITableViewDataSource {
        
    var audioArray = [String]()
     
    var audioTableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        audioTableView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
        
        audioTableView.delegate = self
        audioTableView.dataSource = self

        audioTableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(audioTableView)
        //self.bringSubviewToFront(audioTableView)
    
        audioTableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        audioTableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        audioTableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        audioTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
         
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = UITableViewCell()
        
        cell.textLabel!.text = audioArray[indexPath.row]
        cell.backgroundColor = UIColor.lightGray
        cell.tintColor = UIColor.black
        cell.clipsToBounds = false
        cell.contentView.clipsToBounds = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(audioArray[indexPath.row])
    }
    
    
}
