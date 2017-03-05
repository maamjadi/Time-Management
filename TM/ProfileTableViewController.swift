//
//  ProfileTableViewController.swift
//
//
//  Created by Amin Amjadi on 8/8/16.
//
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ProfileTableViewController: UITableViewController {
    
    
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPassTextField: UITextField!
    
    let imagePicker = UIImagePickerController()
    var selectedPhoto: UIImage! = UIImage(named: "profile pic")! //we have changed it from UIImage!(nil) to this cz of error for swift 3
    var successfullyUpdated: Bool = false
    
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = .black
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                
            }
            else {
                // No user is signed in.
                self.giveAnAlert("Ops... There is no User")
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }
        }
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.clipsToBounds = true
        self.profileImage.isUserInteractionEnabled = true
        
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.selectPhoto(_:)))
        profileImage.addGestureRecognizer(tapRecognizer)
        
        tapDismissGesture()
        
        
        // User is signed in.
        let name = user?.displayName
        let email = user?.email
        
        self.emailTextField.text = email
        self.nameTextField.text = name
        
        UserService.userService.loadProfilePictureFromStorage(user: user!)
        let loadPic = Error.manageError.giveError(typeOfError: "UserService")
        if loadPic == true {
//            let imageData = UserService.userService.giveImageData()
//            if imageData != nil {
//                profileImage.image = UIImage(data: imageData!)
//                profileImage.isHidden = false
//            } else {
//                profileImage.isHidden = true
//            }
        }
        
        if let userBirthday = UserService.userService.getBirthday(uid: (user?.uid)!) {
            birthdayTextField.text = userBirthday
        }
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
    
    
    
    @IBAction func timeTextFieldEditingBegin(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    func datePickerValueChanged(_ sender:UIDatePicker) {
        //This will update textfields text with value of datepicker
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        birthdayTextField.text = dateFormatter.string(from: sender.date)
        
    }
    
    @IBAction func updateProfile() {
        
        if successfullyUpdated == false {
            self.successfullyUpdated = true
            if let email = self.emailTextField.text , email != ""{
                self.user?.updateEmail(email) { error in
                    if error != nil {
                        // An error happened.
                        let alertControll = UIAlertController(title: "Alert", message: "Please enter valid email address!", preferredStyle: .alert)
                        alertControll.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                        
                        self.present(alertControll, animated: true, completion: nil)
                        self.successfullyUpdated = false
                    } else {
                        // Email updated.
                    }
                }
            }
            
            if let newPassword = self.passwordTextField.text , !(newPassword.isEmpty) {
                if newPassword == verifyPassTextField.text {
                    self.user?.updatePassword(newPassword) { error in
                        if error != nil {
                            // An error happened.
                            
                            let alertControll = UIAlertController(title: "Alert", message: "Password must be at least 6 digits!", preferredStyle: .alert)
                            alertControll.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                            
                            self.present(alertControll, animated: true, completion: nil)
                            self.successfullyUpdated = false
                        } else {
                            // Password updated.
                        }
                    }
                } else {
                    let alertController = UIAlertController(title: "Warning", message: "Your passwords doesn't match", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    self.successfullyUpdated = false
                }
            }
            
            if let user = user {
                let changeRequest = user.profileChangeRequest()
                
                if self.nameTextField.text != nil {
                    changeRequest.displayName = self.nameTextField.text
                }
                let image = UIImage(named: "profile pic")
                if profileImage.image != image {
                    let data: Data = UIImageJPEGRepresentation(self.profileImage.image!, 1)!
                    if let userPhoto = user.photoURL {
                        let localProfilePicURL: NSURL! = NSURL(fileURLWithPath: "file:///local/images/profile picture.jpg")
                        let currentPhoto = NSData(contentsOf: localProfilePicURL as URL)
                        let userPhotoData = NSData(contentsOf: userPhoto)
                        if userPhotoData != currentPhoto {
                            UserService.userService.changePicture(user: user, imageData: data)
                        }
                    }
                }
            }
            
            if let birthday = birthdayTextField.text , birthday != "" {
                self.ref.child("Users").child(user!.uid).child("Personal information/Birthday").setValue(birthday)
            }
        } else {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainView = mainStoryboard.instantiateViewController(withIdentifier: "mainView")
            
            self.present(mainView, animated: true, completion: nil)
        }
    }
    
    
    
}

extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //imagePicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage
        self.profileImage.image = selectedPhoto
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
