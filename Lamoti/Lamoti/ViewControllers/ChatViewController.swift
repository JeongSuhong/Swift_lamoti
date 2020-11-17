//
//  ChatViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/11/15.
//

import UIKit
import Firebase

class ChatViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public var destinationUid : String?
    var uid : String?
    var chatRoomUid : String?
    var comments : [ChatModel.Comment] = []
    
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        uid = Auth.auth().currentUser?.uid
        checkChatRoom()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let view = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        view.textLabel?.text = self.comments[indexPath.row].message
         
        return view
    }

    func createRoom() {
        let createRoomInfo : Dictionary<String,Any> = [ "users" : [
                uid: true,
                destinationUid: true
            ]
        ]
        
        if(chatRoomUid == nil) {
            self.sendButton.isEnabled = false
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo) { (error, reference) in
                if (error == nil) {
                    self.checkChatRoom()
                }
            }
        } else {
            let value : Dictionary<String,Any> = [
            "uid": uid!,
                "message": messageText.text!
            ]
            Database.database().reference().child("chatrooms").child(chatRoomUid!) .child("comments").childByAutoId().setValue(value)
        }
    }
    
    func checkChatRoom() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                
                if let chatRoomdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    if (chatModel?.users[self.destinationUid!] == true) {
                        self.chatRoomUid = item.key
                        self.sendButton.isEnabled = true
                        self.getMessageList()
                    }
                }
            }
        }
    }
    
    func getMessageList() {
        Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments").observe(DataEventType.value) { (datasnapshot) in
            self.comments.removeAll()
            
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                self.comments.append(comment!)
            }
            
            self.tableView.reloadData()
            
        }
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        createRoom()
    }
}
