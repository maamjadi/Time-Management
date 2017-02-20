//
//  UserService.swift
//  Authentication
//
//  Created by Amin Amjadi on 9/7/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit

class UserService {
    
    
    static let userService = UserService()
    
    fileprivate let ref = FIRDatabase.database().reference()
    fileprivate let storageRef = FIRStorage.storage().reference()
    // Create a storage reference from our storage service
    
    
    func signUp(_ name: String, email: String, pass: String, imageData: Data , afterSignUp : AfterSignIn) {
        Error.manageError.changeError(typeOfError: "UserService", error: nil)
        FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user , error) in
            Error.manageError.changeError(typeOfError: "UserService", error: true)
            if error != nil {
                print(error?.localizedDescription)
                Error.manageError.changeError(typeOfError: "UserService", error: false)
                return
            } else {
                if let user = FIRAuth.auth()?.currentUser {
                    self.initialLicense(user)
                    self.authChangeReq(user, displayName: name, photoURL: nil)
                    UserService.userService.changePicture(user: user, imageData: imageData)
                    let checkError = Error.manageError.giveError(typeOfError: "UserService")
                    if checkError == false {
                        Error.manageError.changeError(typeOfError: "UserService", error: false)
                        return
                    }
                    afterSignUp.onFinish()
                }
            }
        })
    }
    
    func initialLicense(_ user: FIRUser) {
        var refHandle = self.ref.child("Users").observe(FIRDataEventType.value, with: { (snapshot) in
            if !(snapshot.hasChild((user.uid) + "/License")) {
                self.ref.child("Users").child(user.uid).child("License/Type").setValue("free")
                self.ref.child("Users").child(user.uid).child("License/Date of creation").setValue(FIRServerValue.timestamp())
            }
        })
    }
    
    
    func signIn(_ method: String, email: String?, pass: String? , afterSignIn:AfterSignIn) {
        Error.manageError.changeError(typeOfError: "UserService", error: nil)
        switch method {
            
        case "Email":
            FIRAuth.auth()?.signIn(withEmail: email!, password: pass!, completion: { (user, error) in
                if error != nil {
                    Error.manageError.changeError(typeOfError: "UserService", error: false)
                    return
                } else {
                    Error.manageError.changeError(typeOfError: "UserService", error: true)
                    if(FIRAuth.auth()?.currentUser != nil){
                        print("there is user")
                    }
                    afterSignIn.onFinish()
                }
            })
            
        case "Facebook":
            let login: FBSDKLoginManager = FBSDKLoginManager()
            login.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], handler: { (result, error) -> Void in
                Error.manageError.changeError(typeOfError: "UserService", error: true)
                if error != nil {
                    Error.manageError.changeError(typeOfError: "UserService", error: false)
                    return
                }
                else if (result?.isCancelled)! {
                    Error.manageError.changeError(typeOfError: "UserService", error: false)
                    return
                }
                else {
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                        if error == nil {
                            print("You have been loged in")
                            self.initialLicense(user!)
                            afterSignIn.onFinish()
                            
                        } else {
                            Error.manageError.changeError(typeOfError: "UserService", error: false)
                            return
                        }
                    }
                }
            })
            
        //        case "Google":
        default: break
        }
    }
    
    
    func authChangeReq(_ user: FIRUser, displayName: String?, photoURL: URL?) {
        let changeRequest = user.profileChangeRequest()
        if displayName != nil {
            changeRequest.displayName = displayName
        }
        if photoURL != nil {
            changeRequest.photoURL = photoURL
        }
        changeRequest.commitChanges { error in
            if let error = error {
                // An error happened.
                print(error.localizedDescription)
                Error.manageError.changeError(typeOfError: "UserService", error: false)
                return
            } else {
                // Profile updated.
            }
            
        }
    }
    
    
    func changePicture(user: FIRUser, imageData: Data) {
        Error.manageError.changeError(typeOfError: "UserService", error: nil)
        let profilePicRef = self.storageRef.child("images"+"/Profile pictures"+"/\(user.uid).jpg")
        let uploadTask = profilePicRef.put(imageData, metadata:nil) { metadata,error in
            Error.manageError.changeError(typeOfError: "UserService", error: true)
            if error == nil {
                //size, content type or the download URL
                let downloadURL: String = metadata!.downloadURLs![0].absoluteString
                let profileURL = NSURL(fileURLWithPath: downloadURL) as URL
                UserService.userService.authChangeReq(user, displayName: nil, photoURL: profileURL)
            } else {
                print("error in uploading the image")
                Error.manageError.changeError(typeOfError: "UserService", error: false)
            }
        }
    }
    
    private func returnTypeOfAccount(uid: String) -> String? {
        var typeOfAcc: String? = nil
        var refHandle = self.ref.child("Users").observe(FIRDataEventType.value, with: { (snapshot) in
            if snapshot.hasChild((uid) + "/License") {
                let usersDict = snapshot.value as! NSDictionary
                // ...
                let userLicense = (usersDict.object(forKey: uid) as AnyObject).object(forKey: "License")
                typeOfAcc = ((userLicense) as AnyObject).object(forKey: "Type") as? String
            }
        })
        return typeOfAcc
    }
    
    func giveImageData() -> Data? {
        if dateOfImage.count > 0 {
            return dateOfImage.removeLast()
        }
        return nil
    }
    
    private var dateOfImage = [Data]()
    
    func loadProfilePictureFromStorage(user: FIRUser) {
        var checkIfLocalPicExist: Bool = false
        if dateOfImage.count > 0 {
            dateOfImage.removeAll()
        }
        Error.manageError.changeError(typeOfError: "UserService", error: nil)
        let profilePicRef = storageRef.child("images"+"/profile pictures"+"/\(user.uid).jpg")
        // Create local filesystem URL
        let localProfilePicURL: NSURL! = NSURL(fileURLWithPath: "file:///local/images/profile picture.jpg")
        // Download to the local filesystem
        let localPicData = NSData(contentsOf: localProfilePicURL as URL)
        if let userPhoto = user.photoURL {
            let onlinePicData = NSData(contentsOf: userPhoto)
            if localPicData == onlinePicData {
                self.dateOfImage.append(localPicData! as Data)
                checkIfLocalPicExist = true
            }
        }
        
        if checkIfLocalPicExist == false {
            let downloadTask = profilePicRef.write(toFile: localProfilePicURL as URL) { (URL, error) -> Void in
                Error.manageError.changeError(typeOfError: "UserService", error: true)
                if (error != nil) {
                    // Uh-oh, an error occurred!
                    print("unable to download the image")
                    Error.manageError.changeError(typeOfError: "UserService", error: false)
                } else {
                    // Local file URL for "images/island.jpg" is returned
                    print("user already has an image, no need to download it from facebook")
                    let data = NSData(contentsOf: URL!)
                    self.dateOfImage.append(data! as Data)
                }
            }
        }
    }
    
    func loadProfilePictureFromFB(user: FIRUser) {
        if dateOfImage.count > 0 {
            dateOfImage.removeAll()
        }
        Error.manageError.changeError(typeOfError: "UserService", error: nil)
        //        let profilePicRef = storageRef.child("images"+"/profile pictures"+"/\(user.uid).jpg")
        let profilePic = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height": 300, "width": 300, "redirect": false], httpMethod: "GET")
        profilePic?.start(completionHandler: {(connection, result, error) -> Void in
            // Handle the result
            if error == nil {
                let dictionary = result as? NSDictionary
                //                        let data = dictionary?.object(forKey: "data")
                //
                //                        let urlPic = ((data as AnyObject).object(forKey: "url"))! as! String
                let urlPic = (dictionary?["data"]! as! [String : AnyObject])["url"] as! String
                if let imageData = try? Data(contentsOf: URL(string: urlPic)!) {
                    Error.manageError.changeError(typeOfError: "UserService", error: true)
                    //                    let uploadTask = profilePicRef.put(imageData, metadata:nil) { metadata,error in
                    //                        if error == nil {
                    //                            //size, content type or the download URL
                    //                            let downloadURL: String = metadata!.downloadURLs![0].absoluteString
                    //
                    //                            let profileURL = NSURL(fileURLWithPath: downloadURL) as URL
                    //                            UserService.userService.authChangeReq(user, displayName: nil, photoURL: profileURL)
                    //
                    //                        } else {
                    //                            print("error in downloading image")
                    //                            Error.manageError.changeError(typeOfError: "UserService", error: false)
                    //                        }
                    //                    }
                    self.changePicture(user: user, imageData: imageData)
                    self.dateOfImage.append(imageData)
                }
            }
            
        })
    }
    
    func getBirthday(uid: String) -> String? {
        var userBirthday: String? = nil
        var refHandle = self.ref.child("Users").observe(FIRDataEventType.value, with: { (snapshot) in
            if snapshot.hasChild(uid + "/Personal information") {
                let usersDict = snapshot.value as! NSDictionary
                // ...
                let userPersonalInformation = (usersDict.object(forKey: uid) as AnyObject).object(forKey: "Personal information")
                userBirthday = (userPersonalInformation as AnyObject).object(forKey: "Birthday") as? String
            }
        })
        return userBirthday
    }
    
}
