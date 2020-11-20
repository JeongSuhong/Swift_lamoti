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
    var userModel : UserModel?
    
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
        
        if (self.comments[indexPath.row].uid == uid) {
        let view = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            view.messageText?.text = self.comments[indexPath.row].message
            view.messageText.numberOfLines = 0
            return view
        } else {
            let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.nameText.text = userModel?.name
            view.messageText.text = self.comments[indexPath.row].message
            view.messageText.numberOfLines = 0
            
            let url = URL(string: (self.userModel?.profileImageUrl)!)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                DispatchQueue.main.async {
                    view.profileImage.image = UIImage(data: data!)
                    view.profileImage.layer.cornerRadius = view.profileImage.frame.width / 2
                    view.profileImage.clipsToBounds = true
                }
            }.resume()
        return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
                        self.getDestinationInfo()
                        
                    }
                }
            }
        }
    }
    
    func getDestinationInfo() {
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            self.userModel = UserModel()
            self.userModel?.setValuesForKeys(datasnapshot.value as! [String:Any])
            self.getMessageList()
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


class MyMessageCell : UITableViewCell {
    
    @IBOutlet weak var messageText: UILabel!
}

class DestinationMessageCell : UITableViewCell {
    
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameText: UILabel!
    
}
