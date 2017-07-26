//
//  EventCollectionViewCell.swift
//  TM
//
//  Created by Amin Amjadi on 7/14/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit
import EventKit

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var checklistLabel: UILabel!
    
    var event: EKEvent! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        titleLabel.text = event.title
        locationLabel.text = event.location ?? "not Set"
        notesLabel.text = event.notes ?? "None"
        tagLabel.text = "Red"
        calendarLabel.text = event.calendarItemExternalIdentifier
        let checkAlarm = event.hasAlarms
        let alarm: String = checkAlarm ? (String(describing: event.alarms?.count)) : "None"
        alertLabel.text = alarm
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
}
