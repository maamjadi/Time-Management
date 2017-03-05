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

class MainViewController: UIViewController , AfterAsynchronous {

    
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var typeOfAccTextField: UILabel!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    var manageError = Error()
    
    @IBAction func logOut() {
        
        //signs the user out of firebase app
        try! FIRAuth.auth()!.signOut()
        
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
            var counter: Int = 0
            UserService.userService.loadProfilePictureFromStorage(user: user , afterLoadingThePiture: self)
            let loadPicFromStorage = manageError.giveError(typeOfError: "UserService")
            counter += 1
            if loadPicFromStorage == false && counter != 1 {
                UserService.userService.loadProfilePictureFromFB(user: user)
            }
            let loadPic = manageError.giveError(typeOfError: "UserService")
            if loadPic == true {
//                let imageData = UserService.userService.giveImageData()
//                if imageData != nil {
//                    profileImage.image = UIImage(data: imageData!)
//                    profileImage.isHidden = false
//                } else {
//                    profileImage.isHidden = true
//                }
            }
            loadingSpinner.stopAnimating()
            
        } else {
            // No user is signed in.
        }
    }
    internal func onFinish() {
        
    }

}
