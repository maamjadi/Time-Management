//
//  AlertController.swift
//  Time Management
//
//  Created by Amin Amjadi on 1/30/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func giveAnAlert(_ message: String) {
        let alertController = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
