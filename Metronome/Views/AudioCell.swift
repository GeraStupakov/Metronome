//
//  AudioCell.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/21/21.
//

import UIKit

class AudioCell: UITableViewCell {
    
    @IBOutlet weak var audioLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            contentView.backgroundColor = UIColor(named: "TapCellColor")
        } else {
            contentView.backgroundColor = UIColor(named: "CellColor")
        }
    }
}
