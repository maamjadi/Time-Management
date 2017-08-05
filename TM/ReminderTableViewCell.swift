//
//  ReminderTableViewCell.swift
//  TM
//
//  Created by Amin Amjadi on 7/13/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var scheduleLabel: UILabel!
    
    @IBOutlet weak var checkbox: CheckBoxButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
}
