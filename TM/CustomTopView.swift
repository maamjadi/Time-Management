//
//  CustomTopView.swift
//  TM
//
//  Created by Amin Amjadi on 7/20/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTopView: UIView {
    
    @IBInspectable var numberOfLines: CGFloat = 22 {
        didSet{ updateView() }
    }
    
    func updateView() {
        let width = self.frame.size.width
        let height = self.frame.size.height
        let widthConstant = width/(self.numberOfLines + 2)
        var heightConstant: CGFloat = 0
        var jumps: Int = 0
        var constants = [CGFloat]()
        if (Int(self.numberOfLines) % 2 == 0) {
        jumps = Int(self.numberOfLines+1)
        } else {
           jumps = Int(self.numberOfLines+2)
        }
        var center = jumps / 2
        center += 1
        for jump in 1...jumps {
            let xPoint = (CGFloat(jump))*widthConstant
            var lineWidth: CGFloat = 1
            if jump % 4 == 0 {
                lineWidth = 2.5
            }
            var view = UIView()
            if jump < center {
                let substractionConstant = CGFloat(center*jump)
                let constant = substractionConstant/(CGFloat(center)/5)
            heightConstant = height - constant
                constants.append(heightConstant)
            view = UIView(frame: CGRect(x: xPoint, y: (heightConstant)/2, width: lineWidth, height: height-heightConstant))
            }
            else if jump == center {
                view = UIView(frame: CGRect(x: xPoint, y: 0, width: lineWidth, height: height))
            }
            else if jump > center {
                heightConstant = constants.removeLast()
                view = UIView(frame: CGRect(x: xPoint, y: (heightConstant)/2, width: lineWidth, height: height-heightConstant))
            }
            view.backgroundColor = UIColor.white
            self.addSubview(view)
            view.bringSubview(toFront: view)
        }
    }
    
    override func draw(_ rect: CGRect) {
        updateView()
    }
}
