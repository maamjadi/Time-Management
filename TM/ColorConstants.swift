//
//  ColorConstants.swift
//  TM
//
//  Created by Amin Amjadi on 7/24/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

class ColorConstants {
    
    static let colorConstants = ColorConstants()
    
    private var defaultTheme: Bool? {
        didSet { updateAppTheme() }
    }
    
    private let blackBackgroundConstant = UIColor(red: 0.0549, green: 0.0549, blue: 0.0549, alpha: 1.0)
    private let tableCellsConstant = UIColor(red: 0.1333, green: 0.1373, blue: 0.1373, alpha: 1.0)
    var navigationBarColor: UIBarStyle = UIBarStyle.black
    var baseLayerColor: UIColor = .black
    var tableViewCells: UIColor = .black
    var centerButtonBackgroundColor: UIColor = .white
    var centerButtontintColor: UIColor = .black
    
    func changeDefaultTheme() {
        defaultTheme = (UserDefaults.standard.value(forKey: "theme") as! Bool)
    }
    
    private func updateAppTheme() {
        if defaultTheme == true {
            
        } else {
            
        }
    }
}
