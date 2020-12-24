//
//  SignInViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/11/03.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    

    @IBAction func signIn(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { (result, error) in
            let userId = result?.user.uid

            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = self.nameText.text
            changeRequest?.commitChanges(completion: { (error) in
                if error != nil {
                    print("Erorr Update DisplayName : \(error)")
                }
            })
            
                    let userData = NSDictionary(dictionary:["name":self.nameText.text, "uid":Auth.auth().currentUser?.uid])
                    Database.database().reference().child("users").child(userId!).setValue(userData) { (error, reference) in
                        if error == nil {
                            self.closeVC()
                        }
                    }
            }
        }
    
    func closeVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelSignIn(_ sender: Any) {
        closeVC()
    }
}

