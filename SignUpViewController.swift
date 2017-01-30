//
//  SignUpViewController.swift
//  Authentication
//
//  Created by Amin Amjadi on 7/28/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var vertifyPassTextField: UITextField!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    var manageError = Error()
    
    let imagePicker = UIImagePickerController()
    var selectedPhoto: UIImage! = UIImage()
    //var photo: UIImage = UIImage()
    
    let mainQueue = DispatchQueue.main
    let defaultQueue = DispatchQueue.global(qos: .default)
    
    @IBAction func dissmisButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidden(false)
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                self.deregisterFromKeyboardNotifications()
                
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }
            else {
                // No user is signed in.
            }
        }
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height/2
        self.profileImage.clipsToBounds = true
        
        //Looks for single or multiple taps.
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.selectPhoto(_:)))
        profileImage.addGestureRecognizer(tapRecognizer)
        
        tapDismissGesture()
        
        registerForKeyboardNotifications()
        
    }
    
    
    func selectPhoto(_ gestureRecognizer: UITapGestureRecognizer)
    {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.sourceType = .camera
        } else {
            self.imagePicker.sourceType = .photoLibrary
        }
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func signUp() {
        guard let name = nameTextField.text , !name.isEmpty, let email = emailTextField.text , !email.isEmpty, let pass = passwordTextField.text , !pass.isEmpty, let verPass = vertifyPassTextField.text , !verPass.isEmpty else {
            
            giveAnAlert("Please fill all the informations")
            
            return
        }
        if pass == verPass {
            self.hidden(true)
            self.loadingSpinner.startAnimating()
            var data = Data()
            data = UIImageJPEGRepresentation(profileImage.image!, 0.1)!
            FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user , error) in
                self.manageError.changeError(typeOfError: "UserService", error: true)
                if error != nil {
                    print(error?.localizedDescription)
                    self.hidden(false)
                    self.loadingSpinner.stopAnimating()
                    self.giveAnAlert(error!.localizedDescription)
                } else {
                    if let user = user {
                        UserService.userService.initialLicense(user)
                        UserService.userService.authChangeReq(user, displayName: name, photoURL: nil)
                        UserService.userService.changePicture(user: user, imageData: data)
                        let checkSignUp = self.manageError.giveError(typeOfError: "UserService")
                        if checkSignUp == true {
                            print("User successfully signed up")
                            self.deregisterFromKeyboardNotifications()
                            
                            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
                            let mainViewController: UIViewController = mainStoryBoard.instantiateViewController(withIdentifier: "mainView")
                            self.present(mainViewController, animated: true, completion: nil)
                        }
                        else if checkSignUp == false {
                            self.hidden(false)
                            self.loadingSpinner.stopAnimating()
                            
                            self.giveAnAlert("Something went wrong, please try again later")
                        }
                        
                    }
                }
            })
            
        } else {
            giveAnAlert("Your passwords doesn't match")
        }
    }
    
    
    
    func hidden(_ bool: Bool) {
        self.nameTextField.isHidden = bool
        self.vertifyPassTextField.isHidden = bool
        self.emailTextField.isHidden = bool
        self.passwordTextField.isHidden = bool
        self.profileImage.isHidden = bool
        self.signUpButton.isHidden = bool
        self.dismissButton.isHidden = bool
    }
    
    
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //imagePicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedPhoto = info[UIImagePickerControllerEditedImage] as! UIImage
        self.profileImage.image = selectedPhoto
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

