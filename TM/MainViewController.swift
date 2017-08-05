//
//  MainViewController.swift
//  Authentication
//
//  Created by Amin Amjadi on 7/30/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase

class MainViewController: UIViewController, AfterAsynchronous {
    
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var typeOfAccTextField: UILabel!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    @IBAction func logOut() {
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        FBSDKAccessToken.setCurrent(nil)
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.login()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
            }
            else {
                // No user is signed in.
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }
        }
        
        
        typeOfAccTextField.isHidden = true
        nameTextField.isHidden = true
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.clipsToBounds = true
        
        navigationController?.isNavigationBarHidden = true
        
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            loadingSpinner.startAnimating()
            
            if let name = user.displayName {
                nameTextField.text = name
                nameTextField.isHidden = false
            }
            let uid = user.uid
            
            //            if let typeExist = UserService.userService.returnTypeOfAccount(uid: uid) {
            //                typeOfAccTextField.text = typeExist
            //                typeOfAccTextField.isHidden = false
            //            }
            
            if let photoURL = user.photoURL {
                if let data = try? Data(contentsOf: photoURL) {
                    self.profileImage.image = UIImage(data: data)
                }
            }
            UserService.shared.loadProfilePictureFromStorage(user: user, afterLoadingThePiture: self)
            
            
        } else {
            // No user is signed in.
        }
    }
    
    func onFinish() {
        let loadPic = AppError.manageError.giveError(typeOfError: "UserService")
        if loadPic == true {
            let imageData = UserService.shared.giveImageData()
            if imageData != nil {
                profileImage.image = UIImage(data: imageData!)
                profileImage.isHidden = false
            } else {
                profileImage.isHidden = true
            }
        }
        loadingSpinner.stopAnimating()
    }
    
}
