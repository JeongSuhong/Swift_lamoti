//
//  LoginView.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/12/22.
//

import Firebase

protocol LoginProtocol {
    func LoginSuccess()
    func LoginFailed()
}

class LoginViewModel {
    
    
    
    
    func startLogin(email: String, password: String) {
        Auth.auth().addStateDidChangeListener(<#T##listener: (Auth, User?) -> Void##(Auth, User?) -> Void#>)
    }
    
}
