//
//  CustomTabBarController.swift
//  TM
//
//  Created by Amin Amjadi on 3/4/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, CustomMenuButtonAction {
    
    let menuBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBar.barStyle = .black
        self.setupMiddleButton(menuButton: menuBtn, image: "addBtn", backgroundColor: .white)
        
        let controller1 = self.viewControllers?[0]
        let controller2 = self.viewControllers?[1]
        let controller3 = self.viewControllers?[2]
        let controller4 = self.viewControllers?[3]
        
        let customController = UIViewController()
        let custom = UINavigationController(rootViewController: customController)
        custom.title = ""
        
        self.viewControllers = [controller1!,controller2!,custom,controller3!,controller4!]
    }
    
    func menuButtonAction(sender: UIButton) {
        self.selectedIndex = 2
        let storyboard = UIStoryboard.init(name: "Visualization", bundle: nil)
        let addEventTableViewController: UITableViewController = storyboard.instantiateViewController(withIdentifier: "AddEventView") as! UITableViewController
        addEventTableViewController.modalTransitionStyle = .partialCurl
        self.present(addEventTableViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension CustomTabBarController {
    func hideTabBar() {
        self.tabBar.isHidden = true
        self.menuBtn.isHidden = true
    }
    
    func showTabBar() {
        self.tabBar.isHidden = false
        self.menuBtn.isHidden = false
    }
}
