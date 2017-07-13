//
//  AlertController.swift
//  Time Management
//
//  Created by Amin Amjadi on 1/30/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func giveAnAlert(_ message: String, alertControllerTitle: String) {
        let alertController = UIAlertController(title: alertControllerTitle, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setupMiddleButton(menuButton: UIButton, image: String, backgroundColor: UIColor = .clear) {
        
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = self.view.bounds.height - menuButtonFrame.height
        menuButtonFrame.origin.x = self.view.bounds.width/2 - menuButtonFrame.size.width/2
        menuButton.frame = menuButtonFrame
        
        menuButton.backgroundColor = backgroundColor
        menuButton.layer.cornerRadius = menuButtonFrame.height/2
        
        menuButton.setImage(UIImage(named: image), for: UIControlState.normal) // 450 x 450px
        
        menuButton.contentMode = .scaleAspectFit
        let menuButtonAction = self as! CustomMenuButtonAction
        
        menuButton.addTarget(self, action: #selector(menuButtonAction.menuButtonAction(sender:)), for: .touchUpInside)
        
        self.view.addSubview(menuButton)
        
        
        self.view.layoutIfNeeded()
    }
    
}
