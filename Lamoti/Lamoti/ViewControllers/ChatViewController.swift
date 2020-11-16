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
    var uid : String?
    var chatRoomUid : String?
    
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        checkChatRoom()
    }

    func createRoom() {
        let createRoomInfo : Dictionary<String,Any> = [ "users" : [
                uid: true,
                destinationUid: true
            ]
        ]
        
        if(chatRoomUid == nil) {
        Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo)
        } else {
            let value : Dictionary<String,Any> = [
            "comments": [
            "uid": uid!,
                "message": messageText.text!
            ]]
            Database.database().reference().child("chatrooms").child(chatRoomUid!) .child("comments").childByAutoId().setValue(value)
        }
    }
    
    func checkChatRoom() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                self.chatRoomUid = item.key
            }
        }
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        createRoom()
    }
}
