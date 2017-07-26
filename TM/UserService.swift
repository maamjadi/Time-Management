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
    
    private let mainPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    fileprivate let ref = FIRDatabase.database().reference()
    fileprivate let storageRef = FIRStorage.storage().reference()
    // Create a storage reference from our storage service
    
    
    func signUp(_ name: String, email: String, pass: String, imageData: Data , afterSignUp : AfterAsynchronous) {
        Error.manageError.changeError(typeOfError: "UserService", error: nil)
        FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user , error) in
            Error.manageError.changeError(typeOfError: "UserService", error: true)
            if error != nil {
                print(error?.localizedDescription ?? "error")
                Error.manageError.changeError(typeOfError: "UserService", error: false)
                afterSignUp.onFinish()
                return
            } else {
                if let user = FIRAuth.auth()?.currentUser {
                    self.initialLicense(user)
                    self.authChangeReq(user, displayName: name, photoURL: nil)
                    UserService.userService.changePicture(user: user, imageData: imageData)
                    let checkError = Error.manageError.giveError(typeOfError: "UserService")
                    if checkError == false {
                        Error.manageError.changeError(typeOfError: "UserService", error: false)
                    }
                    afterSignUp.onFinish()
                    return
                }
            }
        })
    }
    
    func signIn(_ method: String, email: String?, pass: String? , afterSignIn: AfterAsynchronous) {
        Error.manageError.changeError(typeOfError: "UserService", error: nil)
        switch method {
            
        case "Email":
            FIRAuth.auth()?.signIn(withEmail: email!, password: pass!, completion: { (user, error) in
                if error != nil {
                    Error.manageError.changeError(typeOfError: "UserService", error: false)
                    afterSignIn.onFinish()
                    return
                } else {
                    Error.manageError.changeError(typeOfError: "UserService", error: true)
                    afterSignIn.onFinish()
                    return
                }
            })
            
        case "Facebook":
            let login: FBSDKLoginManager = FBSDKLoginManager()
            login.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], handler: { (result, error) -> Void in
                Error.manageError.changeError(typeOfError: "UserService", error: true)
                if error != nil {
                    Error.manageError.changeError(typeOfError: "UserService", error: false)
                    afterSignIn.onFinish()
                    return
                }
                else if (result?.isCancelled)! {
                    Error.manageError.changeError(typeOfError: "UserService", error: false)
                    afterSignIn.onFinish()
                    return
                }
                else {
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                        if error == nil {
                            print("You have been loged in")
                            self.initialLicense(user!)
                            afterSignIn.onFinish()
                            return
                            
                        } else {
                            Error.manageError.changeError(typeOfError: "UserService", error: false)
                            afterSignIn.onFinish()
                            return
                        }
                    }
                }
            })
            
        default: break
        }
    }
    
    private func authChangeReq(_ user: FIRUser, displayName: String?, photoURL: URL?) {
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
    
    func initialLicense(_ user: FIRUser) {
        _ = self.ref.child("Users").observe(FIRDataEventType.value, with: { (snapshot) in
            if !(snapshot.hasChild((user.uid) + "/License")) {
                self.ref.child("Users").child(user.uid).child("License/Type").setValue("free")
                self.ref.child("Users").child(user.uid).child("License/Date of creation").setValue(FIRServerValue.timestamp())
            }
        })
    }
    
    func updateNamePicture(user: FIRUser, imageData: Data, updateName: String?) {
        changePicture(user: user, imageData: imageData)
        self.authChangeReq(user, displayName: updateName, photoURL: nil)
    }
    
    private func changePicture(user: FIRUser, imageData: Data) {
        let profilePicRef = self.storageRef.child("images"+"/profile pictures"+"/\(user.uid).jpg")
        _ = profilePicRef.put(imageData, metadata:nil) { metadata,error in
            if error == nil {
                //size, content type or the download URL
                let downloadURL: String = metadata!.downloadURLs![0].absoluteString
                let profileURL = NSURL(fileURLWithPath: downloadURL) as URL
                self.authChangeReq(user, displayName: nil, photoURL: profileURL)
            } else {
                print("error in uploading the image")
                Error.manageError.changeError(typeOfError: "UserService", error: false)
            }
        }
    }
    
    private func returnTypeOfAccount(uid: String) -> String? {
        var typeOfAcc: String? = nil
        _ = self.ref.child("Users").observe(FIRDataEventType.value, with: { (snapshot) in
            if snapshot.hasChild((uid) + "/License") {
                let usersDict = snapshot.value as! NSDictionary
                // ...
                let userLicense = (usersDict.object(forKey: uid) as AnyObject).object(forKey: "License")
                typeOfAcc = ((userLicense) as AnyObject).object(forKey: "Type") as? String
            }
        })
        return typeOfAcc
    }
    
    private var dateOfImage: Data? = nil
    
    func giveImageData() -> Data? {
        return dateOfImage
    }
    
    func loadProfilePictureFromStorage(user: FIRUser , afterLoadingThePiture : AfterAsynchronous) {
        var checkIfLocalPicExist: Bool = false
        Error.manageError.changeError(typeOfError: "UserService", error: nil)
        let profilePicRef = storageRef.child("images"+"/profile pictures"+"/\(user.uid).jpg")
        // Create local filesystem URL
        //let localProfilePicURL: NSURL! = NSURL(fileURLWithPath: "file:///local/images/profile picture.jpg")
        let documentsDirectory = mainPath + "/User"
        let filePath = "file:\(documentsDirectory)/profilePicture.jpg"
        guard let localProfilePicURL = URL.init(string: filePath) else { return }
        // Download to the local filesystem
        if let localPicData = NSData(contentsOf: localProfilePicURL as URL) {
            if let userPhoto = user.photoURL {
                let onlinePicData = NSData(contentsOf: userPhoto)
                if localPicData == onlinePicData {
                    self.dateOfImage = localPicData as Data
                    checkIfLocalPicExist = true
                    Error.manageError.changeError(typeOfError: "UserService", error: true)
                }
            }
        }
        
        if checkIfLocalPicExist == false {
            _ = profilePicRef.write(toFile: localProfilePicURL as URL) { (URL, error) -> Void in
                Error.manageError.changeError(typeOfError: "UserService", error: true)
                if (error != nil) {
                    // Uh-oh, an error occurred!
                    print("unable to download the image")
                    Error.manageError.changeError(typeOfError: "UserService", error: false)
                    self.loadProfilePictureFromFB(user: user, afterLoadingThePiture: afterLoadingThePiture)
                } else {
                    // Local file URL for "images/island.jpg" is returned
                    print("user already has an image, no need to download it from facebook")
                    let data = NSData(contentsOf: URL!)
                    self.dateOfImage = data! as Data
                    afterLoadingThePiture.onFinish();
                    return
                }
            }
        }
        
    }
    
    func loadProfilePictureFromFB(user: FIRUser, afterLoadingThePiture : AfterAsynchronous) {
        Error.manageError.changeError(typeOfError: "UserService", error: nil)
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
                    self.changePicture(user: user, imageData: imageData)
                    self.dateOfImage = imageData
                    print("FB profile picture imported to FIR")
                    afterLoadingThePiture.onFinish();
                    return
                }
            } else {
                Error.manageError.changeError(typeOfError: "UserService", error: false)
                afterLoadingThePiture.onFinish();
                return
            }
            
        })
        
    }
    
    func getBirthday(uid: String) -> String? {
        var userBirthday: String? = nil
        _ = self.ref.child("Users").observe(FIRDataEventType.value, with: { (snapshot) in
            if snapshot.hasChild(uid + "/Personal information") {
                let usersDict = snapshot.value as! NSDictionary
                // ...
                let userPersonalInformation = (usersDict.object(forKey: uid) as AnyObject).object(forKey: "Personal information")
                userBirthday = (userPersonalInformation as AnyObject).object(forKey: "Birthday") as? String
            }
        })
        return userBirthday
    }
    
    func createDirectory() {
        let documentDirectoryPath = mainPath + "/User"
        var objeCtBool: ObjCBool = true
        let dirExist = FileManager.default.fileExists(atPath: documentDirectoryPath, isDirectory: &objeCtBool)
        if dirExist == false {
            do {
                try FileManager.default.createDirectory(atPath: documentDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
}
