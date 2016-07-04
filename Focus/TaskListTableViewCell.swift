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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
