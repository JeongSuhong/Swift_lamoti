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
    @IBOutlet weak var viewPasswordButton: UIButton!
    
    private var vm : LoginViewModel?

    
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm = LoginViewModel()
        vm?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        vm?.delegate = nil
        vm = nil
    }

    @IBAction func loginEvent(_ sender: UIButton) {
        vm?.startLogin(email: emailText.text, password: passwordText.text)
    }
    
    @IBAction func presentSignIn(_ sender: UIButton) {
        let view = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        view.modalPresentationStyle = .overFullScreen
        self.present(view, animated: true)
    }
}



extension LoginViewController : LoginProtocol {
    
    func successEvent() {
    }
    
    func failedEvent(_ error: NSError) {
        
        var message : String?
        
        switch AuthErrorCode(rawValue: error.code) {
        case .networkError:
            message = "네트워크 문제로 서비스 접속에 실패했습니다.\n네트워크 연결을 확인한 후 다시 이용해 주세요."
        case .invalidEmail:
            message = "이메일 형식에 맞지 않는 메일주소입니다.\n다시 입력해주시기 바랍니다."
        case .wrongPassword:
            message = "등록되지 않은 아이디이거나 아이디 또는 비밀번호를 잘못 입력했습니다"
        default:
            message = "일시적인 오류로 로그인을 할 수 없습니다.\n잠시 후 다시 이용해 주시기 바랍니다."
        }
        
        let alert = UIAlertController(title: "로그인 실패", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
