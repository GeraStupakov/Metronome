//
//  SettingsViewController.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/23/21.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var adsButton: UIButton!
    @IBOutlet weak var themeControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adsButton.layer.cornerRadius = 5
        themeControl.selectedSegmentIndex = ThemeApp.current.rawValue
    }
    
    @IBAction func changedThemeControl(_ sender: UISegmentedControl) {
        
        guard let theme = ThemeApp(rawValue: themeControl.selectedSegmentIndex) else { return }
        
        theme.setActive()
        
    }
    
    @IBAction func pressedAdsButton(_ sender: UIButton) {

    }
    
    @IBAction func pressedBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
