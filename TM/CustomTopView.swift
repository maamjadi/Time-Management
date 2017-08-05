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
    
    var widthConstant: CGFloat = 20
    
    @IBInspectable var numberOfLines: CGFloat = 22 {
        didSet{ updateView() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private var lines = [UIView]()
    
    func updateView() {
        let width = self.frame.size.width
        let height = self.frame.size.height
        widthConstant = width/(self.numberOfLines + 2)
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
                let diff = (height-heightConstant - (height-heightConstant)*0.9)
                constants.append(heightConstant)
                view = UIView(frame: CGRect(x: xPoint, y: ((heightConstant+diff)/2), width: lineWidth, height: (height-heightConstant)*0.9))
            }
            else if jump == center {
                view = UIView(frame: CGRect(x: xPoint, y: 0, width: lineWidth, height: height))
            }
            else if jump > center {
                heightConstant = constants.removeLast()
                let diff = (height-heightConstant - (height-heightConstant)*0.9)
                view = UIView(frame: CGRect(x: xPoint, y: ((heightConstant+diff)/2), width: lineWidth, height: (height-heightConstant)*0.9))
            }
            view.backgroundColor = UIColor.white
            view.layer.cornerRadius = 1.3
            self.addSubview(view)
            self.lines.append(view)
            view.bringSubview(toFront: view)
        }
    }
    
    func animateTheView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveLinear, animations: {
            for item in self.lines {
                item.transform = CGAffineTransform(translationX: -self.widthConstant, y: 0)
            }
        })
        for item in self.lines {
            item.transform = CGAffineTransform.identity
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        updateView()
    }
}
