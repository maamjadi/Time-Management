//
//  HomeViewController.swift
//  Time Management
//
//  Created by Amin Amjadi on 10/12/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            
            if let user = user {

        try! FIRAuth.auth()!.signOut()
        
        FBSDKAccessToken.setCurrent(nil)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
        let loggingView: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "loginView")
        
        self.present(loggingView, animated: true, completion: nil)
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showProfile() {
        let storyBoard = UIStoryboard(name: "Authentication", bundle: nil)
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "loginView")
        
        self.present(mainViewController, animated: true, completion: nil)
    }

}

