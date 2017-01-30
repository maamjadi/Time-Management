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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fbLoginButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    let mainQueue = DispatchQueue.main
    let defaultQueue = DispatchQueue.global(qos: .default)
    
    var manageError = Error()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidden(false)
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let user = user {
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
    
    
    @IBAction func login() {
        guard let email = emailTextField.text , !email.isEmpty, let pass = passwordTextField.text , !pass.isEmpty else {
            let alertController = UIAlertController(title: "Warning", message: "Please fill all the informations", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        self.hidden(true)
        self.loadingSpinner.startAnimating()
        FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
            self.manageError.changeError(typeOfError: "UserService", error: true)
            if error != nil {
                print(error?.localizedDescription)
                self.hidden(false)
                self.loadingSpinner.stopAnimating()
                self.giveAnAlert(error!.localizedDescription)
            } else {
                let checkSignIn = self.manageError.giveError(typeOfError: "UserService")
                if checkSignIn == true {
                    print("User has been loged in successfully")
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.login()
                } else {
                    self.hidden(false)
                    self.loadingSpinner.stopAnimating()
                    self.giveAnAlert("There is an Error, please try again later")
                }
            }
        })
        
    }
    
    @IBAction func facebookLoginButton() {
        
        self.hidden(true)
        self.loadingSpinner.startAnimating()
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], handler: { (result, error) -> Void in
            self.manageError.changeError(typeOfError: "UserService", error: true)
            if error != nil {
            }
            else if (result?.isCancelled)! {
            }
            else {
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        self.hidden(false)
                        self.loadingSpinner.stopAnimating()
                        self.giveAnAlert(error!.localizedDescription)
                    } else {
                        if let user = user {
                            print("You have been logged in")
                            UserService.userService.initialLicense(user)
                            let checkSignIn = self.manageError.giveError(typeOfError: "UserService")
                            if checkSignIn == true {
                                print("User has been loged in successfully")
                                let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
                                let mainViewController: UIViewController = mainStoryBoard.instantiateViewController(withIdentifier: "mainView")
                                
                                self.present(mainViewController, animated: true, completion: nil)
                            } else {
                                self.hidden(false)
                                self.loadingSpinner.stopAnimating()
                                self.giveAnAlert("There is an Error, please try again later")
                            }
                        }
                        
                    }
                }
            }
        })
        
    }
    
    func hidden(_ bool: Bool) {
        self.fbLoginButton.isHidden = bool
        self.loginButton.isHidden = bool
        self.emailTextField.isHidden = bool
        self.passwordTextField.isHidden = bool
        self.signUpButton.isHidden = bool
    }
    
}


