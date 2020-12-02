//
//  ChatViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/11/15.
//

import UIKit
import Firebase
import Alamofire

class ChatViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public var destinationUid : String?
    var uid : String?
    var chatRoomUid : String?
    var comments : [ChatModel.Comment] = []
    var destinationUserModel : UserModel?
    
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        uid = Auth.auth().currentUser?.uid
        checkChatRoom()
        
        self.tabBarController?.tabBar.isHidden = true
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (self.comments[indexPath.row].uid == uid) {
        let view = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            view.messageText?.text = self.comments[indexPath.row].message
            view.messageText.numberOfLines = 0
            
            if let time = self.comments[indexPath.row].time {
                view.timeText.text = time.toDayTime
            }
            
            return view
        } else {
            let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.nameText.text = destinationUserModel?.name
            view.messageText.text = self.comments[indexPath.row].message
            view.messageText.numberOfLines = 0
        
            let url = URL(string: (self.destinationUserModel?.profileImageUrl)!)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                DispatchQueue.main.async {
                    view.profileImage.image = UIImage(data: data!)
                    view.profileImage.layer.cornerRadius = view.profileImage.frame.width / 2
                    view.profileImage.clipsToBounds = true
                }
            }.resume()
            
            if let time = self.comments[indexPath.row].time {
                view.timeText.text = time.toDayTime
            }
            
            
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
                "message": messageText.text!,
                "time": ServerValue.timestamp()
            ]
            Database.database().reference().child("chatrooms").child(chatRoomUid!) .child("comments").childByAutoId().setValue(value) { (error, reference) in
                self.messageText.text = ""
            }
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
            self.destinationUserModel = UserModel()
            self.destinationUserModel?.setValuesForKeys(datasnapshot.value as! [String:Any])
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
            
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    func sendGcm() {
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.sendBottomConstraint.constant = keyboardSize.height
        }
        
        UIView.animate(withDuration: 0, animations: {
            // setNeedsLayout() -> 다음 updateCycle & layoutIfNeeded() -> 즉시 (실행 차이가 있다.)
            self.view.layoutIfNeeded()
        }, completion: {
            (complete) in
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: .bottom, animated: true)
            }
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.sendBottomConstraint.constant = 20
        self.view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        createRoom()
    }
}


extension Int {
    var toDayTime : String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        
        let date = Date(timeIntervalSince1970: Double(self) / 1000)
        
        return dateFormatter.string(from: date)
    }
}

class MyMessageCell : UITableViewCell {
    
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var timeText: UILabel!
    
}

class DestinationMessageCell : UITableViewCell {
    
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var timeText: UILabel!
    
}
