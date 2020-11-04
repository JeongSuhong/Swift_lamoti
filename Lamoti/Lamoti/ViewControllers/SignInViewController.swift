//
//  SignInViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/11/03.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
     @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
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
        
    }

    @IBAction func signIn(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { (result, error) in
            let userId = result?.user.uid
            Database.database().reference().child("users/\(userId)/username").setValue(self.nameText.text)

        }
    }
    
    @IBAction func cancelSignIn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
