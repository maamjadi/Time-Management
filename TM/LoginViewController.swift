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
import GoogleSignIn

class LoginViewController: UIViewController, AfterAsynchronous, GIDSignInUIDelegate {
    
    @IBOutlet weak var fbLoginButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var gLoginButton: UIButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextFieldX!
    @IBOutlet weak var passwordTextField: UITextFieldX!
    @IBOutlet weak var orTextView: UIView!
    
    let mainQueue = DispatchQueue.main
    let defaultQueue = DispatchQueue.global(qos: .default)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
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
        fbLoginButton.tintColor = UIColor.white.withAlphaComponent(0.5)
        self.hidden(true)
        self.loadingSpinner.startAnimating()
        defaultQueue.async {
            UserService.userService.signIn("Facebook", email: nil, pass: nil,afterSignIn: self)
        }
    }
    
    @IBAction func googleLoginButton() {
        gLoginButton.tintColor = UIColor.white.withAlphaComponent(0.5)
        Error.manageError.changeError(typeOfError: "UserService", error: nil)
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    @IBAction func changeColorFB(_ sender: UIButton) {
        sender.tintColor = #colorLiteral(red: 0.2235, green: 0.3412, blue: 0.5804, alpha: 1)
    }
    @IBAction func changeColorFBToNormal(_ sender: UIButton) {
        sender.tintColor = UIColor.white.withAlphaComponent(0.5)
    }
    
    @IBAction func changeColorGoogle(_ sender: UIButton) {
        sender.tintColor = #colorLiteral(red: 0.8353, green: 0.2588, blue: 0.2078, alpha: 1)
    }
    @IBAction func changeColorGToNormal(_ sender: UIButton) {
        sender.tintColor = UIColor.white.withAlphaComponent(0.5)
    }
    
    private func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        self.hidden(false)
        self.loadingSpinner.stopAnimating()
    }
    
    @IBAction func login(_ sender: UIButton) {
        guard let email = emailTextField.text , !email.isEmpty, let pass = passwordTextField.text , !pass.isEmpty else {
            self.giveAnAlert("Please fill all the informations", alertControllerTitle: "Warning")
            return
        }
        
        self.hidden(true)
        
        self.loadingSpinner.startAnimating()
        defaultQueue.async {
            UserService.userService.signIn("Email", email: email, pass: pass,afterSignIn: self)
        }
    }
    
    
    func hidden(_ bool: Bool) {
        self.fbLoginButton.isHidden = bool
        self.loginButton.isHidden = bool
        self.signUpButton.isHidden = bool
        self.gLoginButton.isHidden = bool
        self.emailTextField.isHidden = bool
        self.passwordTextField.isHidden = bool
        self.orTextView.isHidden = bool
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
            self.giveAnAlert("There is an Error, please try again later", alertControllerTitle: "Warning")
        }
    }
    
}


