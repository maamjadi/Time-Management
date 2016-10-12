//
//  UserService.swift
//  Authentication
//
//  Created by Amin Amjadi on 9/7/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FBSDKLoginKit

class UserService {
    
    var manageError = Error()
    
    static let userService = UserService()
    
    fileprivate let ref = FIRDatabase.database().reference()
    fileprivate let storageRef = FIRStorage.storage().reference()
    // Create a storage reference from our storage service
    
    
    func signUp(_ name: String, email: String, pass: String, imageData: Data) {
        //        UserService.error.checkError = nil
        manageError.changeError(typeOfError: "UserService", error: nil)
        FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user , error) in
            //            UserService.error.checkError = true
            self.manageError.changeError(typeOfError: "UserService", error: true)
            if error != nil {
                print(error?.localizedDescription)
                //                UserService.error.checkError = false
                self.manageError.changeError(typeOfError: "UserService", error: false)
                return
            } else {
                if let user = FIRAuth.auth()?.currentUser {
                    let profilePicRef = self.storageRef.child("images"+"/Profile pictures"+"/\(user.uid).jpg")
                    self.ref.child("Users").child(user.uid).child("Licence/Type").setValue("free")
                    self.ref.child("Users").child(user.uid).child("Licence/Date of creation").setValue(FIRServerValue.timestamp())
                    let changeRequest = user.profileChangeRequest()
                    changeRequest.displayName = name
                    changeRequest.commitChanges { error in
                        if let error = error {
                            // An error happened.
                            //                            UserService.error.checkError = false
                            self.manageError.changeError(typeOfError: "UserService", error: false)
                            return
                        } else {
                            // Profile updated.
                        }
                    }
                    let uploadTask = profilePicRef.put(imageData, metadata:nil) { metadata,error in
                        if error == nil {
                            //size, content type or the download URL
                            let downloadURL: String = metadata!.downloadURLs![0].absoluteString
                            let changeRequest = user.profileChangeRequest()
                            changeRequest.photoURL = NSURL(fileURLWithPath: downloadURL) as URL
                            changeRequest.commitChanges { error in
                                if let error = error {
                                    // An error happened.
                                    print(error.localizedDescription)
                                    //                                    UserService.error.checkError = false
                                    self.manageError.changeError(typeOfError: "UserService", error: false)
                                    return
                                } else {
                                    // Profile updated.
                                }
                            }
                        } else {
                            print("error in uploading the image")
                            //                            UserService.error.checkError = false
                            self.manageError.changeError(typeOfError: "UserService", error: false)
                            return
                        }
                    }
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.login()
                }
            }
        })
    }
    
    func signIn(_ method: String, email: String?, pass: String?) {
        //        UserService.error.checkError = nil
        manageError.changeError(typeOfError: "UserService", error: nil)
        switch method {
            
        case "Email":
            FIRAuth.auth()?.signIn(withEmail: email!, password: pass!, completion: { (user, error) in
                self.manageError.changeError(typeOfError: "UserService", error: true)
                if error != nil {
                    self.manageError.changeError(typeOfError: "UserService", error: false)
                    return
                } else {
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.login()
                }
            })
            
        case "Facebook":
            let login: FBSDKLoginManager = FBSDKLoginManager()
            login.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], handler: { (result, error) -> Void in
                self.manageError.changeError(typeOfError: "UserService", error: true)
                if error != nil {
                    self.manageError.changeError(typeOfError: "UserService", error: false)
                    return
                }
                else if (result?.isCancelled)! {
                    self.manageError.changeError(typeOfError: "UserService", error: false)
                    return
                }
                else {
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                        if error == nil {
                            print("You have been loged in")
                            var refHandle = self.ref.child("Users").observe(FIRDataEventType.value, with: { (snapshot) in
                                if !(snapshot.hasChild((user?.uid)! + "/Licence")) {
                                    self.ref.child("Users").child((user?.uid)!).child("Licence/Type").setValue("free")
                                    self.ref.child("Users").child((user?.uid)!).child("Licence/Date of creation").setValue(FIRServerValue.timestamp())
                                }
                            })
                            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.login()

                        } else {
                            //                            UserService.error.checkError = false
                            self.manageError.changeError(typeOfError: "UserService", error: false)
                            return
                        }
                    }
                }
            })
            
        //        case "Google":
        default: break
        }
    }
    
    private func returnTypeOfAccount(uid: String) -> String? {
        var typeOfAcc: String? = nil
        var refHandle = self.ref.child("Users").observe(FIRDataEventType.value, with: { (snapshot) in
            if snapshot.hasChild((uid) + "/Licence") {
                let usersDict = snapshot.value as! NSDictionary
                // ...
                let userPersonalInformation = (usersDict.object(forKey: uid) as AnyObject).object(forKey: "Licence")
                typeOfAcc = ((userPersonalInformation) as AnyObject).object(forKey: "Type") as? String
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
    
    func loadProfilePictureFromStorage(uid: String) {
        if dateOfImage.count > 0 {
            dateOfImage.removeAll()
        }
        manageError.changeError(typeOfError: "UserService", error: nil)
        let profilePicRef = storageRef.child("images"+"/profile pictures"+"/\(uid).jpg")
        // Create local filesystem URL
        let localProfilePicURL: NSURL! = NSURL(fileURLWithPath: "file:///local/images/profile picture.jpg")
        // Download to the local filesystem
        let downloadTask = profilePicRef.write(toFile: localProfilePicURL as URL) { (URL, error) -> Void in
            self.manageError.changeError(typeOfError: "UserService", error: true)
            if (error != nil) {
                // Uh-oh, an error occurred!
                print("unable to download the image")
                self.manageError.changeError(typeOfError: "UserService", error: false)
            } else {
                // Local file URL for "images/island.jpg" is returned
                print("user already has an image, no need to download it from facebook")
                let data = NSData(contentsOf: URL!)
                self.dateOfImage.append(data! as Data)
            }
        }
    }
    func loadProfilePictureFromFB(uid: String) {
        if dateOfImage.count > 0 {
            dateOfImage.removeAll()
        }
        manageError.changeError(typeOfError: "UserService", error: nil)
        let profilePicRef = storageRef.child("images"+"/profile pictures"+"/\(uid).jpg")
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
                    self.manageError.changeError(typeOfError: "UserService", error: true)
                    let uploadTask = profilePicRef.put(imageData, metadata:nil) { metadata,error in
                        if error == nil {
                            //size, content type or the download URL
                            let downloadURL = metadata!.downloadURL
                        } else {
                            print("error in downloading image")
                            self.manageError.changeError(typeOfError: "UserService", error: false)
                        }
                    }
                    self.dateOfImage.append(imageData)
                }
            }
            
        })
    }
    
}
