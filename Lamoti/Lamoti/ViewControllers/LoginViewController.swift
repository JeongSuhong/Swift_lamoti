//
//  LoginViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/10/29.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 에러 핸들링. try! -> Error 가 절대로 발생하지 않을경우 사용
        try! Auth.auth().signOut()
        
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (m) in
            m.top.left.right.equalTo(self.view)
            m.height.equalTo(20)
        }
        statusBar.backgroundColor = UIColor.gray
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user != nil) {
                let view = self.storyboard?.instantiateViewController(identifier: "MainTabBarController") as! MainTabBarController
                view.modalPresentationStyle = .fullScreen
                self.present(view, animated: true, completion: nil)
            }
        }
        
    }

    @IBAction func loginEvent(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { (result, error) in
            if(error != nil) {
                let alert = UIAlertController(title: "로그인 실패", message: error.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
    
            
        }
        
    }
    
    @IBAction func presentSignIn(_ sender: UIButton) {
        let view = self.storyboard?.instantiateViewController(identifier: "SignInViewController") as! SignInViewController
        view.modalPresentationStyle = .fullScreen
        self.present(view, animated: true, completion: nil)
    }
}
