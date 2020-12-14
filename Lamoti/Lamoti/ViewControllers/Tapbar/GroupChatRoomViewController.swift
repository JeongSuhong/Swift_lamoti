//
//  GroupChatRoomViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/12/10.
//

import UIKit
import Firebase
import Alamofire

class GroupChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var destinationRoom : String?
    var uid : String?
    var comments : [ChatModel.Comment] = []
    var databaseRef : DatabaseReference?
    var observe : UInt?
    var users : [String:AnyObject]?
    var peopleCount : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference().child("users").observeSingleEvent(of: .value) { (datasnapshot) in
            self.users = datasnapshot.value as! [String:AnyObject]
        }
        
        uid = Auth.auth().currentUser?.uid
        
        getMessageList()
    }
    
    func getMessageList() {
        databaseRef = Database.database().reference().child("chatrooms").child(self.destinationRoom!).child("comments")
        observe = databaseRef?.observe(DataEventType.value) { (datasnapshot) in
            self.comments.removeAll()
            
            var readUserDic : Dictionary<String, AnyObject> = [:]
            
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                let key = item.key as String
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                let commentMotify = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                commentMotify?.readUsers[self.uid!] = true
                comment?.readUsers[self.uid!] = true
                readUserDic[key] = comment?.toJSON() as! NSDictionary
                
                self.comments.append(comment!)
            }
            
            let nsDic = readUserDic as NSDictionary
            
            if(self.comments.last?.readUsers.keys == nil) {
                return
            }
            
            if ((self.comments.last?.readUsers.keys.contains(self.uid!)) != nil) {
            datasnapshot.ref.updateChildValues(nsDic as! [AnyHashable:Any], withCompletionBlock: { (error, ref) in
            
            self.tableView.reloadData()
            
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: .bottom, animated: false)
            }
            })
        } else
            {
                self.tableView.reloadData()
                
                if self.comments.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
        }
    }
    
    func setReadCount(label: UILabel?, position: Int?) {
        let readCount = self.comments[position!].readUsers.count
        
        if (peopleCount == nil) {
        
        Database.database().reference().child("chatrooms").child(destinationRoom!).child("users").observeSingleEvent(of: .value) { (datasnapshot) in
            let dic = datasnapshot.value as! [String:Any]
            self.peopleCount = dic.count
            let noReadCount = self.peopleCount! - readCount
            
            if (noReadCount > 0) {
                label?.isHidden = false
                label?.text = String(noReadCount)
            } else {
                label?.isHidden = true
            }
        }
        } else {
            let noReadCount = peopleCount! - readCount
            
            if (noReadCount > 0) {
                label?.isHidden = false
                label?.text = String(noReadCount)
            } else {
                label?.isHidden = true
            }
        }
    }
    
    
    func sendGcm(pushToken : String) {
        
        let url = "https://fcm.googleapis.com/fcm/send"
        let header : HTTPHeaders = [
            "Content-Type" : "application/json",
            "Authorization" : "key=AAAAUb9MMeg:APA91bHlc3fjdTanmvnLwQf7vLDGkaa5NJn2Q_VX-v6O7Cy95GpjC4xP8-IoD6w_hFEAKITh_FH7S0ak6dzfvmLVaLFomiY4i7n32ym-FwLzsQaZJU7EB6MXjZjxDPBdSOskUeLF7OBl"
        ]
        
        let user = Auth.auth().currentUser
        
         var notificationModel = NotificationModel()
        notificationModel.to = pushToken
        notificationModel.notification.title = user?.displayName
        notificationModel.notification.body = textField.text
        notificationModel.data.title = user?.displayName
        notificationModel.data.body = textField.text
        
        let params = notificationModel.toJSON()
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            print(response.result)
        }
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
            
            setReadCount(label: view.readCountText, position: indexPath.row)
            
            return view
        } else {
            let destinationUser = users![self.comments[indexPath.row].uid!]
            let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.nameText.text = destinationUser!["name"] as! String
            view.messageText.text = self.comments[indexPath.row].message
            view.messageText.numberOfLines = 0
        
            let url = URL(string: (destinationUser!["profileImageUrl"] as! String))
            view.profileImage.layer.cornerRadius = view.profileImage.frame.width / 2
            view.profileImage.clipsToBounds = true
            view.profileImage.kf.setImage(with: url)
      
            if let time = self.comments[indexPath.row].time {
                view.timeText.text = time.toDayTime
            }
            
           setReadCount(label: view.readCountText, position: indexPath.row)
            
        return view
        }
    
    }
    

    @IBAction func sendMessage(_ sender: UIButton) {
        let value : Dictionary<String,Any> = [
            "uid" : uid!,
            "message" : textField.text!,
            "timestamp" : ServerValue.timestamp()
        ]
        
        Database.database().reference().child("chatrooms").child(destinationRoom!).child("comments").childByAutoId().setValue(value) { (error, ref) in
            Database.database().reference().child("chatrooms").child(self.destinationRoom!).child("users").observeSingleEvent(of: .value) { (datasnapshot) in
                let dic = datasnapshot.value as! [String:Any]
                
                for item in dic.keys {
                    if (item == self.uid) {
                        continue
                    }
                    
                    let user = self.users![item]
                    self.sendGcm(pushToken: user!["pushToken"] as! String)
                }
                self.textField.text = ""
            }
        }
    }
}
