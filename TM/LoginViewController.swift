//
//  ViewController.swift
//  Authentication
//
//  Created by Amin Amjadi on 7/26/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController, AfterAsynchronous {
    
    @IBOutlet weak var fbLoginButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var gLoginButton: UIButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    let mainQueue = DispatchQueue.main
    let defaultQueue = DispatchQueue.global(qos: .default)

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidden(false)
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }
            else {
                // No user is signed in.
            }
        }
        
        //Looks for single or multiple taps.
        tapDismissGesture()
    }
    
    @IBAction func facebookLoginButton() {
        self.hidden(true)
        self.loadingSpinner.startAnimating()
        defaultQueue.async {
          UserService.userService.signIn("Facebook", email: nil, pass: nil,afterSignIn: self)
        }
    }
    
    func hidden(_ bool: Bool) {
        self.fbLoginButton.isHidden = bool
        self.loginButton.isHidden = bool
        self.signUpButton.isHidden = bool
        self.gLoginButton.isHidden = bool
    }
    
    func onFinish() {
        let checkSignIn = Error.manageError.giveError(typeOfError: "UserService")
        if checkSignIn == true {
            print("User has been logged in successfully")
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.login()
        } else {
            self.hidden(false)
            self.loadingSpinner.stopAnimating()
            self.giveAnAlert("There is an Error, please try again later")
        }
    }
    
}


