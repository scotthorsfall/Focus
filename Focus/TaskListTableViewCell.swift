//
//  TaskListTableViewCell.swift
//  Focus
//
//  Created by Scott Horsfall on 7/4/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import UIKit

class TaskListTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var taskCellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        
        let didTap = UITapGestureRecognizer(target: self, action: #selector(TaskListTableViewCell.taskCellTapped(_:)))
        taskCellView.addGestureRecognizer(didTap)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func taskCellTapped(sender: UITapGestureRecognizer) {
        print("task cell tapped")
    }
    

}
