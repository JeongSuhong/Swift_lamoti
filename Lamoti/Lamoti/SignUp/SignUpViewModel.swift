//
//  SignUpViewModel.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/12/24.
//

import Firebase


protocol SignUpProtocol {
    func successEvent()
    func failedEvent(_ error: NSError)
}

class SignUpViewModel {
    
    private var delegate : SignUpProtocol?
    
    func startCreateUser(email: String, password: String, name: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in

            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = name
            changeRequest?.commitChanges(completion: { (error) in
                if error != nil {
                    self.delegate?.failedEvent(error! as NSError)
                }
            })
            
            self.updateUserData(name: name)
            
            }
    }
    
    func updateUserData(name: String) {
        
        let uid = UserManager.instance.currentUid
        let userData = NSDictionary(dictionary:["name": name, "uid": uid])
                Database.database().reference().child("users").child(uid!).setValue(userData) { (error, reference) in
                    if error == nil {
              
                    }
                }
    }
    
}
