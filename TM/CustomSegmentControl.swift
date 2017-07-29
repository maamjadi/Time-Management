//
//  CustomSegmentControl.swift
//  TM
//
//  Created by Amin Amjadi on 7/27/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

@IBDesignable
class CustomSegmentControl: UIControl {
    
    var buttons = [UIButton]()
    var selectorView: UIView!
    var selectedButtonIndex = 0
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var borderRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = borderRadius
        }
    }
    
    @IBInspectable
    var commaSeperatedButtons: String = "" {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var selectorBorderWidth: CGFloat = 0 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var selectorColor: UIColor = UIColor.blue {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var textColor: UIColor = UIColor.black {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var selectedTextColor: UIColor = UIColor.white {
        didSet {
            updateView()
        }
    }
    func updateView() {
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        
        let buttonTitles = commaSeperatedButtons.components(separatedBy: ",")
        
        for btnTitle in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(btnTitle, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        buttons[0].setTitleColor(selectedTextColor, for: .normal)
        
        let selectorWidth = frame.size.width / CGFloat(buttonTitles.count)
        selectorView = UIView(frame: CGRect(x: 0, y: 0, width: selectorWidth, height: self.frame.height))
        selectorView.layer.cornerRadius = borderRadius
        selectorView.layer.borderWidth = selectorBorderWidth
        selectorView.backgroundColor = selectorColor
        addSubview(selectorView)
        
        let sv = UIStackView(arrangedSubviews: buttons)
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillProportionally
        addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        sv.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        sv.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        
    }
    
    func buttonTapped(button: UIButton) {
        for (buttonIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(textColor, for: .normal)
            if btn == button {
                selectedButtonIndex = buttonIndex
                let selectorPosition = frame.width / CGFloat(buttons.count) * CGFloat(buttonIndex)
                UIView.animate(withDuration: 0.3, animations: {
                    self.selectorView.frame.origin.x = selectorPosition
                })
                btn.setTitleColor(selectedTextColor, for: .normal)
            }
        }
        
        sendActions(for: .valueChanged)
    }

}
