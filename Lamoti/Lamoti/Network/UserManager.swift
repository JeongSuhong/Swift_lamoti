//
//  UserManager.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/12/22.
//

import Firebase

class UserManager {
    
    static let instance = UserManager()
    
    var currentUid:  String? { get { return _currentUid } }
    private var _currentUid : String?
    
    var checkAutoLogin : Bool = false
    
    private init() {
        setCurrentUid()
    }
    
    private func setCurrentUid() {
        _currentUid = Auth.auth().currentUser?.uid
    }
}
