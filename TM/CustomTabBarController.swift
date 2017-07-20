//
//  CustomTabBarController.swift
//  TM
//
//  Created by Amin Amjadi on 3/4/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let centerBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBar.barStyle = .black
        self.delegate = self
        
        let controller1 = self.viewControllers?[0]
        let controller2 = self.viewControllers?[1]
        let controller3 = self.viewControllers?[2]
        let controller4 = self.viewControllers?[3]
        
        let customController = UIStoryboard(name: "Visualization", bundle: nil).instantiateViewController(withIdentifier: "mainView")
        
        self.viewControllers = [controller1!,controller2!,customController,controller3!,controller4!]
        
        self.setupMiddleButton(centerButton: self.centerBtn, image: "addBtn", backgroundColor: #colorLiteral(red: 0.5137, green: 0.5137, blue: 0.5137, alpha: 1))
    }
    
    func setupMiddleButton(centerButton: UIButton, image: String, backgroundColor: UIColor = .clear) {
        
        var menuButtonFrame = centerButton.frame
        menuButtonFrame.origin.y = self.view.bounds.height - menuButtonFrame.height
        menuButtonFrame.origin.x = self.view.bounds.width/2 - menuButtonFrame.size.width/2
        centerButton.frame = menuButtonFrame
        
        centerButton.backgroundColor = backgroundColor
        centerButton.tintColor = #colorLiteral(red: 0.349, green: 0.349, blue: 0.349, alpha: 1)
        centerButton.layer.cornerRadius = menuButtonFrame.height/2
        
        centerButton.setImage(UIImage(named: image), for: UIControlState.normal) // 450 x 450px
        
        centerButton.contentMode = .scaleAspectFit
        
        centerButton.addTarget(self, action: #selector(centerButtonAction(sender:)), for: .touchUpInside)
        
        self.view.addSubview(centerButton)
        
        
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        self.bringcenterButtonToFront();
    }
    
    func centerButtonAction(sender: UIButton) {
        self.selectedIndex = 2
        let storyboard = UIStoryboard(name: "Visualization", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddEventView")
        vc.modalTransitionStyle = .crossDissolve
        
        self.present(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func bringcenterButtonToFront() {
        print("bringcenterButtonToFront called...")
        self.view.bringSubview(toFront: self.centerBtn);
    }
    
    func hideTabBar() {
        self.tabBar.isHidden = true
        self.centerBtn.isHidden = true
    }
    
    func showTabBar() {
        self.tabBar.isHidden = false
        self.centerBtn.isHidden = false
        self.bringcenterButtonToFront()
    }
    
    func changeCenterButtonColor(backgroundColor: UIColor, tintColor: UIColor) {
        centerBtn.backgroundColor = backgroundColor
        centerBtn.tintColor = tintColor
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
