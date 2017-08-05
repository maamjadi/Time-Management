//
//  RotatableView.swift
//  TM
//
//  Created by Amin Amjadi on 8/1/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

@IBDesignable
class RotatableView: UIView {

    var xOffSet:CGVector = CGVector(dx: 0, dy: 0)
    var yOffSet:CGVector = CGVector(dx: 0, dy: 0)
    var origin:CGPoint = CGPoint.zero
    var tempTransform=CGAffineTransform()
    var subviewsTransform = [CGAffineTransform]()
    var startingAngle:CGFloat?
    var viewSubView = [UIView]()
    
    
    @IBInspectable var imageColor: UIColor = UIColor.white {
        didSet {
          let imageView = subviews.filter{($0 is UIImageView)}
            for image in imageView {
                image.tintColor = imageColor
            }
        }
    }
    
    @IBInspectable var labelColor: UIColor = UIColor.white {
        didSet {
            let labelView = subviews.filter{($0 is UILabel)}
            for label in labelView {
                (label as! UILabel).textColor = labelColor
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        origin = (touches.first?.location(in: self.superview))!
        xOffSet = CGVector(dx:(origin.x)-self.center.x, dy:(origin.y) - self.center.y)
        startingAngle = atan2(xOffSet.dy,xOffSet.dx)
        
        //numberLabels = subviews.filter{$0 is UILabel}
        
        //save the current transform
        tempTransform = self.transform
        
        viewSubView = subviews.filter{!($0 is UIImageView)}
        
        if !(subviewsTransform.isEmpty) {
            subviewsTransform.removeAll()
        }
        for (index, subv) in viewSubView.enumerated() {
            subviewsTransform.insert(subv.transform, at: index)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touchPoint = touches.first?.location(in: self.superview)
        yOffSet = CGVector(dx:touchPoint!.x - self.center.x, dy:touchPoint!.y - self.center.y)
        let angle = atan2(yOffSet.dy,yOffSet.dx)
        
        let deltaAngle = angle - startingAngle!
        self.transform = tempTransform.rotated(by: deltaAngle)

        for (index, subv) in viewSubView.enumerated() {
            subv.transform = subviewsTransform[index].rotated(by: -deltaAngle)
        }

    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        startingAngle = nil
    }
    
    //reset in case drag is cancelled
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        self.transform = tempTransform
        for (index, subv) in viewSubView.enumerated() {
            subv.transform = subviewsTransform[index]
        }
        
        startingAngle = nil
    }

}
