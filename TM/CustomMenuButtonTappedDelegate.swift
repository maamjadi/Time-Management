//
//  CustomMenuButtonAction.swift
//  TM
//
//  Created by Amin Amjadi on 7/10/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import Foundation

@objc protocol CustomMenuButtonTappedDelegate {
    func menuButtonAction(tabBarController: CustomTabBarController, button: UIButton)->Void
}
