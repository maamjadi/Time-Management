//
//  SettingTableViewController.swift
//  TM
//
//  Created by Amin Amjadi on 4/24/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class SettingTableViewController: UITableViewController, AfterAsynchronous {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var typeOfAccTextField: UILabel!
    @IBOutlet weak var themeSwitch: UISwitch!
    @IBOutlet weak var googleSwitch: UISwitch!
    @IBOutlet weak var outlookSwitch: UISwitch!
    
    let user = FIRAuth.auth()?.currentUser
    
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
        
        if let name = user?.displayName {
            nameTextField.text = name
            nameTextField.isHidden = false
        }
        let uid = user?.uid
        
        //            if let typeExist = UserService.userService.returnTypeOfAccount(uid: uid) {
        //                typeOfAccTextField.text = typeExist
        //                typeOfAccTextField.isHidden = false
        //            }
        
        if let photoURL = user?.photoURL {
            if let data = try? Data(contentsOf: photoURL) {
                self.profileImage.image = UIImage(data: data)
            }
        }
        UserService.shared.loadProfilePictureFromStorage(user: user! , afterLoadingThePiture : self)
        
        if let savedValue = UserDefaults.standard.value(forKey: "theme") {
            themeSwitch.isOn = savedValue as! Bool
        }
        
        if let googleConnected =  UserDefaults.standard.value(forKey: "GoogleCalStatus") {
            googleSwitch.isOn = googleConnected as! Bool
        }
        
        if let outlookConnected = UserDefaults.standard.value(forKey: "OutlookCalStatus") {
            outlookSwitch.isOn = outlookConnected as! Bool
        }
    }
    
    @IBAction func themeSwitchIsChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "theme")
        ColorConstants.colorConstants.changeDefaultTheme()
    }
    
    @IBAction func googleSwitchIsChanged(_ sender: UISwitch) {
    }
    
    @IBAction func outlookSwitchIsChanged(_ sender: UISwitch) {
    }
    
    
    @IBAction func logout() {
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
    
    func onFinish() {
        let loadPic = AppError.manageError.giveError(typeOfError: "UserService")
        if loadPic == true {
            let imageData = UserService.shared.giveImageData()
            profileImage.image = UIImage(data: imageData!)
        }
        
    }
}
