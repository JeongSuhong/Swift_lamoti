//
//  SignInViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/11/03.
//

import UIKit
import Firebase

class SignInViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
     @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    
    let remoteConfig = RemoteConfig.remoteConfig()

    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (m) in
            m.top.left.right.equalTo(self.view)
            m.height.equalTo(20)
        }
        statusBar.backgroundColor = UIColor.gray
        
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPhoto(recognizer:))))
        
    }
    
    @objc func selectPhoto(recognizer: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        profileImage.image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        dismiss(animated: true, completion: nil)
    }

    @IBAction func signIn(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { (result, error) in
            let userId = result?.user.uid

            Database.database().reference().child("users/\(userId!)/username").setValue(self.nameText.text)
            
            let image = self.profileImage.image!.jpegData(compressionQuality: 0.1)
            let riverRef = Storage.storage().reference().child("userImage/\(userId!)")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let uploadTask = riverRef.putData(image!, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata else { return }
            }
            
            // URL 저장이 안됨.
            riverRef.downloadURL{ (url, error) in
                guard let downloadURL = url else { return }
                Database.database().reference().child("users/\(userId!)/profileImageUrl").setValue(downloadURL)
            }
        }
    }
    
    @IBAction func cancelSignIn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

