//
//  LoginView.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/12/22.
//

import Firebase

protocol LoginProtocol {
    func successEvent()
    func failedEvent(_ error: NSError)
}

class LoginViewModel {
    
    private var listenerHandle : AuthStateDidChangeListenerHandle?
    
    var delegate : LoginProtocol?
    
    func startLogin(email: String?, password: String?) {
        self.listenerHandle = Auth.auth().addStateDidChangeListener(loginChangeState)
        
        Auth.auth().signIn(withEmail: email!, password: password!) { (result, error) in
            if(error != nil) {
                self.failedLogin(error! as NSError)
            }
        }
    }
    
    func successLogin() {
        let uid = Auth.auth().currentUser?.uid
        Messaging.messaging().token { (token, error) in
            
            if error != nil {
                
            let data = NSDictionary(dictionary: ["pushToken":token!])
            Database.database().reference().child("users").child(uid!).updateChildValues(data as! [AnyHashable : Any])
                
                Auth.auth().removeStateDidChangeListener(self.listenerHandle!)
                self.delegate?.successEvent()
            } else {
                self.failedLogin(error! as NSError)
            }
        }
    }
    
    func failedLogin(_ error: NSError) {
        
        Auth.auth().removeStateDidChangeListener(self.listenerHandle!)
        self.delegate?.failedEvent(error)
    }
    
    
    func loginChangeState(auth: Auth, user: User?) {
        if(user != nil) {
            successLogin()
        }
    }
    
}
