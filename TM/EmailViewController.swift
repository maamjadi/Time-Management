//
//  EmailViewController.swift
//  TM
//
//  Created by Amin Amjadi on 3/5/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit
import FirebaseAuth

class EmailViewController: UIViewController, AfterSignIn{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var dismissButton: UIButton!
    
     let defaultQueue = DispatchQueue.global(qos: .default)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func dismissButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func login() {
        guard let email = emailTextField.text , !email.isEmpty, let pass = passwordTextField.text , !pass.isEmpty else {
            self.giveAnAlert("Please fill all the informations")
            return
        }
        
        self.hidden(true)
        
        self.loadingSpinner.startAnimating()
        defaultQueue.async {
            UserService.userService.signIn("Email", email: email, pass: pass,afterSignIn: self)
        }
    }

    func hidden(_ bool: Bool) {
        self.emailTextField.isHidden = bool
        self.passwordTextField.isHidden = bool
        self.loginButton.isHidden = bool
        self.dismissButton.isHidden = bool
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
