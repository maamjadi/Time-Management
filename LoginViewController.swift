//
//  ViewController.swift
//  Authentication
//
//  Created by Amin Amjadi on 7/26/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController,AfterSignIn {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fbLoginButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var startingViewSpinner: UIActivityIndicatorView!
    
    let mainQueue = DispatchQueue.main
    let defaultQueue = DispatchQueue.global(qos: .default)

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidden(false)
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
                let mainViewController: UIViewController = mainStoryBoard.instantiateViewController(withIdentifier: "mainView")
                
                self.present(mainViewController, animated: true, completion: nil)
            }
            else {
                // No user is signed in.
            }
        }
        
        //Looks for single or multiple taps.
        tapDismissGesture()
        
    }
    
    
    @IBAction func login() {
        guard let email = emailTextField.text , !email.isEmpty, let pass = passwordTextField.text , !pass.isEmpty else {
            let alertController = UIAlertController(title: "Warning", message: "Please fill all the informations", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        self.hidden(true)
        self.startingViewSpinner.startAnimating()
        defaultQueue.async {
            UserService.userService.signIn("Email", email: email, pass: pass,afterSignIn: self)
        }
    }
    
    @IBAction func facebookLoginButton() {
        
        self.hidden(true)
        self.startingViewSpinner.startAnimating()
        defaultQueue.async {
          UserService.userService.signIn("Facebook", email: nil, pass: nil,afterSignIn: self)
        
        }
    }
    
    func hidden(_ bool: Bool) {
        self.fbLoginButton.isHidden = bool
        self.loginButton.isHidden = bool
        self.emailTextField.isHidden = bool
        self.passwordTextField.isHidden = bool
        self.signUpButton.isHidden = bool
    }
    
    func onFinish() {
            let checkSignIn = Error.manageError.giveError(typeOfError: "UserService")
        if checkSignIn == true {
            print("User has been loged in successfully")
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.login()
        }
         else {
            self.hidden(false)
            self.startingViewSpinner.stopAnimating()
            let alertController = UIAlertController(title: "Warning", message: "There is an Error, please try again later", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }

    }
    
}


