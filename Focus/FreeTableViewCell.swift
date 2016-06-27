//
//  FreeTableViewCell.swift
//  FocusDayView
//
//  Created by Scott Horsfall on 6/23/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import UIKit

class FreeTableViewCell: UITableViewCell {
    
    // labels
    @IBOutlet weak var timeLabel: UILabel!
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
