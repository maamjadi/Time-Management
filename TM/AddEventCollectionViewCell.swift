//
//  AddEventCollectionViewCell.swift
//  TM
//
//  Created by Amin Amjadi on 7/15/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

class AddEventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
}
