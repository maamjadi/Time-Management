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

class SignUpViewController: UIViewController, AfterAsynchronous {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPassTextField: UITextField!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    
    let imagePicker = UIImagePickerController()
    var selectedPhoto: UIImage! = UIImage()
    //var photo: UIImage = UIImage()
    
    let mainQueue = DispatchQueue.main
    let defaultQueue = DispatchQueue.global(qos: .default)
    
    @IBAction func dismissButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verifyPassTextField.isEnabled = false
        passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        profileImage.tintColor = UIColor.white.withAlphaComponent(0.5)
        self.hidden(false)
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                //                self.deregisterFromKeyboardNotifications()
                
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }
            else {
                // No user is signed in.
            }
        }
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height/2
        self.profileImage.clipsToBounds = true
        self.profileImage.isUserInteractionEnabled = true
        //Looks for single or multiple taps.
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.selectPhoto(_:)))
        profileImage.addGestureRecognizer(tapRecognizer)
        
        tapDismissGesture()
        
        //        registerForKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func selectPhoto(_ gestureRecognizer: UITapGestureRecognizer)
    {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        
        let alertController = UIAlertController(title: "Profile Picture", message: "Choose From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
            alertController.addAction(photoLibraryAction)
        } else {
            alertController.addAction(photoLibraryAction)
        }
        alertController.addAction(cancelAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func editingChanged(_ textField: UITextField) {
        if textField.text?.characters.count == 1 {
            if textField.text?.characters.first == " " {
                textField.text = ""
                return
            }
        }
        guard let pass = passwordTextField.text, !pass.isEmpty else {
            verifyPassTextField.text = nil
            verifyPassTextField.isEnabled = false
            return
        }
        verifyPassTextField.isEnabled = true
    }
    
    
    @IBAction func signUp() {
        guard let name = nameTextField.text , !name.isEmpty, let email = emailTextField.text , !email.isEmpty, let pass = passwordTextField.text , !pass.isEmpty, let verPass = verifyPassTextField.text , !verPass.isEmpty else {
            
            giveAnAlert("Please fill all the informations", alertControllerTitle: "Warning")
            
            return
        }
        if pass == verPass {
            self.hidden(true)
            self.loadingSpinner.startAnimating()
            var data = Data()
            data = UIImageJPEGRepresentation(profileImage.image!, 0.1)!
            defaultQueue.async {
                UserService.shared.signUp(self.nameTextField.text!, email: self.emailTextField.text!, pass: self.passwordTextField.text!, imageData: data,afterSignUp: self)
            }
            
        } else {
            giveAnAlert("Your passwords doesn't match", alertControllerTitle: "Warning")
        }
    }
    
    
    
    func hidden(_ bool: Bool) {
        self.nameTextField.isHidden = bool
        self.verifyPassTextField.isHidden = bool
        self.emailTextField.isHidden = bool
        self.passwordTextField.isHidden = bool
        self.profileImage.isHidden = bool
        self.signUpButton.isHidden = bool
        self.dismissButton.isHidden = bool
    }
    
    func onFinish() {
        let checkSignUp = AppError.manageError.giveError(typeOfError: "UserService")
        if checkSignUp == true {
            print("User successfully signed up")
            //            self.deregisterFromKeyboardNotifications()
            let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.login()
        }
        else if checkSignUp == false {
            self.hidden(false)
            self.loadingSpinner.stopAnimating()
            self.giveAnAlert("Something went wrong, please try again later", alertControllerTitle: "Warning")
        }
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

