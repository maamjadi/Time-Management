//
//  TagsCollectionViewCell.swift
//  TM
//
//  Created by Amin Amjadi on 7/20/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

class TagsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet weak var defaultIcon: UIImageView!
    @IBOutlet weak var secView: UIView!
    @IBOutlet weak var secIcon: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
    
    func animate() {
        secView.transform = CGAffineTransform(translationX: 0, y: self.frame.size.width)
        secView.isHidden = false
        UIView.animate(withDuration: 0.7) { 
            self.secView.transform = .identity
        }
        defaultView.backgroundColor = secView.backgroundColor
        defaultIcon.image = secIcon.image
        secView.isHidden = true
    }
}
