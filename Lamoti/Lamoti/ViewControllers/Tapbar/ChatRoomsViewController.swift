//
//  ChatViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/11/22.
//

import UIKit
import Firebase

class ChatRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var uid : String!
    var chatrooms : [ChatModel]! = []
    var destinationUsers : [String] = []

    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uid = Auth.auth().currentUser?.uid
        
        self.getChatroomsList()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewDidLoad()
    }
    
    func getChatroomsList() {
        
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: .value) { (datasnapshot) in
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                self.chatrooms.removeAll()
                if let chatroomdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatroomdic)
                    self.chatrooms.append(chatModel!)
                }
            }
            self.tableview.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath) as! CustomCell
        
        var destinationUid : String?
        
        for item in chatrooms[indexPath.row].users {
            if (item.key != self.uid) {
                destinationUid = item.key
                destinationUsers.append(destinationUid!)
            }
        }
        
        Database.database().reference().child("users").child(destinationUid!).observeSingleEvent(of: .value, with: { (datasnapshot) in
            let userModel = UserModel()
            userModel.setValuesForKeys(datasnapshot.value as! [String:AnyObject])
            
            cell.titleText.text = userModel.name
            let url = URL(string: userModel.profileImageUrl!)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                DispatchQueue.main.sync {
                    cell.profileImage.image = UIImage(data:data!)
                    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.width / 2
                    cell.profileImage.layer.masksToBounds = true
                }
            }).resume()
            
            // Z ~ A 순으로 정렬 ( 큰쪽에서 작은쪽으로 )
            let lastMessageKey = self.chatrooms[indexPath.row].comments.keys.sorted(){$0>$1}
            cell.lastMessageText.text = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.message
            
            let unixTime = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.time
            cell.timeText.text = unixTime?.toDayTime
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let destinationUid = self.destinationUsers[indexPath.row]
        let view = self.storyboard?.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
        view.destinationUid = destinationUid
        self.navigationController?.pushViewController(view, animated: true)
    }
}

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var lastMessageText: UILabel!
    @IBOutlet weak var timeText: UILabel!
    
    
}
