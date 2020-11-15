//
//  ChatViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/11/15.
//

import UIKit
import Firebase

class ChatViewController : UIViewController {
    
    public var destinationUid : String?
    
    @IBOutlet weak var sendButton: UIButton!
    
    

    func createRoom() {
        let createRoomInfo = [
            "uid" : Auth.auth().currentUser?.uid,
            "destinationUid" : destinationUid
        ]
        
        Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        createRoom()
    }
}
