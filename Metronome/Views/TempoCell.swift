//
//  TempoCell.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/7/21.
//

import UIKit

class TempoCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var beatLabel: UILabel!
    @IBOutlet weak var valueImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
