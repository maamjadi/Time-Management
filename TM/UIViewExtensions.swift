//
//  UIViewExtensions.swift
//  TM
//
//  Created by Amin Amjadi on 7/6/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, sizeTransformation: Bool = true, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        if sizeTransformation == true { self.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5) }
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
            self.transform  = CGAffineTransform.identity
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 0.8, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
            self.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        }, completion: completion)
    }
}

