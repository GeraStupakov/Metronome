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
    @IBOutlet weak var valueLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            contentView.backgroundColor = #colorLiteral(red: 0.3197718231, green: 0.3197718231, blue: 0.3197718231, alpha: 1)
        } else {
            contentView.backgroundColor = #colorLiteral(red: 0.1882151961, green: 0.1882481873, blue: 0.188207984, alpha: 1)
        }
    }
    
}
