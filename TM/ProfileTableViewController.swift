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

class ProfileTableViewController: UITableViewController, AfterAsynchronous {
    
    
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPassTextField: UITextField!
    @IBOutlet var loadingEffect: UIVisualEffectView!
    
    let imagePicker = UIImagePickerController()
    var selectedPhoto: UIImage! = UIImage(named: "profile pic")! //we have changed it from UIImage!(nil) to this cz of error for swift 3
    var successfullyUpdated: Bool = false
    var updateEmailAsyncProccess: Bool = false
    var updatePassAsyncProccess: Bool = false
    
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
                self.giveAnAlert("Ops... There is no User", alertControllerTitle: "Warning")
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }
        }
        verifyPassTextField.isEnabled = false
        passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
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
        
        UserService.userService.loadProfilePictureFromStorage(user: user! , afterLoadingThePiture : self)
        
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
        }
        alertController.addAction(photoLibraryAction)
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
    
    func updateManualFirstP() {
        if successfullyUpdated == true {
        if let newPassword = self.passwordTextField.text , !(newPassword.isEmpty) {
            if newPassword == verifyPassTextField.text {
                updatePassAsyncProccess = true
                self.user?.updatePassword(newPassword) { error in
                    if error != nil {
                        // An error happened.
                        self.giveAnAlert("Password must be at least 6 digits!", alertControllerTitle: "Alert")
                        self.successfullyUpdated = false
                        self.updateManualSecP()
                        return
                    } else {
                        // Password updated.
                        print("password updated:" + newPassword)
                        self.updateManualSecP()
                        return
                    }
                }
            } else {
                self.giveAnAlert("Your passwords doesn't match", alertControllerTitle: "Warning")
                self.successfullyUpdated = false
            }
        }
        if updatePassAsyncProccess == false {
            updateManualSecP()
        }
        }
    }
    
    func updateManualSecP() {
        savingProcessFinished()
        if successfullyUpdated == true {
        if let user = user {
            let image = UIImage(named: "profile pic")
            if profileImage.image != image {
                var data = Data()
                let userName = self.nameTextField.text
                data = UIImageJPEGRepresentation(profileImage.image!, 0.1)!
                UserService.userService.updateNamePicture(user: user, imageData: data, updateName: userName)
                print("picture and name Updated")
            }
        
        }
        
        if let birthday = birthdayTextField.text , birthday != "" {
            self.ref.child("Users").child(user!.uid).child("Personal information/Birthday").setValue(birthday)
        }
        saveButtonAction()
    }
    }
    
    @IBAction func updateProfile() {
        savingInProccess()
        if successfullyUpdated == false {
            self.successfullyUpdated = true
            updateEmailAsyncProccess = false
            updatePassAsyncProccess = false
            if let email = self.emailTextField.text , email != ""{
                updateEmailAsyncProccess = true
                self.user?.updateEmail(email) { error in
                    if error != nil {
                        // An error happened.
                        self.giveAnAlert("Please enter valid email address!", alertControllerTitle: "Alert")
                        self.successfullyUpdated = false
                        self.updateManualFirstP()
                        return
                    } else {
                        // Email updated.
                        print("Email updated:" + email)
                        self.updateManualFirstP()
                        return
                    }
                }
            }
            if updateEmailAsyncProccess ==  false {
                self.updateManualFirstP()
            }
        }
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
    
    func saveButtonAction() {
        if successfullyUpdated == true {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func savingInProccess() {
        self.view.addSubview(loadingEffect)
        let viewHeight = self.view.bounds.size.height
        let viewWidth = self.view.bounds.size.width
        /*let orientation = UIDevice.current.orientation
         
         if orientation == .landscapeLeft || orientation == .landscapeRight {
         viewHeight = self.view.frame.size.width
         viewWidth = self.view.frame.size.height
         }*/
        
        loadingEffect.frame.size.height = viewHeight
        loadingEffect.frame.size.width = viewWidth
        loadingEffect.center = self.view.center
        navigationController?.isNavigationBarHidden = true
        loadingEffect.fadeIn(sizeTransformation: false)
    }
    
    func savingProcessFinished() {
        loadingEffect.fadeOut(sizeTransformation: false)
        navigationController?.isNavigationBarHidden = false
        loadingEffect.removeFromSuperview()
    }

    
    func onFinish() {
        
        let loadPic = Error.manageError.giveError(typeOfError: "UserService")
        if loadPic == true {
            let imageData = UserService.userService.giveImageData()
            profileImage.image = UIImage(data: imageData!)
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
