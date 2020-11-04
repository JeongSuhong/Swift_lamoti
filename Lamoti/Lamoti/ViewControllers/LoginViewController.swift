//
//  LoginViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/10/29.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    
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
    
    @IBAction func presentSignIn(_ sender: UIButton) {
        let view = self.storyboard?.instantiateViewController(identifier: "SignInViewController") as! SignInViewController
        view.modalPresentationStyle = .fullScreen
        self.present(view, animated: true, completion: nil)
    }
}
