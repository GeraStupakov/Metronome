//
//  TempoListTableView.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/16/21.
//

import UIKit

class TempoListTableView: UITableView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: px)
        let line = UIView(frame: frame)
        self.tableHeaderView = line
        line.backgroundColor = self.separatorColor
    }

}
