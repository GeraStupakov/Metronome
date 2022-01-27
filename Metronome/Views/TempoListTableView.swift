//
//  TempoListTableView.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/16/21.
//

import UIKit

class TempoListTableView: UITableView, UIDropInteractionDelegate {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: px)
        let line = UIView(frame: frame)
        self.tableHeaderView = line
        line.backgroundColor = self.separatorColor
        
        self.register(UINib(nibName: "TempoCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        self.reloadData()
        
        self.dragDelegate = self
        self.dropDelegate = self
        self.dragInteractionEnabled = true
    }
}

//MARK: - UITableViewDragDelegate & UITableViewDropDelegate
extension TempoListTableView: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
}

extension TempoListTableView: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {

        if session.localDragSession != nil { // Drag originated from the same app.
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }
    
}
